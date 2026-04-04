#!/bin/bash

# SoruTrack Pro - Pre-build Verification Script
# This script ensures all quality checks pass before a production build is allowed.

set -e # Exit immediately if a command exits with a non-zero status.

echo "------------------------------------------------"
echo "🚀 Starting Pre-build Verification..."
echo "------------------------------------------------"

# 1. Static Analysis
echo "🔍 Running Static Analysis (flutter analyze --no-fatal-infos)..."
flutter analyze --no-fatal-infos
echo "✅ Static analysis passed!"

# 2. Unit & Widget Tests
echo "🧪 Running Unit and Widget Tests (flutter test)..."
flutter test
echo "✅ Unit and widget tests passed!"

# 3. Integration Tests (E2E)
# Note: In a CI environment, you might need a headless browser or emulator.
# For local web verification, we can run a specific web-targeted integration test if requested.
# But for now, we'll run the standard integration tests.
if [ -d "integration_test" ]; then
    echo "🌐 Running Integration Tests..."
    # If you have specific web tests, you could use:
    # flutter test integration_test/web_e2e_test.dart -d chrome
    flutter test integration_test/
    echo "✅ Integration tests passed!"
fi

echo "------------------------------------------------"
echo "🎉 All checks passed! Ready for production build."
echo "------------------------------------------------"
exit 0
