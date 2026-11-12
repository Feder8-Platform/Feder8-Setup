#!/usr/bin/env bash
#
# Archive the current OMOP CDM schema and start from a fresh one.
#
#   1. Rename the existing omopcdm schema to omopcdm_<source_release_date>
#      (date taken from omopcdm.cdm_source.source_release_date, YYYYMMDD)
#   2. Create a new, empty omopcdm schema with the same CDM version (5.3.1 or 5.4)
#      owned by ohdsi_admin, with read access for ohdsi_app
#   3. Add base primary keys, base constraints and base indexes
#   4. Load the vocabulary via start-vocabulary-update.sh
#
# Run this script from the folder where you normally run the Feder8 scripts
# (the folder containing info_feder8_installation).
#
# REGISTRY and REPOSITORY can be overridden for other therapeutic areas, e.g.
#   REGISTRY=harbor.lupusnet.org REPOSITORY=lupus ./rotate-omopcdm-schema.sh
set -euo pipefail

REGISTRY=${REGISTRY:-harbor.honeur.org}
REPOSITORY=${REPOSITORY:-honeur}
CDM_SCHEMA=omopcdm
FEDER8_ADMIN_USERNAME=feder8_admin
OWNER_ROLE=ohdsi_admin
READ_ROLE=ohdsi_app

INIT_SCHEMA_IMAGE=$REGISTRY/$REPOSITORY/postgres-omopcdm-initialize-schema:2.0.3
BASE_PK_IMAGE=$REGISTRY/$REPOSITORY/postgres-omopcdm-add-base-primary-keys:2.0.3
BASE_CONSTRAINTS_IMAGE=$REGISTRY/$REPOSITORY/postgres-omopcdm-add-base-constraints:1.0
BASE_INDEXES_IMAGE=$REGISTRY/$REPOSITORY/postgres-omopcdm-add-base-indexes:2.0.2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOCABULARY_UPDATE_SCRIPT="$SCRIPT_DIR/start-vocabulary-update.sh"

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

# Run a query and return the bare result (no headers, no alignment)
query() {
    docker exec postgres psql -U postgres -d OHDSI -v ON_ERROR_STOP=1 -tAc "$1"
}

run_sql() {
    docker exec -i postgres psql -U postgres -d OHDSI -v ON_ERROR_STOP=1 -q
}

run_pipeline_image() {
    local name=$1 image=$2
    docker run --rm --name "$name" \
        -v shared:/var/lib/shared \
        --env DB_HOST=postgres \
        --env DB_OMOPCDM_SCHEMA=$CDM_SCHEMA \
        --env CDM_VERSION="$CDM_VERSION" \
        --env FEDER8_ADMIN_USERNAME=$FEDER8_ADMIN_USERNAME \
        --network feder8-net \
        "$image"
}

# ---------------------------------------------------------------------------
# Pre-checks
# ---------------------------------------------------------------------------
echo "Checking prerequisites..."

[[ -f "$VOCABULARY_UPDATE_SCRIPT" ]] \
    || fail "start-vocabulary-update.sh not found next to this script ($SCRIPT_DIR)."

docker ps --format '{{.Names}}' | grep -qx postgres \
    || fail "The postgres container is not running. Start the Feder8 local installation first."

[[ "$(query "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '$CDM_SCHEMA' AND table_name = 'concept')")" == "t" ]] \
    || fail "Schema '$CDM_SCHEMA' does not exist or is not an OMOP CDM schema."

[[ "$(query "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '$CDM_SCHEMA' AND table_name = 'cdm_source')")" == "t" ]] \
    || fail "Table $CDM_SCHEMA.cdm_source does not exist."

RELEASE_DATE=$(query "SELECT to_char(max(source_release_date), 'YYYYMMDD') FROM $CDM_SCHEMA.cdm_source")
[[ "$RELEASE_DATE" =~ ^[0-9]{8}$ ]] \
    || fail "No source_release_date found in $CDM_SCHEMA.cdm_source. Fill in cdm_source before running this script."

ARCHIVE_SCHEMA="${CDM_SCHEMA}_${RELEASE_DATE}"
[[ "$(query "SELECT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = '$ARCHIVE_SCHEMA')")" == "f" ]] \
    || fail "Schema '$ARCHIVE_SCHEMA' already exists. This release has already been archived."

if [[ "$(query "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '$CDM_SCHEMA' AND table_name = 'episode')")" == "t" ]]; then
    CDM_VERSION=5.4
else
    CDM_VERSION=5.3.1
fi

# ---------------------------------------------------------------------------
# Confirmation
# ---------------------------------------------------------------------------
cat <<EOF

This script will:
  1. Rename schema '$CDM_SCHEMA' to '$ARCHIVE_SCHEMA'
  2. Create a new, EMPTY '$CDM_SCHEMA' schema (OMOP CDM v$CDM_VERSION)
     owned by $OWNER_ROLE, readable by $READ_ROLE
  3. Add base primary keys, base constraints and base indexes
  4. Load the vocabulary into the new '$CDM_SCHEMA' schema

After this, the new '$CDM_SCHEMA' schema contains only vocabulary tables.
Your clinical data stays available in '$ARCHIVE_SCHEMA'.
You will need to run your ETL again to load data into '$CDM_SCHEMA'.

EOF
read -rp "Do you want to continue? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[yY]([eE][sS])?$ ]] || { echo "Aborted. Nothing was changed."; exit 0; }

