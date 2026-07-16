#!/usr/bin/env bash
#
# run-evaluation.sh — validate this install on your server with the built-in synthetic test.
#
# What it does (see EVALUATION.md for the full explanation and how to read the result):
#   - generates a ~1 MB fully synthetic test patient (no real data) in an isolated scratch volume,
#   - indexes it and runs the recall evaluation against the production-configured AI model,
#   - reports the peak GPU memory used (the 16 GB fit check) and the accuracy/timing summary.
#
# Your real notes and search index are never touched. Run it from this directory:  ./run-evaluation.sh
# Set KEEP_EVAL_DATA=1 to keep the scratch volume afterwards (e.g. to debug a failure).

set -euo pipefail
cd "$(dirname "$0")"   # so `docker compose` finds docker-compose.yml and .env in this folder

VOLUME="clinical-eval-data"
KEEP_EVAL_DATA="${KEEP_EVAL_DATA:-0}"

# Sanity checks with friendly messages.
command -v docker >/dev/null 2>&1 || { echo "ERROR: docker is not installed or not on PATH." >&2; exit 1; }
[ -f docker-compose.yml ] || { echo "ERROR: run this from the clinical-notes-processor folder (no docker-compose.yml here)." >&2; exit 1; }
if [ ! -f .env ]; then
  [ -f .env.example ] || { echo "ERROR: no .env and no .env.example here — run from the clinical-notes-processor folder." >&2; exit 1; }
  cp .env.example .env

  # Pick the Ollama address the container should use, based on the host OS:
  #   macOS (Docker Desktop): host.docker.internal reaches the host
  #   Linux:                  the Docker bridge gateway (usually 172.17.0.1)
  case "$(uname -s)" in
    Darwin) ollama_host="http://host.docker.internal:11434" ;;
    *)      ollama_host="http://172.17.0.1:11434" ;;
  esac

  # Apply OLLAMA_HOST and a freshly generated WEBUI_SECRET_KEY (portable; no GNU/BSD sed -i).
  secret="$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  tmp="$(mktemp)"
  awk -v h="${ollama_host}" -v s="${secret}" '
    /^OLLAMA_HOST=/      { print "OLLAMA_HOST=" h; seen_h=1; next }
    /^WEBUI_SECRET_KEY=/ { print "WEBUI_SECRET_KEY=" s; seen_s=1; next }
    { print }
    END {
      if (!seen_h) print "OLLAMA_HOST=" h
      if (!seen_s) print "WEBUI_SECRET_KEY=" s
    }' .env >"${tmp}" && mv "${tmp}" .env

  echo "Created .env from .env.example (OLLAMA_HOST=${ollama_host}, generated WEBUI_SECRET_KEY)."
  echo "If your Ollama runs elsewhere, edit OLLAMA_HOST in .env. Continuing..."
fi

# Image the evaluation runs against. Exported here (overriding .env) so the eval ONLY uses the
# candidate for its own steps -- it does NOT change the image your application serves via
# `docker compose up`, which keeps the default in docker-compose.yml / your .env. Leave
# CLINICAL_IMAGE commented in .env so production stays on the stable release. Override the
# candidate with:  EVAL_IMAGE=... ./run-evaluation.sh
export CLINICAL_IMAGE="${EVAL_IMAGE:-harbor.honeur.org/honeur/clinical-notes-processor:0.3.0-rc1}"

# These options redirect every path the tools use into the isolated scratch volume,
# so production notes (read-only) and the production registry are left untouched.
EVAL_OPTS=(--rm
  -e CLINICAL_NOTES_DIR=/eval/notes
  -e CLINICAL_DB_PATH=/eval/registry/registry.db
  -e CLINICAL_RECALL_GOLD_PATH=/eval/recall_gold/needles.csv
  -v "${VOLUME}:/eval")

run() { docker compose run "${EVAL_OPTS[@]}" clinical-api "$@"; }

echo "==> Checking application version (need >= 0.2.0)"
ver="$(docker compose run --rm clinical-api \
  python -c "import importlib.metadata as m; print(m.version('clinical-notes-processor'))" | tr -d '\r')"
echo "    version: ${ver}"
case "${ver}" in
  0.0.*|0.1.*)
    echo "ERROR: image is ${ver}, but the evaluation needs >= 0.2.0." >&2
    echo "       Pin CLINICAL_IMAGE to :0.3.0-rc1 (or later) in .env, run 'docker compose pull', and retry." >&2
    echo "       See EVALUATION.md." >&2
    exit 1 ;;
esac

echo "==> Creating isolated scratch volume (${VOLUME})"
docker volume create "${VOLUME}" >/dev/null

cleanup() {
  code=$?
  if [ "${code}" -eq 0 ] && [ "${KEEP_EVAL_DATA}" != "1" ]; then
    echo "==> Cleaning up scratch volume"
    docker volume rm "${VOLUME}" >/dev/null 2>&1 || true
  elif [ "${code}" -ne 0 ]; then
    echo "Note: evaluation did not finish cleanly; scratch volume '${VOLUME}' kept for inspection." >&2
    echo "      Remove it with:  docker volume rm ${VOLUME}" >&2
  fi
}
trap cleanup EXIT

# A fresh named volume is root-owned, but the container runs as a non-root user (uid 10001).
# Create the subdirectories once as root and hand them to that user so the eval steps can write.
echo "==> Preparing the scratch volume"
docker compose run --rm --user root -v "${VOLUME}:/eval" clinical-api \
  sh -c 'mkdir -p /eval/notes /eval/registry /eval/recall_gold && chown -R 10001 /eval'

echo "==> Generating the ~1 MB synthetic test record (no real data)"
run python -m scripts.gen_recall_corpus

echo "==> Registering and indexing it"
run python -m scripts.ingest
run python -m scripts.index

# Background GPU-memory sampler — the 16 GB fit check. Skipped if nvidia-smi is unavailable.
samples="$(mktemp)"
sampler_pid=""
if command -v nvidia-smi >/dev/null 2>&1; then
  ( while true; do
      nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1
      sleep 2
    done ) >"${samples}" &
  sampler_pid=$!
fi

echo "==> Running the recall evaluation (this loads the model on the GPU)"
run python -m scripts.eval_recall

if [ -n "${sampler_pid}" ]; then
  kill "${sampler_pid}" 2>/dev/null || true
  peak="$(awk -F', *' 'NF{print $1}' "${samples}" | sort -n | tail -1)"
  total="$(awk -F', *' 'NF{print $2}' "${samples}" | tail -1)"
  [ -n "${peak}" ] && echo "==> Peak GPU memory during evaluation: ${peak} MiB of ${total} MiB total"
fi
rm -f "${samples}"

echo ""
echo "Done. Interpret the summary line above using EVALUATION.md ('How to read the result')."
echo "It passes if: it finished without out-of-memory; hallucination_rate is 0.0;"
echo "and recall_at_k / answer_accuracy are near the reference (~1.0 / ~0.88)."
