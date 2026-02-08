#!/usr/bin/env bash
set -euo pipefail

# Docker cache directory - shared across builds for layer caching
DOCKER_CACHE_DIR="${DOCKER_CACHE_DIR:-/home/docker_comm_user/cache}"

# Repository info
REPO_NAME="mrwadams--stride-gpt"
REPO_DIR="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/${REPO_NAME}"
IMAGE_NAME="${REPO_NAME}"

# Build cache directory for this repo
BUILD_CACHE_DIR="${DOCKER_CACHE_DIR}/${REPO_NAME}"

# Create cache directories
mkdir -p "${BUILD_CACHE_DIR}"

echo "Building Docker image: ${IMAGE_NAME}"
echo "Cache directory: ${BUILD_CACHE_DIR}"

# Build with cache-from to reuse layers from previous builds
docker build \
    --cache-from "${IMAGE_NAME}:latest" \
    --cache-from "type=local,src=${BUILD_CACHE_DIR}" \
    -t "${IMAGE_NAME}:latest" \
    "${REPO_DIR}"

echo "Build complete: ${IMAGE_NAME}:latest"

# Run the container
echo "Running container on port 11040..."
docker run -d \
    --name "${REPO_NAME}" \
    -p 11040:8501 \
    -v "${REPO_DIR}:/home/appuser" \
    "${IMAGE_NAME}:latest"

echo "Container started: ${REPO_NAME}"
echo "Access the app at: http://localhost:11040"
