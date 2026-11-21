# marimo reactive Python notebook, official image (sql variant: pandas, numpy,
# altair, polars, duckdb). Pinned by version and digest.
FROM ghcr.io/marimo-team/marimo:0.25.2-sql@sha256:f154a40fba17cda7581edd3a3ef6c371d46c69a0e45dcd825293554e5d62e4c6

# Railway volumes mount as root, so the wrapper runs as root and keeps all
# state under /data (the volume).
USER root

# Everything stateful lives on the volume; thread pools are capped so the
# service stays inside small plans (0.5 GB / 1 vCPU). Override any of these
# as service variables.
ENV MARIMO_DATA_DIR=/data \
    HOME=/data \
    XDG_CONFIG_HOME=/data/.config \
    XDG_STATE_HOME=/data/.local/state \
    UV_CACHE_DIR=/tmp/uv-cache \
    MARIMO_UV_TARGET=/data/.packages \
    PIP_TARGET=/data/.packages \
    PIP_CACHE_DIR=/tmp/pip-cache \
    MARIMO_SKIP_UPDATE_CHECK=1 \
    OMP_NUM_THREADS=2 \
    OPENBLAS_NUM_THREADS=2 \
    MKL_NUM_THREADS=2 \
    NUMEXPR_MAX_THREADS=2 \
    POLARS_MAX_THREADS=2 \
    RAYON_NUM_THREADS=2 \
    PORT=8080 \
    HOST=0.0.0.0

# Packages installed from the notebook UI go to /data/.packages (on the
# volume). A .pth file appends that folder to sys.path *after* the image's own
# site-packages, so the pinned marimo and its dependencies always win.
RUN SP="$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')" && \
    echo /data/.packages > "$SP/zz-railway-data-packages.pth"

COPY start.sh /usr/local/bin/start-marimo
RUN chmod 755 /usr/local/bin/start-marimo

WORKDIR /data
EXPOSE 8080
STOPSIGNAL SIGTERM
CMD ["/usr/local/bin/start-marimo"]
