#!/bin/sh
# Start marimo in edit mode, behind a password, with its notebooks on the volume.
set -eu

if [ -z "${MARIMO_PASSWORD:-}" ]; then
  echo "MARIMO_PASSWORD is empty: refusing to start marimo without a login." >&2
  exit 1
fi

DATA="${MARIMO_DATA_DIR:-/data}"
NOTEBOOKS="${MARIMO_NOTEBOOK_DIR:-$DATA/notebooks}"
mkdir -p "$NOTEBOOKS" "$DATA/.config" "$DATA/.packages" "$DATA/.local/state"

# First boot: copy marimo's bundled tutorials so the file browser isn't empty.
if [ ! -e "$DATA/.seeded" ]; then
  if [ -d /app/tutorials ] && [ ! -e "$NOTEBOOKS/tutorials" ]; then
    cp -r /app/tutorials "$NOTEBOOKS/tutorials"
  fi
  touch "$DATA/.seeded"
fi

# Pass the password through a private file, not the process list.
PWFILE="$(mktemp /tmp/marimo-pw.XXXXXX)"
chmod 600 "$PWFILE"
printf '%s' "$MARIMO_PASSWORD" > "$PWFILE"

cd "$NOTEBOOKS"
# exec: marimo is PID 1's only child of interest; if it dies (crash, OOM kill)
# the container exits non-zero and Railway's ON_FAILURE policy restarts it.
# --quiet: marimo's startup banner prints the URL with the password as
# ?access_token=..., which would end up in Railway's deploy logs.
echo "Starting marimo on port ${PORT:-8080} (notebooks in $NOTEBOOKS)"
exec marimo --quiet edit "$NOTEBOOKS" \
  --host "${HOST:-0.0.0.0}" \
  --port "${PORT:-8080}" \
  --headless \
  --skip-update-check \
  --token-password-file "$PWFILE"
