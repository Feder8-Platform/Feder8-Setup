# Extraction options

`scripts.extract` is the offline step that pre-computes two things from your ingested
and indexed notes: the cohort variable table (`patient_variables` — the `seen_by_*`
booleans, dates, etc.) and the specialty-encounter table (`specialty_encounters` —
every dated specialty encounter found in the notes, one row per encounter). This
runs against your **real** application data (its `.env` and registry-data volume) —
run it during a low-usage window if you're forcing a full re-extraction.

Run every command below from this folder (`docker-compose.yml` must be present).
Prereqs: `scripts.ingest` and `scripts.index` already run for the notes you want
covered (`./preprocess-data.sh` does all three steps in sequence with `--force`; the
commands below are for running `scripts.extract` on its own, with finer control).

By default `scripts.extract` only recomputes rows that are **stale** — notes, the
answering model, or a variable's question text changed since it was last extracted.
It has no way to detect that the extraction/evidence-selection *code* changed, so a
release that fixes that logic needs one of the `--force*` flags below to actually
apply to already-extracted data.

## Quick decision guide

| You want to... | Command |
|---|---|
| Normal incremental run (new/changed notes only) | `docker compose run --rm clinical-api python -m scripts.extract` |
| Pick up a code fix, everywhere, for everyone | `--force` |
| Pick up a code fix for one variable only | `--force-variable NAME` (repeatable) |
| Pick up a code fix to specialty-date extraction only | `--force-specialty-dates` |
| Re-scan without the specialty pre-filter (see below) | add `--exhaustive-specialty-scan` |
| Process only specific patients (e.g. today's known subset) | add `--patient-id ID` (repeatable) |

## The options, explained

### `--force`

Recomputes **every** `patient_variables` row and **every** `specialty_encounters`
row, ignoring staleness entirely.

```bash
docker compose run --rm clinical-api python -m scripts.extract --force
```

Use this after upgrading to a release whose notes say it changed the
extraction/evidence-selection logic (this is what `preprocess-data.sh` does). Most
expensive option — full LLM re-scan of every patient for both extraction paths.

### `--force-variable NAME` (repeatable)

Recomputes only the named variable's rows across all patients, leaving everything
else (including specialty-encounter dates) alone.

```bash
docker compose run --rm clinical-api python -m scripts.extract \
  --force-variable is_the_patient_male \
  --force-variable is_the_patient_female
```

Use for a targeted refresh when you know only specific variables were affected by a
change (variable names come from `variables.yaml`).

### `--force-specialty-dates`

Recomputes every `specialty_encounters` row (full replace per patient), without
forcing the per-variable extraction pass.

```bash
docker compose run --rm clinical-api python -m scripts.extract --force-specialty-dates
```

Use this to pick up a fix to the specialty-date extraction/normalization code
specifically, without paying for a full `patient_variables` re-run too. This is also
what you want the first time you bring up specialty-encounter-date extraction on a
corpus that was indexed before that feature existed — the table is empty until this
(or `--force`) runs.

### `--exhaustive-specialty-scan`

Disables the specialty pre-filter for the specialty-date extraction pass. By
default, a note/chunk that mentions no known specialty name and no broad
encounter-related cue word ("seen by", "consult", "clinic", "dr.", etc. — see
`_ENCOUNTER_CUE_WORDS` in `variables/specialty_date_extraction.py`) is skipped
without an LLM call, which is a large speedup on big corpora. It's a heuristic, so it
cannot *guarantee* catching an encounter phrased in some entirely novel way that
trips none of the cue words.

```bash
docker compose run --rm clinical-api python -m scripts.extract \
  --force-specialty-dates --exhaustive-specialty-scan
```

Use when you have time to spare and want the safest possible completeness guarantee
for specialty-encounter dates (e.g. a final validation pass), or if you suspect the
pre-filter is dropping real encounters phrased unusually. Without
`--force-specialty-dates` too, this only affects chunks that are re-extracted anyway
under the normal staleness rule — pair it with `--force-specialty-dates` (or
`--force`) to actually re-scan everything exhaustively.

This can take **hours** on a full ~50-patient, ~1MB-per-patient corpus — see
"Timing" below.

### `--patient-id ID` (repeatable)

Restricts extraction — both the per-variable pass and the specialty-date pass — to
the named patient id(s), instead of the whole roster. Combine freely with any of the
flags above.

```bash
docker compose run --rm clinical-api python -m scripts.extract \
  --patient-id Patient_12 --patient-id Patient_47 --force-specialty-dates
```

Use this to pre-process a known subset of patients first (e.g. the ones needed for
an immediate question) without waiting on a full-cohort run. Patient ids must match
what's already in the registry (from `scripts.ingest`).

## Useful combinations

Fast path, only the patients you need right now, picking up any pending code fixes
for both extraction types:

```bash
docker compose run --rm clinical-api python -m scripts.extract \
  --patient-id Patient_12 --patient-id Patient_47 --force
```

Specialty-dates only, safest completeness (no pre-filter), scoped to a subset:

```bash
docker compose run --rm clinical-api python -m scripts.extract \
  --patient-id Patient_12 --patient-id Patient_47 \
  --force-specialty-dates --exhaustive-specialty-scan
```

Everything, everywhere, default (fast) pre-filter — the heaviest normal run:

```bash
docker compose run --rm clinical-api python -m scripts.extract --force
```

## Timing

Specialty-date extraction scans notes exhaustively (never similarity-based
retrieval) — cost scales with corpus size, not question count. On a real ~1MB note,
the default cue-word pre-filter cuts LLM calls dramatically versus
`--exhaustive-specialty-scan`; expect roughly 2-4 seconds per LLM call once running,
so calls-avoided is the main lever. If you're short on time before a deadline, prefer
`--patient-id` to scope to only the patients you need, over disabling the pre-filter.

No direct database access is needed for any of the above — these flags are the
supported way to control what gets recomputed.
