# ------------------------------------------------------------
#  Streamlit app – clean single-stage Dockerfile
# ------------------------------------------------------------
FROM python:3.12-slim

# ------------------------------------------------------------
#  General environment variables
# ------------------------------------------------------------
ENV PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_SERVER_PORT=8501 \
    STREAMLIT_SERVER_ADDRESS=0.0.0.0

# ------------------------------------------------------------
#  System packages – curl for healthcheck and build tools for wheels
# ------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        build-essential \
        gcc \
        python3-dev \
        libffi-dev \
        libssl-dev \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
#  Create a non‑root user
# ------------------------------------------------------------
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid 1000 -ms /bin/bash appuser && \
    mkdir -p /home/appuser && \
    chown -R appuser:appuser /home/appuser

# ------------------------------------------------------------
#  Working directory (owned by appuser)
# ------------------------------------------------------------
WORKDIR /home/appuser

# ------------------------------------------------------------
#  Copy only the requirements first to leverage layer caching
# ------------------------------------------------------------
COPY --chown=appuser:appuser requirements.txt .

# ------------------------------------------------------------
#  Python virtual environment + dependencies (run as root for speed)
# ------------------------------------------------------------
ENV VIRTUAL_ENV=/home/appuser/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python -m venv "$VIRTUAL_ENV" && \
    "$VIRTUAL_ENV/bin/pip" install --no-cache-dir --upgrade pip setuptools wheel && \
    "$VIRTUAL_ENV/bin/pip" install --no-cache-dir -r requirements.txt && \
    "$VIRTUAL_ENV/bin/pip" check

# ------------------------------------------------------------
#  Copy the rest of the application source and entrypoint
# ------------------------------------------------------------
COPY --chown=appuser:appuser . .

# Ensure the entrypoint script is executable
RUN chmod +x /home/appuser/entrypoint.sh

# ------------------------------------------------------------
#  Switch to non‑root user for runtime
# ------------------------------------------------------------
USER appuser

# ------------------------------------------------------------
#  Runtime configuration
# ------------------------------------------------------------
EXPOSE 11040

# ------------------------------------------------------------
#  Healthcheck – curl the internal Streamlit health endpoint
# ------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:11040/_stcore/health || exit 1

# ------------------------------------------------------------
#  Entrypoint – start the Streamlit app
# ------------------------------------------------------------
ENTRYPOINT ["/home/appuser/entrypoint.sh"]
