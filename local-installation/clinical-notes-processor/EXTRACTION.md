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
| Diagnostics: re-scan without the specialty keyword screen (see below) | add `--exhaustive-specialty-scan` |
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

If a call to the model fails for a patient (for example, Ollama restarts mid-run), that
patient's existing rows are kept, a `FAILED` line is logged for it, the run carries on
with the other patients, and the command exits with a non-zero status
(`specialty_encounters_failed` in the final summary counts them). Run
`scripts.extract` again (no flag needed) to redo only those patients.

### `--exhaustive-specialty-scan`

Disables the specialty keyword screen for the specialty-date extraction pass. By
default, a passage that contains no term from the specialty vocabulary (specialty
names, word stems, organ/field words, service phrases and common abbreviations such
as "Derm", "Haem-Onc" — see `variables/specialty_terms.py`) is skipped without an LLM
call, and the model is offered only the specialties named in the passage.

Since 0.8.2 this screen is **lossless**: a finding is only kept when its supporting
quote — which must be text from the passage — contains a term for that specialty from
the same vocabulary. A skipped passage could therefore never have produced a kept
encounter, and an exhaustive scan finds nothing extra; it only costs time.

```bash
docker compose run --rm clinical-api python -m scripts.extract \
  --force-specialty-dates --exhaustive-specialty-scan
```

Use it only for diagnostics, for example to confirm on your own data that the screen
changes nothing. Without `--force-specialty-dates` too, it only affects patients that
are re-extracted anyway under the normal staleness rule.

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

Specialty-dates only, scoped to a subset:

```bash
docker compose run --rm clinical-api python -m scripts.extract \
  --patient-id Patient_12 --patient-id Patient_47 --force-specialty-dates
```

Everything, everywhere — the heaviest normal run:

```bash
docker compose run --rm clinical-api python -m scripts.extract --force
```

## Timing

Specialty-date extraction reads every passage of every note (never similarity-based
retrieval), so its cost scales with the size of the notes, not with the number of
questions. A note of up to 32000 characters is read whole; a longer one is read in
section-aligned passages of up to 2000 characters (about 500 passages for a ~1 MB
note). Each passage that passes the keyword screen costs one extraction call, plus one
short verification call per candidate encounter, and occasionally a recheck call.
Undated passages that only repeat already-extracted wording (such as letter footers)
are skipped.

Expect a full `--force-specialty-dates` run on a ~50-patient, ~1 MB-per-patient corpus
to take hours. To see how long your own run took, use `./run-statistics.sh` (see "Run
statistics" below). If you're short on time before a deadline, use `--patient-id` to
process only the patients you need.

No direct database access is needed for any of the above — these flags are the
supported way to control what gets recomputed.

## Run statistics

`./run-statistics.sh` prints counts-only statistics about the notes, the
specialist-visit extraction output and how long the extraction took — for example
for the methods section of a publication. It only reads the database, makes no
model calls, takes seconds, and can run while the application is up. The output
contains no patient identifiers, note text or quotes, and is also saved to
`run-statistics-<date>-<time>.txt` in this folder.

```bash
./run-statistics.sh                  # run time estimated from the database
./run-statistics.sh extraction.log   # exact run time from a saved extraction log
```

The output has four sections:

1. **Software and model** — application version, Ollama version, and the model's
   parameter size, quantisation and digest (asked from Ollama; the model is not run).
   The GPU name and memory are added when `nvidia-smi` is available.
2. **Notes** — note files, characters and estimated tokens per patient, and the
   passages the visit extraction reads (passages per patient, characters per passage,
   share passing the specialty keyword screen). Each line gives the total, median with
   interquartile range (IQR), mean, minimum and maximum over patients. Tokens are
   estimated from characters: the application's own rule (4 characters per token) and
   a lower/upper bound for the Qwen3 tokenizer (3.4 and 3.0 characters per token, as
   measured on synthetic notes).
3. **Extraction output** — visits per patient, how many have a standardised date, a
   written date that could not be standardised, or no date, the number of distinct
   specialties, and the model that produced the rows.
4. **Extraction time** — the database stores when each patient's visit extraction
   finished. Patients are processed one after another, so the gap between two
   consecutive completions is a patient's processing time; the first patient's time
   is estimated as the median. Completions more than 6 hours apart count as separate
   runs, and only the most recent run is timed. This covers the visit extraction only,
   not the yes/no variable extraction that `scripts.extract` runs first.

For exact times, save the console output of the extraction run and pass that file:

```bash
docker compose run --rm clinical-api python -m scripts.extract --force-specialty-dates 2>&1 | tee extraction.log
./run-statistics.sh extraction.log
```

Section **4b** then reports the duration of the whole command and of the visit
extraction, the time and passages per patient, completed / failed / skipped patients,
undated repeated passages skipped, and over-long model replies that were split and
retried. If the log holds several runs, the last complete one is used.