# ---------------------------------------------------------------------------
# Pull images before changing anything
# ---------------------------------------------------------------------------
echo "Logging in to $REGISTRY..."
docker login "$REGISTRY"

echo "Pulling images..."
for image in "$INIT_SCHEMA_IMAGE" "$BASE_PK_IMAGE" "$BASE_CONSTRAINTS_IMAGE" "$BASE_INDEXES_IMAGE"; do
    docker pull "$image"
done

# ---------------------------------------------------------------------------
# From here on the database is changed. If a step fails, explain how to roll back.
# ---------------------------------------------------------------------------
on_error() {
    cat >&2 <<EOF

ERROR: the schema rotation failed. Your original data is still in '$ARCHIVE_SCHEMA'.
To restore the previous situation, run:

  docker exec -it postgres psql -U postgres -d OHDSI -c "DROP SCHEMA IF EXISTS $CDM_SCHEMA CASCADE; ALTER SCHEMA $ARCHIVE_SCHEMA RENAME TO $CDM_SCHEMA;"

EOF
}

echo "Renaming schema '$CDM_SCHEMA' to '$ARCHIVE_SCHEMA'..."
query "ALTER SCHEMA $CDM_SCHEMA RENAME TO $ARCHIVE_SCHEMA" > /dev/null
trap on_error ERR

echo "Initializing new '$CDM_SCHEMA' schema (OMOP CDM v$CDM_VERSION)..."
run_pipeline_image omopcdm-initialize-schema "$INIT_SCHEMA_IMAGE"

echo "Setting owner $OWNER_ROLE and read access for $READ_ROLE on '$CDM_SCHEMA'..."
run_sql <<SQL
ALTER SCHEMA $CDM_SCHEMA OWNER TO $OWNER_ROLE;
DO \$\$
DECLARE
    obj record;
BEGIN
    FOR obj IN
        SELECT c.relname, c.relkind
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = '$CDM_SCHEMA'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S')
          -- sequences linked to a column follow their table's owner automatically
          AND NOT (c.relkind = 'S' AND EXISTS (
                SELECT 1 FROM pg_depend d
                WHERE d.classid = 'pg_class'::regclass AND d.objid = c.oid AND d.deptype IN ('a', 'i')))
    LOOP
        IF obj.relkind = 'S' THEN
            EXECUTE format('ALTER SEQUENCE %I.%I OWNER TO %I', '$CDM_SCHEMA', obj.relname, '$OWNER_ROLE');
        ELSIF obj.relkind = 'v' THEN
            EXECUTE format('ALTER VIEW %I.%I OWNER TO %I', '$CDM_SCHEMA', obj.relname, '$OWNER_ROLE');
        ELSIF obj.relkind = 'm' THEN
            EXECUTE format('ALTER MATERIALIZED VIEW %I.%I OWNER TO %I', '$CDM_SCHEMA', obj.relname, '$OWNER_ROLE');
        ELSE
            EXECUTE format('ALTER TABLE %I.%I OWNER TO %I', '$CDM_SCHEMA', obj.relname, '$OWNER_ROLE');
        END IF;
    END LOOP;
END
\$\$;
GRANT USAGE ON SCHEMA $CDM_SCHEMA TO $READ_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA $CDM_SCHEMA TO $READ_ROLE;
ALTER DEFAULT PRIVILEGES FOR ROLE $OWNER_ROLE IN SCHEMA $CDM_SCHEMA GRANT SELECT ON TABLES TO $READ_ROLE;
SQL

echo "Adding base primary keys to '$CDM_SCHEMA'..."
run_pipeline_image omopcdm-add-base-primary-keys "$BASE_PK_IMAGE"

echo "Adding base constraints to '$CDM_SCHEMA'..."
run_pipeline_image omopcdm-add-base-constraints "$BASE_CONSTRAINTS_IMAGE"

echo "Adding base indexes to '$CDM_SCHEMA'..."
run_pipeline_image omopcdm-add-base-indexes "$BASE_INDEXES_IMAGE"

trap - ERR

# ---------------------------------------------------------------------------
# Vocabulary update
# ---------------------------------------------------------------------------
cat <<EOF

=============================================================================
 The new '$CDM_SCHEMA' schema is ready. Next: loading the vocabulary.

 The vocabulary update will now ask you a few questions:

   * "Please enter your database password for feder8_admin"
       -> enter the feder8_admin database password (only asked if needed)

   * "In which schema you want to apply the pipeline?"
       -> type:  $CDM_SCHEMA
          (newer versions already show '$CDM_SCHEMA' as default: just press Enter)

   Do NOT enter '$ARCHIVE_SCHEMA' here: that is your archived schema.
=============================================================================

EOF
read -rp "Press Enter to start the vocabulary update..." _

if ! bash "$VOCABULARY_UPDATE_SCRIPT"; then
    cat >&2 <<EOF

ERROR: the vocabulary update failed. The new '$CDM_SCHEMA' schema exists but has no
(complete) vocabulary yet. Fix the problem and run start-vocabulary-update.sh again,
entering '$CDM_SCHEMA' as schema.
EOF
    exit 1
fi

cat <<EOF

Done.
  * Archived schema:  $ARCHIVE_SCHEMA (OMOP CDM v$CDM_VERSION, original data)
  * New schema:       $CDM_SCHEMA (OMOP CDM v$CDM_VERSION, vocabulary only)

Next step: run your ETL to load your data into '$CDM_SCHEMA'.
EOF
