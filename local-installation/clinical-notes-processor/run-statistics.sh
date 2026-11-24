#!/usr/bin/env bash
#
# run-statistics.sh — counts-only statistics for reporting (e.g. a publication's methods):
# the notes, the specialist-visit extraction output, and how long the extraction took.
#
# What it does (see EXTRACTION.md, "Run statistics", for how to read the output):
#   - runs run_statistics.py inside the application container, read-only against the database,
#   - prints the application/Ollama/model versions, note and passage counts, visit counts,
#     and the extraction run time (estimated from the database, exact if you supply a log),
#   - saves everything to run-statistics-<date>-<time>.txt in this folder.
#
# No model calls, no changes, and no patient identifiers, note text or quotes in the output.
# Run it from this directory:
#   ./run-statistics.sh                      # estimate the run time from the database
#   ./run-statistics.sh extraction.log       # exact run time from a saved extraction log
#
# To save a log for the next extraction run:
#   docker compose run --rm clinical-api python -m scripts.extract --force-specialty-dates 2>&1 | tee extraction.log

set -euo pipefail
cd "$(dirname "$0")"   # so `docker compose` finds docker-compose.yml and .env in this folder

command -v docker >/dev/null 2>&1 || { echo "ERROR: docker is not installed or not on PATH." >&2; exit 1; }
[ -f docker-compose.yml ] || { echo "ERROR: run this from the clinical-notes-processor folder (no docker-compose.yml here)." >&2; exit 1; }
[ -f .env ] || { echo "ERROR: no .env here. Copy .env.example to .env and fill it in first (see README.md Step 5)." >&2; exit 1; }
[ -f run_statistics.py ] || { echo "ERROR: run_statistics.py is missing; download it next to this script (README.md Step 3)." >&2; exit 1; }

log_b64=""
if [ $# -ge 1 ]; then
  [ -r "$1" ] || { echo "ERROR: cannot read log file '$1'." >&2; exit 1; }
  # Passed to the container as text inside the script, so no extra folder has to be mounted.
  log_b64="$(base64 < "$1" | tr -d '\n')"
fi

out="run-statistics-$(date +%Y%m%d-%H%M%S).txt"
{
  echo "Clinical Notes Processor — run statistics, generated $(date -u '+%Y-%m-%d %H:%M UTC')"
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "GPU: $(nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader 2>/dev/null | head -1)"
  fi
  { printf 'LOG_B64 = "%s"\n' "${log_b64}"; cat run_statistics.py; } |
    docker compose run --rm -T clinical-api python -
} | tee "${out}"

echo "Saved to ${out} (counts only; safe to share)."
