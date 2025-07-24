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
        # Store checksums of files with quarto_exports instead of timestamps
        CHECKSUM_FILE="/tmp/quarto_checksums_$$"
        
        # Function to generate checksums of relevant files
        generate_checksums() {
            find content/ \( -name "*.qmd" -o -name "*.md" \) -exec grep -l "quarto_exports:" {} \; 2>/dev/null | \
            while read -r file; do
                if [ -f "$file" ]; then
                    # Use modification time + file size as a simple checksum
                    stat -f "%N %m %z" "$file" 2>/dev/null || stat -c "%n %Y %s" "$file" 2>/dev/null
                fi
            done | sort
        }
        
        # Generate initial checksums
        generate_checksums > "$CHECKSUM_FILE"
        
        while true; do
            sleep 3
            
            # Generate new checksums
            NEW_CHECKSUM_FILE="/tmp/quarto_checksums_new_$$"
            generate_checksums > "$NEW_CHECKSUM_FILE"
            
            # Compare checksums
            if ! cmp -s "$CHECKSUM_FILE" "$NEW_CHECKSUM_FILE" 2>/dev/null; then
                # Find which files changed
                CHANGED_FILES=$(comm -13 <(sort "$CHECKSUM_FILE") <(sort "$NEW_CHECKSUM_FILE") | cut -d' ' -f1)
                if [ -n "$CHANGED_FILES" ]; then
                    echo "🔄 Quarto file changes detected: $(echo "$CHANGED_FILES" | tr '\n' ' ')"
                    echo "   Regenerating exports..."
                    ./build.sh >/dev/null 2>&1
                fi
                cp "$NEW_CHECKSUM_FILE" "$CHECKSUM_FILE"
            fi
            
            rm -f "$NEW_CHECKSUM_FILE"
        done
        
        # Cleanup
        rm -f "$CHECKSUM_FILE"
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