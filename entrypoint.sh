#!/usr/bin/env bash
set -euo pipefail

# Start the Streamlit app
# The service listens on port 8501 inside the container

cd /home/appuser

echo "Starting StrideGPT Streamlit application on port 8501..."
exec streamlit run main.py --server.port 8501 --server.address 0.0.0.0
