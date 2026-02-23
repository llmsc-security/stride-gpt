#!/usr/bin/env bash
set -euo pipefail

# Start the Streamlit app
# The service listens on port 11040 (mapped port) inside the container

cd /home/appuser

echo "Starting StrideGPT Streamlit application on port 11040..."
exec streamlit run main.py --server.port 11040 --server.address 0.0.0.0
