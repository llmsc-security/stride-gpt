#!/usr/bin/env python3
"""
Tutorial PoC script for StrideGPT HTTP API

This script demonstrates how to interact with the StrideGPT service
running in a Docker container on port 11040.
"""

import requests
import json

# Service configuration
BASE_URL = "http://localhost:11040"


def test_health():
    """Test the health endpoint"""
    print("Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/_stcore/health")
    print(f"Health check response: {response.status_code}")
    print(f"Response: {response.text[:200]}")
    print()
    return response.status_code == 200


def test_root():
    """Test the root endpoint"""
    print("Testing root endpoint...")
    response = requests.get(BASE_URL)
    print(f"Root response status: {response.status_code}")
    print(f"Response preview: {response.text[:300]}...")
    print()
    return response.status_code == 200


def test_streamlit_page():
    """Test accessing the Streamlit app page"""
    print("Testing Streamlit app page...")
    response = requests.get(f"{BASE_URL}/")
    print(f"Streamlit page response status: {response.status_code}")
    print(f"Content contains Streamlit: {'Streamlit' in response.text}")
    print()
    return response.status_code == 200


def main():
    """Run all tests"""
    print("=" * 60)
    print("StrideGPT HTTP API Tutorial PoC")
    print("=" * 60)
    print()

    tests = [
        ("Health Check", test_health),
        ("Root Endpoint", test_root),
        ("Streamlit Page", test_streamlit_page),
    ]

    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, "PASSED" if result else "FAILED"))
        except requests.exceptions.ConnectionError as e:
            print(f"Connection error: {e}")
            print("Make sure the Docker container is running on port 11040")
            print()
            return
        except Exception as e:
            results.append((name, f"ERROR: {e}"))

    print("=" * 60)
    print("Test Results:")
    print("=" * 60)
    for name, result in results:
        print(f"  {name}: {result}")
    print()


if __name__ == "__main__":
    main()
