#!/usr/bin/env bash
#
# run-loadtest.sh — concurrency/throughput smoke test against an isolated instance of this install.
#
# What it does (see LOAD_TEST.md for the full explanation and how to read the result):
#   - generates the same ~1 MB fully synthetic test patient as run-evaluation.sh, in its own
#     isolated scratch volume,
#   - starts a SEPARATE, temporary instance of the application on that scratch data (its own
#     container, its own port — never your production instance on port 8000),
#   - fires several questions at it AT THE SAME TIME (simulating concurrent users) and reports
#     latency, errors, and whether answers stayed correct/grounded under that load.
#
# Your real notes, search index, and running application are never touched or restarted. Run it
# from this directory:  ./run-loadtest.sh
# Tune load with:   CONCURRENCY=3 ROUNDS=3 ./run-loadtest.sh   (defaults: concurrency=2, rounds=2)
# Set KEEP_EVAL_DATA=1 to keep the scratch volume afterwards (e.g. to debug a failure).

set -euo pipefail
cd "$(dirname "$0")"   # so docker compose / .env resolve relative to this folder

VOLUME="clinical-loadtest-data"
CONTAINER="clinical-loadtest"
PORT="${LOADTEST_PORT:-8001}"
CONCURRENCY="${CONCURRENCY:-2}"
ROUNDS="${ROUNDS:-2}"
KEEP_EVAL_DATA="${KEEP_EVAL_DATA:-0}"

# Sanity checks with friendly messages.
command -v docker >/dev/null 2>&1 || { echo "ERROR: docker is not installed or not on PATH." >&2; exit 1; }
[ -f docker-compose.yml ] || { echo "ERROR: run this from the clinical-notes-processor folder (no docker-compose.yml here)." >&2; exit 1; }
if [ ! -f .env ]; then
  [ -f .env.example ] || { echo "ERROR: no .env and no .env.example here — run from the clinical-notes-processor folder." >&2; exit 1; }
  cp .env.example .env
  case "$(uname -s)" in
    Darwin) ollama_host="http://host.docker.internal:11434" ;;
    *)      ollama_host="http://172.17.0.1:11434" ;;
  esac
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

# Candidate image with the load-test tool. Override with EVAL_IMAGE=... ./run-loadtest.sh
export CLINICAL_IMAGE="${EVAL_IMAGE:-harbor.honeur.org/honeur/clinical-notes-processor:0.2.0-rc2}"
docker pull "${CLINICAL_IMAGE}" >/dev/null

echo "==> Checking the image has the load-test tool"
if ! docker run --rm "${CLINICAL_IMAGE}" python -c "import scripts.load_test_concurrency" >/dev/null 2>&1; then
  echo "ERROR: ${CLINICAL_IMAGE} does not include scripts.load_test_concurrency." >&2
  echo "       Pin CLINICAL_IMAGE (via EVAL_IMAGE=...) to a build that has it, and retry." >&2
  exit 1
fi

# --env-file loads OLLAMA_HOST / CLINICAL_OLLAMA_MODEL from .env, same as docker-compose.yml does.
# We run plain `docker` (not `docker compose run`) throughout so this scratch instance never
# shares a network/service name with your real `clinical-api` service — no risk of Open WebUI or
# anything else being routed to the temporary instance instead of your production one.
scratch() { docker run --rm --env-file .env "$@"; }

echo "==> Creating isolated scratch volume (${VOLUME})"
docker volume create "${VOLUME}" >/dev/null

cleanup() {
  code=$?
  docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
  if [ "${code}" -eq 0 ] && [ "${KEEP_EVAL_DATA}" != "1" ]; then
    echo "==> Cleaning up scratch volume"
    docker volume rm "${VOLUME}" >/dev/null 2>&1 || true
  elif [ "${code}" -ne 0 ]; then
    echo "Note: load test did not finish cleanly; scratch volume '${VOLUME}' kept for inspection." >&2
    echo "      Remove it with:  docker volume rm ${VOLUME}" >&2
  fi
}
trap cleanup EXIT

echo "==> Preparing the scratch volume"
docker run --rm --user root -v "${VOLUME}:/eval" "${CLINICAL_IMAGE}" \
  sh -c 'mkdir -p /eval/notes /eval/registry /eval/recall_gold && chown -R 10001 /eval'

echo "==> Generating the ~1 MB synthetic test record (no real data)"
scratch -e CLINICAL_NOTES_DIR=/eval/notes -e CLINICAL_RECALL_GOLD_PATH=/eval/recall_gold/needles.csv \
  -v "${VOLUME}:/eval" "${CLINICAL_IMAGE}" python -m scripts.gen_recall_corpus

echo "==> Registering and indexing it"
scratch -e CLINICAL_NOTES_DIR=/eval/notes -e CLINICAL_DB_PATH=/eval/registry/registry.db \
  -v "${VOLUME}:/eval" "${CLINICAL_IMAGE}" python -m scripts.ingest
scratch -e CLINICAL_NOTES_DIR=/eval/notes -e CLINICAL_DB_PATH=/eval/registry/registry.db \
  -v "${VOLUME}:/eval" "${CLINICAL_IMAGE}" python -m scripts.index

echo "==> Starting a temporary, isolated instance of the app on the scratch data (port ${PORT})"
docker run -d --rm --name "${CONTAINER}" --env-file .env \
  -e CLINICAL_NOTES_DIR=/eval/notes -e CLINICAL_DB_PATH=/eval/registry/registry.db \
  -v "${VOLUME}:/eval" -p "${PORT}:8000" "${CLINICAL_IMAGE}" >/dev/null

echo "==> Waiting for it to become ready"
ready=0
for _ in $(seq 1 30); do
  if curl -sf "http://localhost:${PORT}/v1/models" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done
[ "${ready}" -eq 1 ] || { echo "ERROR: temporary instance did not become ready on port ${PORT}." >&2; exit 1; }

# Reach the temporary instance's published port from inside the load-generating container the
# same way OLLAMA_HOST already reaches the host: host.docker.internal (macOS) / bridge gateway
# (Linux). This avoids docker networking/DNS entirely, so there is never any ambiguity with the
# real clinical-api service.
case "$(uname -s)" in
  Darwin) docker_host="host.docker.internal" ;;
  *)      docker_host="172.17.0.1" ;;
esac
target_url="http://${docker_host}:${PORT}/v1/chat/completions"

echo "==> Firing concurrent questions at it (concurrency=${CONCURRENCY}, rounds=${ROUNDS})"
scratch -e CLINICAL_RECALL_GOLD_PATH=/eval/recall_gold/needles.csv -v "${VOLUME}:/eval" "${CLINICAL_IMAGE}" \
  python -m scripts.load_test_concurrency --url "${target_url}" --concurrency "${CONCURRENCY}" --rounds "${ROUNDS}"

echo ""
echo "Done. Interpret the summary line above using LOAD_TEST.md ('How to read the result')."
echo "It passes if: no errors, hallucination_rate stays 0.0, and accuracy stays near the serial"
echo "reference (~0.63, from EVALUATION.md) — i.e. nothing flips or breaks under concurrent load."
