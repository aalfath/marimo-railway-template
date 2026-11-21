[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/marimo?utm_medium=integration&utm_source=button&utm_campaign=marimo)

# marimo on Railway

One-click [marimo](https://github.com/marimo-team/marimo) on Railway, built from this repo. marimo is a reactive Python notebook: when you run a cell or move a slider, every cell that depends on it runs again, so code and outputs never drift apart. Notebooks are plain `.py` files that also run as scripts or as interactive web apps.

## What the template deploys

| Service | Source | What it does |
|---|---|---|
| **marimo** | this repo (`Dockerfile`) | marimo's notebook editor (`marimo edit`) on `PORT` 8080, behind marimo's own password login. Volume at `/data` for notebooks, settings and packages you install from the UI. Health check `/healthz` (no login). |

- Version: marimo **0.25.2**, official image `ghcr.io/marimo-team/marimo:0.25.2-sql@sha256:f154a40fba17cda7581edd3a3ef6c371d46c69a0e45dcd825293554e5d62e4c6` (the `-sql` variant: pandas, NumPy, Altair, Polars and DuckDB are preinstalled, so SQL cells work at once).
- Memory: about 150 MB at rest; each open notebook starts its own Python kernel, which needs more for large data. It runs on Railway's 0.5 GB / 1 vCPU per-service limit for light work; give it 1 GB or more for real data sets.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `PORT` | `8080` | Port marimo listens on. Keep it equal to the domain's target port. |
| `MARIMO_PASSWORD` | `${{secret(24,…)}}` | Login password, generated at deploy. marimo refuses to start without it. |

Optional service variables you can add: `MARIMO_NOTEBOOK_DIR` (default `/data/notebooks`) and API keys for marimo's AI assistant (set them in marimo's settings screen instead, which stores them on the volume).

## After deploy

1. Open the service's Railway domain. marimo shows a login page: paste `MARIMO_PASSWORD` from the **marimo** service's **Variables** tab.
2. The file browser opens on `/data/notebooks`. Create a notebook, or start with the bundled `tutorials` folder (copied on first boot; delete it if you don't need it).
3. Install extra packages from marimo's package panel (or when a cell imports a missing module). They go to `/data/.packages` on the volume, so they survive redeploys.

To change the password, edit `MARIMO_PASSWORD` and redeploy.

## Data and persistence

Everything lives on the volume at `/data`:

- `/data/notebooks`: your notebooks (`.py` files) and anything they write next to them.
- `/data/.config/marimo`: marimo's settings (`marimo.toml`), including AI provider keys you enter in the UI.
- `/data/.packages`: packages installed from the UI. They are added to Python's path *after* the image's own packages, so the bundled marimo version always wins.

## Updates

This template builds from this repo's `main` branch. When we bump marimo, Railway shows deployers an "update available" notice, and you choose when to apply it. Read [`CHANGELOG.md`](CHANGELOG.md) first: breaking changes are listed first in each entry. Your notebooks and settings stay on the volume across updates. Packages you installed from the UI stay too; if one stops working with a newer marimo or Python, reinstall it from the package panel.

## How it works

`start.sh` (the container's command):

1. Refuses to start without `MARIMO_PASSWORD`.
2. Creates `/data/notebooks`, `/data/.config` and `/data/.packages`, and copies marimo's tutorials on first boot.
3. Hands the password to marimo through a private file (`--token-password-file`), so it never shows in the process list.
4. `exec`s `marimo edit` in headless mode. If marimo stops for any reason (crash, out-of-memory kill), the container exits non-zero and Railway's restart policy brings it back.

Thread pools for NumPy/BLAS, Polars and Rayon are capped at 2 (`OMP_NUM_THREADS`, `POLARS_MAX_THREADS`, …) so a notebook doesn't start dozens of threads on a small plan. Raise them as service variables on bigger plans.

## Licence

The wrapper in this repo is MIT. marimo is Apache-2.0 ([marimo-team/marimo](https://github.com/marimo-team/marimo)).
