# Clinical Notes Processor — Validating the install on your server

## Why run this

Before you rely on the system in production, it is worth confirming three things **on your actual
GPU**, not just in principle:

1. **The models fit in GPU memory.** The answering model, its working memory, and the search model
   all have to share the T4's 16 GB. This check proves they do, under a realistic ~1 MB patient
   record.
2. **The system stays grounded.** It must answer *only* from the notes and say *"Not documented"*
   when a fact is absent — never invent one. This check measures exactly that.
3. **How fast it is on your hardware.** The check reports a per-stage timing breakdown so you know
   what real query latency looks like on your server.

It does this with a **built-in, fully synthetic test record** — a ~1 MB fictional patient with a
known set of planted facts (and some deliberately absent ones). **No real patient data is involved,
and your real notes and search index are never touched.** The test runs in its own isolated scratch
area.

> **The evaluation runs against the `0.2.0-rc1` candidate image automatically.** The script pins
> that image for its own steps only — it does **not** change the image your application serves via
> `docker compose up`, which stays on the stable release. Nothing to configure here. (To validate a
> different build, run `EVAL_IMAGE=<image:tag> ./run-evaluation.sh`.)

This assumes you have already completed Steps 0–6 of the [README](README.md) (Ollama installed, the
`qwen3:8b` and `nomic-embed-text` models pulled, `.env` configured). You do **not** need to have
added real notes, started the services, or run Step 7 to do this validation.

---

## Run it — one command

From this folder, run:

```bash
./run-evaluation.sh
```

The script performs every step below automatically, prints the **peak GPU memory** used during the
run (the 16 GB fit check), and ends with the result summary. It uses an isolated scratch area and
**never touches your real notes or index**. To keep the scratch data afterwards (e.g. to debug a
failure), run `KEEP_EVAL_DATA=1 ./run-evaluation.sh`.

