# Importing externally-sourced variables

Some variables shouldn't come from LLM extraction over the notes at all — either
because the notes don't reliably document them, or because an authoritative source
already exists elsewhere (e.g. a trial database). `scripts.import_external_variables`
loads such a variable from a CSV export into its own SQLite table,
`external_variables`, so you can query it directly alongside — but separately from —
the LLM-extracted `patient_variables` table.

This does **not** change what the LLM-extracted variable of the same name (if any)
returns in Open WebUI or the cohort/router paths — it only gives you a second,
independently-sourced table to query by SQL. Run it against your real application
data, from this folder (`docker-compose.yml` must be present).

> **Note:** this script ships from the clinical-notes-processor release that added it
> — if `docker compose run --rm clinical-api python -m scripts.import_external_variables --help`
> fails with "No module named scripts.import_external_variables", your installed image
> predates this feature; update first (see `UPDATING.md`).

## CSV format

- Must have a column named exactly `patient_id`.
- Must have **exactly one** other column. Its header can be anything (it's for your
  own readability only — the script imports its values regardless of what the column
  is called) — naming it after the variable (e.g. `dara_start_date`) is recommended.
- Every value in that second column **must already be an ISO-8601 date**
  (`YYYY-MM-DD`). Any row that isn't gets rejected and reported, not imported. Other
  value types (free text, numbers, non-ISO date formats) are not currently supported
  — every import through this script is validated as a date.

Example CSV, `dara_dates.csv`:

```csv
patient_id,dara_start_date
Patient_1,2021-11-03
Patient_2,2022-03-17
Patient_3,2020-07-01
```

## Running the import

```bash
docker compose run --rm clinical-api python -m scripts.import_external_variables \
  --csv /data/dara_dates.csv \
  --variable-name dara_start_date
```

- `--csv PATH` — the CSV file to import. Since this runs inside the container, the
  path must be one the container can see — either bind-mount the file's folder into
  the container first, or copy the CSV into a folder already mounted (e.g. your
  `notes/` folder's parent, if mounted — check `docker-compose.yml` for what's
  mounted where). The simplest approach on a normal install is to drop the CSV next
  to this folder's `docker-compose.yml` and mount it, or copy it into the container:

  ```bash
  docker compose cp dara_dates.csv clinical-api:/tmp/dara_dates.csv
  docker compose run --rm clinical-api python -m scripts.import_external_variables \
    --csv /tmp/dara_dates.csv --variable-name dara_start_date
  ```

- `--variable-name NAME` — what to call this variable in the `external_variables`
  table's `variable_name` column. Use the same name you'd use to refer to it in
  `variables.yaml` (e.g. `dara_start_date`) so it's unambiguous which variable this
  is an external, authoritative version of.
- `--db-path PATH` (optional) — overrides the app's configured database path. Not
  needed for a normal run against your real installation; the default already points
  at your running application's database.

Output reports how many rows were imported vs. rejected, and lists the rejected
rows (patient id + the bad value) so you can fix the source export:

```
imported=48 rejected=2
rejected rows:
  Patient_17 ('March 2023')
  Patient_44 ('')
```

Re-running the import (e.g. with a corrected export) **fully replaces** every row
for that `--variable-name` — safe to re-run as often as you get a fresh export; it
never leaves stale rows behind from a previous import.

## Example: dara_start_date

The LLM-extracted `dara_start_date` (from `patient_variables`, via note extraction)
isn't reliable enough to trust for cohort queries — dates are sometimes phrased in a
way the model doesn't extract correctly. If your site has an authoritative
`dara_start_date` per patient in an external trial database, export it to CSV as
shown above and import it as `dara_start_date` into `external_variables`.

Query it directly instead of `patient_variables`:

```sql
SELECT patient_id, value AS dara_start_date
FROM external_variables
WHERE variable_name = 'dara_start_date'
ORDER BY patient_id;
```

Combine with other cohort data, e.g. specialties seen per patient:

```sql
SELECT e.patient_id, e.value AS dara_start_date, sv.value AS seen_by_hematology
FROM external_variables e
LEFT JOIN patient_variables sv
  ON sv.patient_id = e.patient_id AND sv.variable_name = 'seen_by_hematology'
WHERE e.variable_name = 'dara_start_date';
```
