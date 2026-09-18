# Updating an existing installation

Steps to update a running `clinical-notes-processor` installation to a new released
version. Run all commands from the `clinical-notes-processor` install folder.

## 1. Re-download the installation files

This refreshes `docker-compose.yml`, `.env.example`, `README.md`, the eval scripts, and
`preprocess-data.sh`. It does **not** touch your real `.env` — your secrets/config are
untouched.

```bash
base="https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/clinical-notes-processor"
for f in README.md docker-compose.yml .env.example run-evaluation.sh EVALUATION.md \
         run-loadtest.sh LOAD_TEST.md preprocess-data.sh; do
  curl -fsSL "$base/$f" -o "$f"
done
chmod +x run-evaluation.sh run-loadtest.sh preprocess-data.sh
```

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

## 5. Re-process the notes (ingest -> index -> force-extract, one command)

```bash
./preprocess-data.sh
```

Heads up: this forces recomputation of every cohort variable for every patient — with real
patient counts this can be a lot of LLM calls and real time. Worth running during a
low-usage window. See `README.md`'s "Updating to a new application version" section for
why `--force` is needed here rather than the plain Step 7 commands.

## 6. Smoke test

Ask a few questions you already know the answer to, covering:

- A single-patient lookup
- A cohort count ("how many patients have X")
- A negated cohort question ("how many patients don't have X")
- Anything specifically called out as fixed in the release notes for the version you just
  installed
