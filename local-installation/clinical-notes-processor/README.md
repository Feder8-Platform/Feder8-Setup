# Clinical Notes Processor — Installation

## What is this?

A **private, on-premise assistant for asking questions about patients' clinical notes in plain
language.** A clinician or researcher types a question — *"Does patient A have evidence of cardiac
amyloidosis?"* or *"How many of these patients received a stem cell transplant?"* — and a local AI
model reads the notes and answers it.

Three properties make it suitable for sensitive medical data:

- **It runs entirely on your own machine.** No data is ever sent to the cloud or any external
  service. The AI model runs locally. This matters even though the notes are anonymized.
- **It answers *only* from the notes.** Every answer is grounded in the actual documents and shows
  the exact source passage it used. When the notes don't contain the answer, it says
  *"Not documented in the available notes"* instead of guessing or inventing facts.
- **It scales to large records.** A single patient's notes can be far too large to hand to an AI
  model all at once, and a whole cohort is larger still. The system automatically finds and uses
  only the relevant passages, so it stays accurate across many large patient files.

It can answer four kinds of question: a **single-patient lookup**, a **cohort count**
("how many patients had X?"), a **cross-patient search** ("which patients mention Y?"), and
**open-ended exploration**.

## How it works (high level)

The system has three parts that run together on one server:

```
   You (web browser)
        │
        ▼
   ┌─────────────┐     ┌────────────────────────┐     ┌─────────────┐
   │  Open WebUI │ ──▶ │ Clinical Notes backend │ ──▶ │   Ollama    │
   │  (chat UI)  │     │ (finds the right text, │     │ (local AI   │
   │             │ ◀── │  enforces grounding)   │ ◀── │  model, GPU)│
   └─────────────┘     └────────────────────────┘     └─────────────┘
                              │
                              ▼
                    Indexed notes (on disk)
```

- **Open WebUI** — the familiar chat interface the user types into.
- **Clinical Notes backend** — selects the right passages from the notes and makes sure every
  answer is grounded and cited.
- **Ollama** — runs the actual AI language model locally on the GPU.

Before answering, the notes are processed once (a quick "indexing" step) so the system can find
relevant passages instantly. You re-run that step whenever the notes change.

---

# Installing on a server (step by step)

These instructions set the system up on a Linux server with an NVIDIA GPU (target: NVIDIA Tesla
**T4, 16 GB**). No knowledge of the source code is required — the application is delivered as a
pre-built Docker image. Each step has a command and how to confirm it worked.

> **Time:** ~30–45 minutes, most of it waiting for model downloads.

## Step 0 — Prerequisites

You need a Linux server with:

- An **NVIDIA GPU with drivers installed.** Confirm with `nvidia-smi` (must print a table showing
  the GPU). If it doesn't, install the NVIDIA drivers first.
- **Docker Engine + the Docker Compose plugin.** Confirm with `docker --version && docker compose
  version`. If missing, install from <https://docs.docker.com/engine/install/>.
- **`curl`** (almost always preinstalled; `sudo apt-get install -y curl` on Debian/Ubuntu if not).
- A **valid HONEUR account.** The application image is hosted in the HONEUR registry; you need an
  account to download it. (Use the same credentials as for the rest of the Feder8 / HONEUR setup.)
- **Logged in to the HONEUR registry** so Docker can pull the image:
  ```bash
  docker login harbor.honeur.org
  ```
  Enter your HONEUR username and password when prompted. You only need to do this once per server.

## Step 1 — Install Ollama (the local AI engine)

Ollama runs the AI models on the GPU. Install it directly on the server:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

The application talks to Ollama over the network, so Ollama must **listen on all network
interfaces** (not just localhost). Configure that once:

```bash
sudo systemctl edit ollama
```

In the editor that opens, add these lines, then save and close:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

Apply and confirm:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
curl http://localhost:11434/api/tags        # should return JSON (a {"models":[...]} list)
```

## Step 2 — Download the AI models

Two models are needed: one that answers questions, and one that powers the note search. Pull both
(this downloads several GB — allow time):

```bash
ollama pull qwen3:8b            # answers questions (~5 GB)
ollama pull nomic-embed-text    # powers note retrieval (~0.3 GB)
ollama list                     # confirm both appear
```

Both models fit comfortably in the T4's 16 GB of GPU memory together.

## Step 3 — Get these installation files

You only need the files in the `clinical-notes-processor` folder. Download them with `curl` — no
git required:

```bash
mkdir clinical-notes-processor && cd clinical-notes-processor
base="https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/clinical-notes-processor"
for f in README.md docker-compose.yml .env.example run-evaluation.sh EVALUATION.md \
         run-loadtest.sh LOAD_TEST.md; do
  curl -fsSL "$base/$f" -o "$f"
