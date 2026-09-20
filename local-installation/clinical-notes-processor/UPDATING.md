# Updating an existing installation

Steps to update a running `clinical-notes-processor` installation to a new released
version. Run all commands from the `clinical-notes-processor` install folder.

## 1. Re-download the installation files

This refreshes `docker-compose.yml`, `.env.example`, `README.md`, the eval scripts,
`preprocess-data.sh`, and this file itself (the re-processing table in Step 5 grows with
each release, so re-fetching it here keeps you on the current version of the table, not
whatever was current when you first downloaded it). It does **not** touch your real `.env`
— your secrets/config are untouched.

```bash
base="https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/clinical-notes-processor"
for f in README.md docker-compose.yml .env.example run-evaluation.sh EVALUATION.md \
         run-loadtest.sh LOAD_TEST.md preprocess-data.sh UPDATING.md; do
  curl -fsSL "$base/$f" -o "$f"
done
chmod +x run-evaluation.sh run-loadtest.sh preprocess-data.sh
```

(If you're partway through following these steps, finish this run first — updating the file
under you mid-read is confusing. Just make sure you fetch the latest before your *next*
update.)

## 2. `.env` — no changes required for a normal update

New env vars ship with safe defaults baked into `docker-compose.yml` (e.g.
`CLINICAL_RAW_QA_EXTRA_MODELS`, `CLINICAL_RAW_QA_CHUNK_CHARS`,
`CLINICAL_RAW_QA_CHUNK_OVERLAP_CHARS`). Only touch `.env` if you want to opt into an
optional feature (see below) or a specific release's notes tell you to.

### 2a. (Optional) Enable the extra raw comparison model (e.g. medgemma:4b)

Only do this if you actually want a second "raw" comparison model available in the Open
WebUI dropdown. Not required for a normal update.

```bash
ollama pull medgemma:4b
```

Then in `.env`, uncomment/set:

```
CLINICAL_RAW_QA_EXTRA_MODELS=clinical-notes-model-raw-medgemma:medgemma:4b
```

## 3. Pull and restart

```bash
docker compose pull
docker compose up -d
```

## 4. Verify the new version is actually running

```bash
docker compose run --rm clinical-api python -c \
  "import tomllib; print(tomllib.load(open('pyproject.toml','rb'))['project']['version'])"
```

Compare the printed version against the release you expect.

## 5. Re-process the notes — only if the release you're upgrading to needs it

`./preprocess-data.sh` (ingest -> index -> force-extract, one command) forces recomputation
of every cohort variable for every patient — with real patient counts this can be a lot of
LLM calls and real time. **Only run it if it's actually needed.** `scripts.extract` can only
tell that your notes, the answering model, or a variable's question text changed — it has
no way to detect that the extraction/evidence-selection *code* changed, so a release that
fixes that code silently skips already-extracted data forever unless you force it. Check
the table below for every version between the one you're currently running and the one
you're upgrading to (skipping straight past several releases at once means checking all of
them, not just the newest):

| Version | Re-processing needed? | Why |
|---|---|---|
| 0.5.0 | **No** | Adds a new comparison model (`chunked_qa`) and fixes narrative-path/Ollama/Docker bugs — none of it touches indexing, chunking, or the cohort extraction/evidence-selection code. |
| 0.4.0 | **Yes** | Changed how cohort citations are chosen (citation-honesty fix) — extraction code changed without notes/model/question changing, so `--force` is the only way already-extracted data picks it up. Indexing unaffected (same embedding model/chunking). |

*(Maintainers: add a row here for every future release that changes indexing/chunking or
the extraction/evidence-selection code, so this table stays the source of truth instead of
each release re-explaining its own rationale inline.)*

If any version in your upgrade path needs it:

```bash
./preprocess-data.sh
```

Worth running during a low-usage window. See `README.md`'s "Updating to a new application
version" section for more on `--force`. Running it when it isn't needed is safe, just slow
— when in doubt, run it.

## 6. Smoke test

Ask a few questions you already know the answer to, covering:

- A single-patient lookup
- A cohort count ("how many patients have X")
- A negated cohort question ("how many patients don't have X")
- Anything specifically called out as fixed in the release notes for the version you just
  installed
