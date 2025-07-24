#!/bin/bash

# Development server script for Hugo + Quarto documentation system

echo "Starting Hugo + Quarto Documentation System..."
echo

# Check for updates (non-blocking)
if [ -f "./check-updates.sh" ]; then
    ./check-updates.sh
fi

echo "Processing Quarto documents and preparing site..."
echo

# Run build operations to process QMD files, create _index.md files, etc.
if [ -f "./build.sh" ]; then
    ./build.sh
else
    echo "Warning: build.sh not found, skipping Quarto processing"
fi

echo
echo "Starting Hugo development server with Quarto file watching..."
echo "Site will be available at: http://localhost:1313"
echo "Press Ctrl+C to stop the server"
echo

# Cross-platform file watcher for Quarto exports
if command -v entr >/dev/null 2>&1; then
    echo "📁 Using entr for efficient file watching..."
    find content/ -name "*.qmd" -o -name "*.md" | entr -r ./build.sh &
    WATCHER_PID=$!
elif command -v inotifywait >/dev/null 2>&1; then
    echo "📁 Using inotifywait for file watching..."
    inotifywait -m -r -e modify,create,move --include=".*\.(qmd|md)$" content/ 2>/dev/null | while read path action file; do
        echo "🔄 File change detected: $file"
        ./build.sh >/dev/null 2>&1
    done &
    WATCHER_PID=$!
else
    echo "📁 Using polling-based file watching (no entr/inotifywait found)..."
    echo "   For better performance, install: brew install entr (macOS) or apt install entr (Linux)"
    
    # Simple polling approach for Windows and systems without file watchers
    (
        # Track last modification time
        LAST_CHECK_FILE="/tmp/quarto_last_check_$$"
        date +%s > "$LAST_CHECK_FILE" 2>/dev/null || echo "0" > "$LAST_CHECK_FILE"
        
        while true; do
            sleep 2
            
            # Find files newer than last check
            LAST_CHECK=$(cat "$LAST_CHECK_FILE" 2>/dev/null || echo "0")
            
            # Use find with -newer if supported, otherwise fallback to basic check
            if find content/ -name "*.qmd" -o -name "*.md" -newer "$LAST_CHECK_FILE" 2>/dev/null | grep -q .; then
                echo "🔄 Quarto file changes detected, regenerating exports..."
                ./build.sh >/dev/null 2>&1
                date +%s > "$LAST_CHECK_FILE" 2>/dev/null || echo "$(date +%s)" > "$LAST_CHECK_FILE"
            elif [ "$LAST_CHECK" = "0" ]; then
                # First run - create the timestamp file
                date +%s > "$LAST_CHECK_FILE" 2>/dev/null || echo "$(date +%s)" > "$LAST_CHECK_FILE"
            fi
        done
        
        # Cleanup
        rm -f "$LAST_CHECK_FILE"
    ) &
    WATCHER_PID=$!
fi

echo "📁 File watcher started (PID: $WATCHER_PID)"

# Cleanup function to kill watcher on exit
cleanup() {
    echo ""
    echo "🛑 Stopping file watcher and Hugo server..."
    if [ ! -z "$WATCHER_PID" ]; then
        kill $WATCHER_PID 2>/dev/null
        # Kill any child processes (for inotifywait case)
        pkill -P $WATCHER_PID 2>/dev/null
    fi
    # Clean up temporary files
    rm -f /tmp/quarto_last_check_* 2>/dev/null
    exit 0
}

# Set up signal handlers
trap cleanup INT TERM EXIT

hugo serve