# Changelog

Every release of this template. Breaking changes are listed first in each entry.
Railway shows deployers an "update available" notice when `main` changes; read the entry
before you apply it.

## 0.25.2-railway.1 (2026-11-21)

First release.

- marimo 0.25.2 (`ghcr.io/marimo-team/marimo:0.25.2-sql`, pinned by digest).
- marimo's own password login (`MARIMO_PASSWORD`, generated at deploy); the container refuses to start without it.
- Notebooks, settings and UI-installed packages on the `/data` volume.
- `/healthz` answers without login for Railway's health check.
- The container exits non-zero if marimo stops, so Railway restarts it. Thread pools capped at 2 for small plans.
