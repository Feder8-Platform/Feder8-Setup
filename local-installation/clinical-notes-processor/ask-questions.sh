#!/usr/bin/env bash
#
# ask-questions.sh — send a list of cohort questions to the running application and
# capture ONLY the aggregate summary (match count / total / which path answered it) to a
# file that can be sent back for debugging. Deliberately does NOT save or print patient
# identifiers, citation text, or any other patient-level content -- see "What this
# captures" below.
#
# Talks directly to the already-running clinical-api service on localhost:8000 (the same
# port docker-compose.yml exposes) -- no .env, no docker compose invocation needed, and it
# never modifies any data: these are the same read-only chat questions a user would type
# into Open WebUI, just sent via curl and logged instead of typed by hand.
#
# Run from anywhere on the server (it only needs `curl` and GNU `grep -P` on PATH):
#   ./ask-questions.sh
#
# Override the model or add/edit questions by editing the QUESTIONS array below, or by
# exporting MODEL=<other-served-id> before running (e.g. MODEL=clinical-notes-model-chunked).
#
# What this captures (and nothing else):
#   - which of the fixed QUESTIONS below was asked (the questions themselves, not any
#     patient-specific content -- edit the list below if a question itself must not leave
#     the site, but the defaults here name only a clinical concept, never a patient)
#   - whether the cohort SQL fast path or the live judge answered it
#   - the aggregate "N of M patients <verb>" summary line's numbers and verb only
# It never captures: patient IDs/names, citation quotes, note filenames, or the raw
# response body -- those are discarded in-memory and never written to disk or printed.
#
# Note on the single-patient question in the default list ("is patient 26 male?"): this is
# expected to report "could not find a cohort summary line" below, since a single-patient
# answer isn't a cohort summary and its actual answer is never captured (that would be
# patient-level content). The "path" line for it is still useful signal on its own.

set -euo pipefail

MODEL="${MODEL:-clinical-notes-model}"
API_URL="${API_URL:-http://localhost:8000/v1/chat/completions}"
OUTFILE="diagnostic-output-$(date +%Y%m%d-%H%M%S).txt"

# Edit this list for whatever you're currently debugging. Defaults to the negation
# investigation questions from 2026-09-23 (item 1 of the production feedback roadmap).
# Keep each question free of any patient-identifying content -- it's written to the file
# verbatim as a label.
QUESTIONS=(
  "which patients don't have anaemia"
  "list the patients where anaemia is no"
  "list the patients where anaemia is not present"
  "list the patients where anaemia is not documented"
  "how many patients are male"
  "how many patients are female"
  "is patient 26 male?"
)

command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is not installed or not on PATH." >&2; exit 1; }
echo | grep -oP '' >/dev/null 2>&1 || { echo "ERROR: this script needs GNU grep with -P (PCRE) support." >&2; exit 1; }

if ! curl -fsS -m 5 "http://localhost:8000/v1/models" >/dev/null 2>&1; then
  echo "ERROR: can't reach http://localhost:8000 -- is the application running here?" >&2
  echo "       (docker compose ps / docker compose up -d from the install folder)" >&2
  exit 1
fi

{
  echo "clinical-notes-processor diagnostic output (aggregate counts only, no patient-level data)"
  echo "model: ${MODEL}"
  echo "generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "========================================"
} > "${OUTFILE}"

for q in "${QUESTIONS[@]}"; do
  echo "==> Asking: ${q}"

  # Simple substitution -- fine for the plain-text questions in QUESTIONS above. If you add
  # a question containing a literal " or \, escape it yourself (\" / \\) before adding it.
  payload=$(printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"stream":false}' \
    "${MODEL}" "${q}")

  http_status=$(curl -sS -m 300 -o /tmp/ask-questions-response.$$ -w '%{http_code}' \
    "${API_URL}" -H "Content-Type: application/json" -d "${payload}" || echo "000")

  {
    echo ""
    echo "----------------------------------------"
    echo "Q: ${q}"
  } >> "${OUTFILE}"

  if [ "${http_status}" != "200" ]; then
    echo "result: HTTP ${http_status} (request failed -- no content captured)" >> "${OUTFILE}"
    rm -f /tmp/ask-questions-response.$$
    continue
  fi

  # Extract ONLY the aggregate "N of M patients <verb>" summary from inside the response's
  # markdown bold markers. This substring is plain ASCII with no JSON escaping in it, so it
  # can be pulled straight out of the raw (still JSON-encoded) response body without ever
  # decoding or storing the rest of the content.
  summary=$(grep -oP '(?<=\*\*)\d+ of [\w ]+ patients [a-z ]+(?=\*\*|:)' /tmp/ask-questions-response.$$ | head -1 || true)
  path="unknown"
  if grep -q 'from pre-extracted variables' /tmp/ask-questions-response.$$ 2>/dev/null; then
    path="SQL fast path"
  elif grep -q 'Checking .* … (' /tmp/ask-questions-response.$$ 2>/dev/null; then
    path="live cohort path"
  fi
  rm -f /tmp/ask-questions-response.$$

  if [ -n "${summary}" ]; then
    echo "path: ${path}" >> "${OUTFILE}"
    echo "result: ${summary}" >> "${OUTFILE}"
  else
    echo "path: ${path}" >> "${OUTFILE}"
    echo "result: could not find a cohort summary line (response may not have been a cohort answer)" >> "${OUTFILE}"
  fi
done

echo ""
echo "Done. Send this file back: ${OUTFILE}"
echo "(It contains only question text, match counts/totals, and which code path answered --"
echo " no patient identifiers, quotes, or other patient-level content.)"