done
chmod +x run-evaluation.sh run-loadtest.sh
```

This folder contains `docker-compose.yml`, `.env.example`, and the evaluation tools
(`run-evaluation.sh`, `EVALUATION.md`, `run-loadtest.sh`, `LOAD_TEST.md`) — everything needed to run
and validate the application. No application source code is required.

## Step 4 — Add the patient notes

Create a `notes/` folder here and place the notes inside it, **one subfolder per patient**, each
holding that patient's note file(s) (`.txt`, `.docx`, or `.pdf`):

```
clinical-notes-processor/notes/
├── Patient_A/
│   └── notes.docx
├── Patient_B/
│   ├── 2023-clinic-letter.docx
│   └── 2024-follow-up.pdf
└── ...
```

The notes stay on disk and are mounted into the application **read-only** — they are never copied
into the Docker image.

## Step 5 — Configure the application

```bash
cp .env.example .env
```

Open `.env` in a text editor and set these values:

```ini
# Point the application at the host's Ollama. On Linux, use the Docker bridge gateway IP
# (almost always 172.17.0.1 — confirm with:  ip -4 addr show docker0).
OLLAMA_HOST=http://172.17.0.1:11434

# The answering model you pulled in Step 2.
CLINICAL_OLLAMA_MODEL=qwen3:8b

# The notes folder you created in Step 4.
CLINICAL_NOTES_HOST_DIR=./notes

# A random session secret for the web UI. Generate one with:  openssl rand -hex 32
WEBUI_SECRET_KEY=paste-a-long-random-string-here
```

## Step 6 — Start the application

```bash
docker compose pull       # download the application image from harbor.honeur.org
docker compose up -d      # start both services
```

Confirm they are healthy:

```bash
docker compose ps                         # both services should show "Up (healthy)"
curl http://localhost:8000/v1/models      # should return JSON listing "clinical-notes-model"
```

## Step 7 — Process the notes (one-time, in order)

Prepare the notes for question-answering. Run these three commands **in this order**. Re-run them
whenever the notes change (see [Updating the notes](#updating-the-notes)).

```bash
# 1. Register the notes (fast)
docker compose run --rm clinical-api python -m scripts.ingest

# 2. Index them for search (a few minutes)
docker compose run --rm clinical-api python -m scripts.index

# 3. Pre-compute cohort answers (slower — needed for "how many patients…" questions)
docker compose run --rm clinical-api python -m scripts.extract
```

Each command prints a summary line on success (e.g. `ingest complete: N patients, …`).

## Step 8 — Use it

Open a web browser to:

```
http://<server-ip>:3000
```

The **first account you create becomes the administrator.** Sign up, then start a new chat — the
clinical model (`clinical-notes-model`) is already connected as the model provider. Ask questions in
plain language; answers come back with the source passages they are based on.

> Only port **3000** (the web UI) needs to be reachable by users. Port 8000 is the internal API.

---

## Validating the install (recommended)

Before relying on the system, you can run a built-in, fully synthetic check that confirms the AI
models fit in the GPU's 16 GB, that the system stays grounded (never invents facts), and how fast it
is on your hardware. It uses an isolated test record and never touches your real notes. See
**[EVALUATION.md](EVALUATION.md)**.

Once that passes, you can also check how the system behaves when **several people ask questions at
the same time** — does it just queue them up (fine), or do answers start breaking under load? This
uses a second, temporary, isolated copy of the application, so your running instance and real data
are never touched. See **[LOAD_TEST.md](LOAD_TEST.md)**.

---

## Updating the notes

When you add, remove, or change note files under `notes/`, re-process them:

```bash
docker compose run --rm clinical-api python -m scripts.ingest    # picks up new/changed files
docker compose run --rm clinical-api python -m scripts.index     # re-indexes changed notes
docker compose run --rm clinical-api python -m scripts.extract    # refreshes cohort answers
```

Unchanged files are detected and skipped automatically, so re-running is safe and quick.

## Updating to a new application version

```bash
docker compose pull        # fetch the new image
docker compose up -d       # recreate the services on it
```

If the update changes how notes are processed, also re-run the Step 7 commands.

## Operating the application

```bash
docker compose ps                      # status of both services
docker compose logs -f clinical-api    # follow the backend logs
docker compose restart                 # restart after a config (.env) change
docker compose down                    # stop everything (data is preserved on its volume)
docker compose up -d                   # start again
```

The registry and search index live on a Docker named volume (`registry-data`), so they survive
restarts. **Back this volume up** if the processed data is valuable.

## Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| `docker compose pull` fails with "unauthorized" / "denied" | Not logged in to the registry. Run `docker login harbor.honeur.org` with your HONEUR account (Step 0). |
| API can't reach the model / answers error out | `OLLAMA_HOST` in `.env` is wrong, or Ollama isn't listening on `0.0.0.0`. Re-check Step 1, and confirm `172.17.0.1` is your Docker bridge IP (`ip -4 addr show docker0`). |
| Test the connection from inside the container | Run `docker compose run --rm clinical-api python -c "import urllib.request,os; print(urllib.request.urlopen(os.environ['OLLAMA_HOST']+'/api/tags').status)"` — it should print `200`. |
| Answers are slow / GPU seems unused | Watch `nvidia-smi` while a question runs — the model should appear on the GPU. Ensure Ollama was installed natively (Step 1), not in a CPU-only container. |
| "model not found" errors | The model name in `.env` must exactly match `ollama list` (e.g. `qwen3:8b`). |
| Web UI loads but no model to pick | Confirm `curl http://localhost:8000/v1/models` returns `clinical-notes-model`; if not, check `docker compose logs clinical-api`. |
| Cohort ("how many patients…") answers look empty | Step 7's `extract` step hasn't been run, or notes changed since. Re-run it. |
