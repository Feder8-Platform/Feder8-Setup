# Clinical Notes Processor — testing concurrent use on your server

## Why run this

**[EVALUATION.md](EVALUATION.md)** confirms the models fit your GPU and answer correctly for one
question at a time. This check goes a step further: **what happens when several people ask
questions at the same time?** On a single GPU, the AI model can only process one request at a
moment — the question is whether concurrent users simply queue behind each other (fine, just
slower) or whether something worse happens under load (errors, or an answer quietly turning
incorrect).

It does this with the **same built-in synthetic test record** as `run-evaluation.sh` — no real
patient data is involved. Unlike the evaluation, it does not test your running application
directly; it starts a **second, temporary, fully isolated copy** of it on a different port, so your
real notes, search index, and the application your users are connected to are never touched or
interrupted.

> This is a heavier check than `run-evaluation.sh` — it runs the ~16-question test **several times
> concurrently**, so expect it to take a few minutes longer, scaling with how much load you ask for.

This assumes you have already completed Steps 0–6 of the [README](README.md). You do **not** need
real notes added, or the application started, to run this.

---

## Run it — one command

From this folder:

```bash
./run-loadtest.sh
```

By default this simulates **2 concurrent users**, each asking through the full 16-question set
**twice** (2 rounds). Tune it:

```bash
CONCURRENCY=4 ROUNDS=3 ./run-loadtest.sh
```

Start small (`CONCURRENCY=2`) before pushing higher — each question already takes several seconds
to tens of seconds on its own, so concurrency multiplies wall-clock time, not GPU load.

The script prints a summary line when it finishes, for example:

```python
{'requests': 32, 'concurrency': 2, 'wall_s': 131.4, 'errors': 0, 'accuracy': 0.75,
 'hallucination_rate': 0.0, 'latency_s': {'mean': 8.2, 'median': 9.9, 'max': 15.3}}
```

To keep the scratch volume afterwards (e.g. to debug a failure), run `KEEP_EVAL_DATA=1
./run-loadtest.sh`.

---

## How to read the result

| Field | Meaning | What you want to see |
|---|---|---|
| `errors` | Requests that failed or timed out. | **`0`**. |
| `hallucination_rate` | Same measure as `EVALUATION.md` — did any deliberately-absent fact get invented under load. | **`0.0`** — this is the most important safety check. |
| `accuracy` | Fraction of the 16 questions answered correctly, across every concurrent/repeated call. | Close to the reference from `EVALUATION.md` (**~0.88**). A drop here, with `errors: 0`, would mean answers are flipping under load rather than failing loudly. |
| `latency_s.mean` / `median` / `max` | Real per-question wall-clock time while `CONCURRENCY` questions were in flight together. | This is your **throughput signal**, not pass/fail. Expect it to be noticeably higher than a single question in isolation (the GPU is serializing the concurrent requests) — that's normal. A number that keeps climbing far beyond a roughly linear multiple of the single-question latency is worth investigating. |
| any listed "answered incorrectly under load" / "hallucination(s) under load" | The specific questions affected. | Compare against `EVALUATION.md`'s run: if the **same** questions are wrong both times, that's the known baseline, not a new problem. If **different or additional** questions are wrong only under concurrency, that is a load-specific issue worth reporting. |

**The check passes if:**

1. **`errors` is `0`** — the server stayed up and responsive throughout.
2. **`hallucination_rate` is `0.0`.**
3. **`accuracy` stays near the `EVALUATION.md` reference (~0.88)** and the same questions are wrong
   as in the single-question evaluation — nothing new breaks specifically under concurrent load.

If any of these fail, latency and stability under real multi-user traffic are not yet acceptable
for production — see the Troubleshooting section below before going live.

---

## What it's doing, if you want the detail

1. Generates the same ~1 MB synthetic patient as `run-evaluation.sh`, into its own scratch volume
   (`clinical-loadtest-data`) — completely separate from `run-evaluation.sh`'s own scratch volume
   and from your production data.
2. Starts a **second container** running the application against that scratch data, published on
   `localhost:8001` (not your production port 8000) — your `docker compose up` application, if
   running, is left alone and keeps serving your real users on port 8000 throughout.
3. Fires the same 16 questions as the evaluation at that second container, `CONCURRENCY` at a time,
   for `ROUNDS` full passes, over real HTTP — exactly how multiple simultaneous Open WebUI users
   would hit your production instance.
4. Stops the temporary container and removes the scratch volume when done (unless
   `KEEP_EVAL_DATA=1`).

## Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| `ERROR: ... does not include scripts.load_test_concurrency` | The pinned `CLINICAL_IMAGE` predates this tool. Point `EVAL_IMAGE=` at a newer build and retry. |
| `ERROR: temporary instance did not become ready on port 8001` | Something else is already using port 8001 on this machine, or the container failed to start — check `docker logs clinical-loadtest` (it may still be running if the script exited before cleanup) and `docker ps -a`. Change the port with `LOADTEST_PORT=8002 ./run-loadtest.sh`. |
| Latency scales far worse than linearly with `CONCURRENCY`, or requests time out | Expected up to a point — Ollama processes one request at a time on a single GPU, so `N` concurrent users roughly means `N`× the single-question latency, not more. Sharp blow-ups beyond that suggest the GPU is also serving other load, or `CONCURRENCY`/`ROUNDS` are set higher than this hardware can sustain — dial them back. |
| Errors mentioning "Ollama is unreachable" | Confirm `OLLAMA_HOST` in `.env` is reachable from a container (see README Step 1), and that nothing else pinned all of Ollama's resources during the test. |

Your production notes, index, and running application are unaffected throughout — the temporary
instance runs on its own scratch volume and port, and is removed when the script exits.
