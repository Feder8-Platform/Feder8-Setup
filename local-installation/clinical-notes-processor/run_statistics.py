"""Run statistics for reporting: the notes, the specialist-visit extraction output, and
how long the extraction took. Counts and distributions only -- no patient identifiers,
note text or quotes are printed. Read-only; makes no model calls.

Run it with ./run-statistics.sh (which feeds this file into the application container);
see EXTRACTION.md, "Run statistics".

Sections:
  1. Software and model  -- application version, Ollama version, model size/quantisation.
  2. Notes               -- files, characters and estimated tokens per patient; passages.
  3. Extraction output   -- visits per patient, dated share, specialties.
  4. Extraction time     -- estimated from the per-patient completion times stored in
                            the database; exact when an extraction log is supplied.
"""

import base64
import json
import os
import re
import sqlite3
import statistics
import sys
import urllib.error
import urllib.request
from datetime import datetime

DB = os.environ.get("CLINICAL_DB_PATH", "/data/registry/registry.db")
MODEL = os.environ.get("CLINICAL_OLLAMA_MODEL", "qwen3:8b")
OLLAMA = os.environ.get("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
TOKEN_BUDGET = 8000  # tokens; a note up to TOKEN_BUDGET * 4 characters is sent whole
PASSAGE_CHARS = 2000
# Characters per Qwen3 token, measured with the Qwen3 tokenizer on synthetic notes
# (3.39 on short notes, 3.02 on a ~1 MB record); the application's own chars/4 rule
# undercounts real tokens.
CHARS_PER_TOKEN_LOW, CHARS_PER_TOKEN_HIGH = 3.0, 3.4
# Gap between two consecutive patient completions above which they are treated as
# separate extraction runs.
RUN_GAP_HOURS = 6
LOG_TEXT = base64.b64decode(globals().get("LOG_B64", "")).decode("utf-8", "replace")


def section(title):
    print(f"\n== {title}")


def summary(label, values, unit=""):
    if not values:
        print(f"{label}: none")
        return
    v = sorted(values)
    q1, med, q3 = statistics.quantiles(v, n=4, method="inclusive") if len(v) > 1 else (v[0],) * 3
    print(
        f"{label}: total {sum(v):.0f}{unit} | median {med:.0f}{unit} (IQR {q1:.0f}-{q3:.0f}) "
        f"| mean {statistics.mean(v):.0f}{unit} | min {v[0]:.0f}{unit} | max {v[-1]:.0f}{unit}"
    )


def hms(seconds):
    seconds = int(round(seconds))
    return f"{seconds // 3600}h {seconds % 3600 // 60:02d}m {seconds % 60:02d}s"


def ollama_get(path, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(
        OLLAMA + path, data=data, headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read())


# ---- 1. Software and model -------------------------------------------------------------
section("1. Software and model")
try:
    import tomllib

    with open("/app/pyproject.toml", "rb") as f:
        print(f"application version: {tomllib.load(f)['project']['version']}")
except Exception as exc:
    print(f"application version: unknown ({exc.__class__.__name__})")
print(f"configured model: {MODEL}")


def ollama_info(label, path, payload, fmt):
    try:
        print(f"{label}: {fmt(ollama_get(path, payload))}")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", "replace")[:200]
        print(f"{label}: not available (Ollama HTTP {exc.code}: {body})")
    except Exception as exc:
        print(f"{label}: not available (Ollama at {OLLAMA}: {exc.__class__.__name__})")


def _details(r):
    d = r.get("details", {})
    return (
        f"family {d.get('family')}, parameters {d.get('parameter_size')}, "
        f"quantisation {d.get('quantization_level')}, format {d.get('format')}"
    )


def _digest(r):
    for m in r.get("models", []):
        if MODEL in (m.get("name"), m.get("model")):
            return m.get("digest")
    return f"{MODEL} not found in the Ollama model list"


ollama_info("Ollama version", "/api/version", None, lambda r: r.get("version"))
ollama_info("model details", "/api/show", {"model": MODEL}, _details)
ollama_info("model digest", "/api/tags", None, _digest)

con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
notes = con.execute("SELECT patient_id, text FROM notes").fetchall()
patients = sorted({p for p, _ in notes})
chars_by_patient = dict.fromkeys(patients, 0)

# ---- 2. Notes -------------------------------------------------------------------------
section("2. Notes")
try:
    from variables.specialty_date_extraction import _passages_for_note
    from variables.specialty_terms import SPECIALTY_TERMS, mentions_specialty
except ImportError:
    _passages_for_note = None
print(f"patients with notes: {len(patients)}")
print(f"note files: {len(notes)}")
per = {p: {"files": 0, "passages": 0, "screened_in": 0} for p in patients}
whole, passage_lengths = 0, []
for pid, text in notes:
    per[pid]["files"] += 1
    chars_by_patient[pid] += len(text)
    if _passages_for_note is None:
        continue
    if len(text) <= TOKEN_BUDGET * 4:
        passages = [text] if text.strip() else []
        whole += 1
    else:
        passages = _passages_for_note(text, max_chars=PASSAGE_CHARS)
    per[pid]["passages"] += len(passages)
    passage_lengths += [len(p) for p in passages]
    per[pid]["screened_in"] += sum(
        1 for p in passages if any(mentions_specialty(v, p) for v in SPECIALTY_TERMS)
    )
chars = list(chars_by_patient.values())
summary("note files per patient", [s["files"] for s in per.values()])
summary("characters per patient", chars)
summary("application's own token estimate per patient (chars/4)", [c / 4 for c in chars])
summary(
    f"est. Qwen3 tokens per patient, lower bound (chars/{CHARS_PER_TOKEN_HIGH})",
    [c / CHARS_PER_TOKEN_HIGH for c in chars],
)
summary(
    f"est. Qwen3 tokens per patient, upper bound (chars/{CHARS_PER_TOKEN_LOW})",
    [c / CHARS_PER_TOKEN_LOW for c in chars],
)
if _passages_for_note is None:
    print("passage statistics skipped: this application version has no passage function")
else:
    print(f"note files sent whole (<= {TOKEN_BUDGET * 4} characters): {whole}")
    summary("passages per patient", [s["passages"] for s in per.values()])
    summary("characters per passage", passage_lengths)
    summary("passages naming a specialty term", [s["screened_in"] for s in per.values()])
    total_p = sum(s["passages"] for s in per.values())
    total_in = sum(s["screened_in"] for s in per.values())
    if total_p:
        print(f"share of passages passing the keyword screen: {total_in / total_p:.1%}")

# ---- 3. Extraction output -------------------------------------------------------------
section("3. Extraction output (specialist visits)")
enc = con.execute(
    "SELECT patient_id, specialty, date_documented, date_iso, model FROM specialty_encounters"
).fetchall()
counts = dict.fromkeys(patients, 0)
for row in enc:
    counts[row[0]] = counts.get(row[0], 0) + 1
print(f"extracted visits: {len(enc)}")
summary("visits per patient", list(counts.values()))
print(f"patients with >= 1 visit: {sum(1 for c in counts.values() if c)}")
if enc:
    iso = sum(1 for r in enc if r[3])
    written_only = sum(1 for r in enc if r[2] and not r[3])
    print(f"visits with a standardised date: {iso} ({iso / len(enc):.1%})")
    print(f"visits with a written date that could not be standardised: {written_only}")
    print(f"visits without a date: {len(enc) - iso - written_only}")
    print(f"distinct specialties with >= 1 visit: {len({r[1] for r in enc})}")
    print(f"model per row: {sorted({(r[4], sum(1 for x in enc if x[4] == r[4])) for r in enc})}")
meta = con.execute(
    "SELECT patient_id, extracted_at FROM specialty_encounters_meta ORDER BY extracted_at"
).fetchall()
print(f"patients with a completed visit extraction: {len(meta)} of {len(patients)}")


# ---- 4. Extraction time ---------------------------------------------------------------
def parse_ts(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def last_run(rows):
    """The most recent block of (patient, completion time) rows without a gap longer than
    RUN_GAP_HOURS -- one extraction run -- and the number of blocks found."""
    blocks, current, prev = [], [], None
    for pid, ts in rows:
        t = parse_ts(ts)
        if prev is not None and (t - prev).total_seconds() > RUN_GAP_HOURS * 3600:
            blocks.append(current)
            current = []
        current.append((pid, t))
        prev = t
    if current:
        blocks.append(current)
    return (blocks[-1] if blocks else []), len(blocks)


section("4. Extraction time")
print(
    "Estimated from the time each patient's visit extraction finished (stored in the "
    "database). Patients are processed one after another, so the time between two "
    "consecutive completions is the second patient's processing time. The first "
    "patient's time is not stored; it is estimated as the median of the others."
)
run, n_runs = last_run(meta)
if len(run) < 2:
    print("not enough completed patients in one run to estimate timing")
else:
    durations = [(b[1] - a[1]).total_seconds() for a, b in zip(run, run[1:])]
    span = (run[-1][1] - run[0][1]).total_seconds()
    est_total = span + statistics.median(durations)
    print(f"extraction runs found in the database: {n_runs} (gap > {RUN_GAP_HOURS} h = new run)")
    print(
        f"most recent run: {len(run)} patients, first completion {run[0][1]:%Y-%m-%d %H:%M}, "
        f"last completion {run[-1][1]:%Y-%m-%d %H:%M} (UTC)"
    )
    if len(run) < len(patients):
        print(
            f"note: {len(patients) - len(run)} patient(s) were last processed in another run "
            f"(earlier run, retry after a failure, or skipped as already current)"
        )
    print(f"time from first to last completion: {hms(span)}")
    print(f"estimated total visit-extraction time (incl. first patient): {hms(est_total)}")
    summary("time per patient (seconds)", durations, unit="s")
    sized = [(d, chars_by_patient.get(b[0], 0)) for d, (_, b) in zip(durations, zip(run, run[1:]))]
    total_chars = sum(c for _, c in sized)
    if total_chars:
        rate = sum(d for d, _ in sized) / total_chars * 100000
        print(f"processing rate: {rate:.0f} s per 100000 characters of notes")

if LOG_TEXT:
    section("4b. Extraction time from the extraction log (exact)")
    ts_re = re.compile(r"^(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)")
    lines = [ln for ln in LOG_TEXT.splitlines() if ts_re.match(ln)]
    # One run per "extraction complete:" line; analyse the last complete run.
    ends = [i for i, ln in enumerate(lines) if "extraction complete:" in ln]
    if ends:
        start_idx = ends[-2] + 1 if len(ends) > 1 else 0
        lines = lines[start_idx : ends[-1] + 1]
    print(f"extraction runs in the log: {len(ends)} (analysing the last one)")
    if not lines:
        print("no timestamped log lines found")
    else:
        t = lambda ln: datetime.strptime(ts_re.match(ln).group(1), "%Y-%m-%d %H:%M:%S")  # noqa: E731
        print(f"whole command: {hms((t(lines[-1]) - t(lines[0])).total_seconds())}")
        key_re = re.compile(r"\[(\d+)/(\d+)\] .*?: (starting|complete|FAILED|skipped)")
        started, done, durations, passages = {}, 0, [], []
        failed = skipped = 0
        for ln in lines:
            m = key_re.search(ln)
            if not m or "specialty_date_extraction" not in ln:
                continue
            idx, kind = m.group(1), m.group(3)
            if kind == "starting":
                started[idx] = t(ln)
                p = re.search(r"\((\d+) passage", ln)
                if p:
                    passages.append(int(p.group(1)))
            elif kind == "complete" and idx in started:
                durations.append((t(ln) - started[idx]).total_seconds())
                done += 1
            elif kind == "FAILED":
                failed += 1
            elif kind == "skipped":
                skipped += 1
        spec_lines = [ln for ln in lines if "specialty_date_extraction" in ln and key_re.search(ln)]
        if spec_lines:
            print(
                "visit extraction (first patient start to last patient end): "
                f"{hms((t(spec_lines[-1]) - t(spec_lines[0])).total_seconds())}"
            )
        print(
            f"patients completed: {done}, failed: {failed}, skipped as already current: {skipped}"
        )
        summary("time per patient (seconds)", durations, unit="s")
        summary("passages processed per patient", passages)
        repeats = [
            int(m.group(1))
            for m in re.finditer(r"(\d+) undated passage\(s\) repeating", "\n".join(lines))
        ]
        print(f"undated repeated passages skipped: {sum(repeats)}")
        splits = sum(1 for ln in lines if "reply truncated; splitting" in ln)
        print(f"over-long model replies split and retried: {splits}")
else:
    print(
        "\n(no extraction log supplied; pass the saved console output of the extraction "
        "run to ./run-statistics.sh for exact times)"
    )
print()
sys.stdout.flush()