When it finishes, interpret the summary with [How to read the result](#how-to-read-the-result).

---

## Running it manually (what the script automates)

If you would rather run the steps yourself, or need to debug, these are exactly what the script
does, in order.

## Step A — Create an isolated scratch area

Pin the candidate image for this terminal session — the script does this automatically; a manual
run needs it so the eval uses `0.2.0-rc1` and not your production image:

```bash
export CLINICAL_IMAGE=harbor.honeur.org/honeur/clinical-notes-processor:0.2.0-rc1
```

The evaluation writes a generated test corpus, a temporary index, and the gold answers into a
dedicated Docker volume, kept entirely separate from your production notes and registry. A fresh
volume is owned by root, so create it and hand it to the app user (uid 10001):

```bash
docker volume create clinical-eval-data
docker compose run --rm --user root -v clinical-eval-data:/eval clinical-api \
  sh -c 'mkdir -p /eval/notes /eval/registry /eval/recall_gold && chown -R 10001 /eval'
```

To keep the commands short, define the shared options once **in the same terminal session** you'll
use for the rest of these steps. They redirect every path the tools use into the scratch volume:

```bash
EVAL='--rm -e CLINICAL_NOTES_DIR=/eval/notes -e CLINICAL_DB_PATH=/eval/registry/registry.db -e CLINICAL_RECALL_GOLD_PATH=/eval/recall_gold/needles.csv -v clinical-eval-data:/eval'
```

(It's one long line — copy it whole. Keep it on a single line so the shell passes each option
through correctly.)

The Ollama connection and the answering model are inherited from your `.env`, so the test uses the
**same model you configured for production** — which is the whole point.

## Step B — Generate the synthetic test record

This writes the deterministic ~1 MB fictional patient and its gold answer key into the scratch
volume. It is pure generation — no GPU, no Ollama:

```bash
docker compose run $EVAL clinical-api python -m scripts.gen_recall_corpus
```

Expect a line like: `wrote /eval/notes/Synthetic_WM_1MB/note.txt (951,158 chars) and
/eval/recall_gold/needles.csv (16 needles)`.

## Step C — Index the test record

Register and index the synthetic record, exactly as the real notes are processed — but inside the
scratch area:

```bash
docker compose run $EVAL clinical-api python -m scripts.ingest
docker compose run $EVAL clinical-api python -m scripts.index
```

`index` calls the search model on the GPU; it takes a minute or two.

## Step D — Run the evaluation

In **another terminal**, watch the GPU while the evaluation runs — this is the 16 GB fit check:

```bash
watch -n 1 nvidia-smi
```

Then run the evaluation:

```bash
docker compose run $EVAL clinical-api python -m scripts.eval_recall
```

It asks the system the 16 planted questions and prints a single summary line, for example:

```python
{'needles': 16, 'recall_at_k': 0.769, 'answer_accuracy': 0.625, 'hallucination_rate': 0.0,
 'recall_by_depth': {'deep': 0.75, 'early': 0.75, 'mid': 0.8},
 'recall_by_phrasing': {'lexical': 0.778, 'paraphrase': 0.75},
 'timing': {'retrieval_s': 1.6, 'prompt_eval_s': 57.3, 'generation_s': 12.6,
            'ollama_total_s': 76.0, 'ollama_calls': 16}}
```

---

## How to read the result

| Field | Meaning | What you want to see |
|---|---|---|
| `hallucination_rate` | Of the deliberately-absent facts, the fraction the system *failed* to abstain on (i.e. made something up). | **`0.0`** — this is the most important safety check. |
| `recall_at_k` | Fraction of planted facts whose source passage the search step actually surfaced. | Close to the reference (**~0.77**). |
| `answer_accuracy` | Fraction of all questions answered correctly. | Close to the reference (**~0.63** on this deliberately hard stress-test corpus). |
| `recall_by_depth` / `recall_by_phrasing` | The same recall, split by where the fact sits in the record and by exact-wording vs. paraphrased questions. | Roughly even across buckets. |
| `timing.prompt_eval_s` | Time the GPU spent reading the retrieved note context. Normally the **largest** part of total time. | Your real latency signal on this hardware. |
| `timing.generation_s` | Time spent writing the answers. | Usually small next to prompt-eval. |
| `timing.ollama_calls` | Number of model calls (one per question). | `16`. |

**The validation passes if:**

1. **Every command completes** — no `out of memory` / CUDA errors. While it ran, `nvidia-smi` stayed
   under 16 GB. (This is the GPU-fit check.)
2. **`hallucination_rate` is `0.0`.** (Grounding holds.)
3. **`recall_at_k` and `answer_accuracy` are in the same ballpark as the reference numbers above.**
   (The model behaves on your T4 as it did in development. Exact values are deterministic for a given
   model, so small differences are fine; large drops are worth investigating.)

The `timing` block is a **measurement, not a pass/fail** — it tells you the latency to expect on your
server, dominated by `prompt_eval_s`.

## Step E — Clean up

The scratch volume is self-contained; remove it when you're done:

```bash
docker volume rm clinical-eval-data
```

Your production notes and search index are unaffected throughout — they live on different volumes
and were never written to.

---

## Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| `out of memory` / CUDA error during `index` or `eval_recall` | The two models don't fit in 16 GB together. Confirm you're using `qwen3:8b` (not a 14B model) in `.env`, and that nothing else is using the GPU (`nvidia-smi`). |
| `$EVAL: command not found` or paths look wrong | The `EVAL='...'` line wasn't set in this terminal session. Re-run Step A's `EVAL=...` block, then retry. |
| `unknown flag` / the options aren't applied | Your shell didn't expand `$EVAL`. Make sure you used single quotes exactly as shown and didn't paste it into a different shell. |
| `eval_recall` errors that the gold file or patient is missing | Steps B and C weren't run against the same scratch volume. Re-run B → C → D in order, all with `$EVAL` set. |
| Answers all come back "Not documented" | The index step didn't finish, or Ollama isn't reachable. Re-run Step C and confirm `OLLAMA_HOST` per the README. |

> **Note (developers):** there is a second, broader evaluation (`scripts.eval_cohort`) that measures
> cohort-question accuracy (precision/recall/F1). It depends on a labelled development sample set that
> is **not** shipped in this install package, so it is run from a source checkout, not on the
> production server. The recall evaluation above is the server-side go-live check.
