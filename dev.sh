#!/bin/bash

# Development server script for Hugo + Quarto documentation system

echo "Starting Hugo + Quarto Documentation System..."
echo

# Check for updates (non-blocking)
if [ -f "./check-updates.sh" ]; then
    ./check-updates.sh
fi

echo "Starting Hugo development server..."
echo "Site will be available at: http://localhost:1313"
echo "Press Ctrl+C to stop the server"
echo

hugo serve