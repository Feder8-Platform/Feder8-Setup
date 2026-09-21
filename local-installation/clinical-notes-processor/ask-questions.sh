#!/usr/bin/env bash
#
# ask-questions.sh — send a list of questions to the running application and capture the
# full raw responses to a single timestamped file, so someone can send that file back
# instead of running questions interactively in Open WebUI and paraphrasing the results.
#
# Talks directly to the already-running clinical-api service on localhost:8000 (the same
# port docker-compose.yml exposes) -- no .env, no docker compose invocation, and it never
# touches your real data: these are the same read-only chat questions a user would type
# into Open WebUI, just sent via curl and logged instead of typed by hand.
#
# Run from anywhere on the server (it only needs `curl` on PATH):
#   ./ask-questions.sh
#
# Override the model or add/edit questions by editing the QUESTIONS array below, or by
# exporting MODEL=<other-served-id> before running (e.g. MODEL=clinical-notes-model-chunked).

set -euo pipefail

MODEL="${MODEL:-clinical-notes-model}"
API_URL="${API_URL:-http://localhost:8000/v1/chat/completions}"
OUTFILE="diagnostic-output-$(date +%Y%m%d-%H%M%S).txt"

# Edit this list for whatever you're currently debugging. Defaults to the negation
# investigation questions from 2026-09-23 (item 1 of the production feedback roadmap).
QUESTIONS=(
  "which patients don't have anaemia"
  "list the patients where anaemia is no"
  "list the patients where anaemia is not present"
  "list the patients where anaemia is not documented"
)

command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is not installed or not on PATH." >&2; exit 1; }

if ! curl -fsS -m 5 "http://localhost:8000/v1/models" >/dev/null 2>&1; then
  echo "ERROR: can't reach http://localhost:8000 -- is the application running here?" >&2
  echo "       (docker compose ps / docker compose up -d from the install folder)" >&2
  exit 1
fi

{
  echo "clinical-notes-processor diagnostic output"
  echo "model: ${MODEL}"
  echo "generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "========================================"
} > "${OUTFILE}"

for q in "${QUESTIONS[@]}"; do
  echo "==> Asking: ${q}"
  {
    echo ""
    echo "----------------------------------------"
    echo "Q: ${q}"
    echo "----------------------------------------"
  } >> "${OUTFILE}"

  # Simple substitution -- fine for the plain-text questions in QUESTIONS above. If you add
  # a question containing a literal " or \, escape it yourself (\" / \\) before adding it.
  payload=$(printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"stream":false}' \
    "${MODEL}" "${q}")

  if response=$(curl -fsS -m 300 "${API_URL}" -H "Content-Type: application/json" -d "${payload}" 2>&1); then
    echo "${response}" >> "${OUTFILE}"
  else
    echo "ERROR: request failed: ${response}" >> "${OUTFILE}"
    echo "   (request failed, see ${OUTFILE})"
  fi
done

echo ""
echo "Done. Send this file back: ${OUTFILE}"
