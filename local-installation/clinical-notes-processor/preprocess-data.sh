#!/usr/bin/env bash
#
# preprocess-data.sh — ingest, index, and extract your real patient notes (the "Step 7"
# pipeline from README.md), forcing cohort re-extraction so a release's fix to the
# extraction/evidence-selection code applies to data already extracted under an older
# version.
#
# Why --force is needed here (and only on extract, not index): scripts.extract only
# recomputes a variable when your notes, the answering model, or the variable's own
# question text changed -- it has no way to tell that the extraction/evidence-selection
# CODE changed instead. Whether a given release needs this run at all is stated in that
# release's own notes (see CLAUDE.md / UPDATING.md) -- if indexing/chunking or the
# extraction/evidence-selection logic didn't change, this script has nothing new to pick
# up and is safe but unnecessary to run.
#
# This runs against your REAL, already-running application (its real .env and
# registry-data volume) -- unlike run-evaluation.sh / run-loadtest.sh, which deliberately
# use an isolated scratch copy and never touch production data. Forcing re-extraction of
# every cohort variable can mean a lot of LLM calls for a real patient count; consider
# running this during a low-usage window.
#
# Run from this directory:
#   ./preprocess-data.sh

set -euo pipefail
cd "$(dirname "$0")"   # so docker compose / .env resolve relative to this folder

command -v docker >/dev/null 2>&1 || { echo "ERROR: docker is not installed or not on PATH." >&2; exit 1; }
[ -f docker-compose.yml ] || { echo "ERROR: run this from the clinical-notes-processor folder (no docker-compose.yml here)." >&2; exit 1; }
[ -f .env ] || { echo "ERROR: no .env here. Copy .env.example to .env and fill it in first (see README.md Step 5)." >&2; exit 1; }

echo "==> Registering notes (scripts.ingest)"
docker compose run --rm clinical-api python -m scripts.ingest

echo "==> Indexing notes (scripts.index) — incremental unless a release note says otherwise"
docker compose run --rm clinical-api python -m scripts.index

echo "==> Extracting cohort variables, forcing recomputation of every variable"
echo "    (picks up any extraction/evidence-selection fix for data extracted under an older version)"
docker compose run --rm clinical-api python -m scripts.extract --force

echo ""
echo "Done. Your application is now serving cohort answers from the freshly re-extracted data."
