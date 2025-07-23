#!/bin/bash
# Creates a Mac app bundle for the documentation system

APP_NAME="Documentation System"
BUNDLE_NAME="Documentation System.app"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create app bundle structure
mkdir -p "$BUNDLE_NAME/Contents/MacOS"
mkdir -p "$BUNDLE_NAME/Contents/Resources"

# Create Info.plist
cat > "$BUNDLE_NAME/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Documentation System</string>
    <key>CFBundleIdentifier</key>
    <string>com.accionlabs.documentation-system</string>
    <key>CFBundleName</key>
    <string>Documentation System</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleIconFile</key>
    <string>app-icon.icns</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create the main executable
cat > "$BUNDLE_NAME/Contents/MacOS/Documentation System" << 'EOF'
#!/bin/bash

# Documentation System App Launcher
RESOURCES_DIR="$(dirname "$0")/../Resources"
INSTALL_DIR="$HOME/Documents/Documentation System"

# Function to show notifications
show_notification() {
    osascript -e "display notification \"$1\" with title \"Documentation System\""
}

# Check if already installed
if [ ! -d "$INSTALL_DIR" ]; then
    # First run - need to install
    osascript << 'APPLESCRIPT'
    tell application "System Events"
        display dialog "Welcome to Documentation System!

This is your first time running the app. We'll set up your documentation system in your Documents folder.

This will:
• Create a 'Documentation System' folder in Documents
• Set up sample content and templates
• Install required components

Ready to get started?" buttons {"Cancel", "Install"} default button "Install" with title "Documentation System Setup"
        
        if button returned of result is "Cancel" then
            return
        end if
    end tell
APPLESCRIPT
    
    if [ $? -ne 0 ]; then
        exit 0
    fi
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Show progress
    show_notification "Setting up your documentation system..."
    
    # Copy resources from bundle
    if [ -d "$RESOURCES_DIR/hugo-quarto-docs" ]; then
        cp -r "$RESOURCES_DIR/hugo-quarto-docs/"* "$INSTALL_DIR/"
    else
        # Download from GitHub if not bundled
        cd "$INSTALL_DIR"
        if command -v git &> /dev/null; then
            git clone https://github.com/accionlabs/hugo-quarto-docs.git temp
            cp -r temp/* .
            rm -rf temp
        else
            curl -L https://github.com/accionlabs/hugo-quarto-docs/archive/main.zip -o temp.zip
            unzip temp.zip
            cp -r hugo-quarto-docs-main/* .
            rm -rf hugo-quarto-docs-main temp.zip
        fi
    fi
    
    # Set up content
    if [ -d "content-sample" ] && [ ! -d "content" ]; then
        cp -r content-sample content
    fi
    
    # Make scripts executable
    chmod +x *.sh 2>/dev/null
    
    # Create shortcuts
    cat > "$INSTALL_DIR/🚀 Start.command" << 'SHORTCUT'
#!/bin/bash
cd "$(dirname "$0")"
echo "🚀 Starting Documentation System..."
echo "📂 Location: $(pwd)"
echo "🌐 Opening: http://localhost:1313"
echo ""
./launch.sh
SHORTCUT
    
    cat > "$INSTALL_DIR/📁 Documents.command" << 'SHORTCUT'
#!/bin/bash
cd "$(dirname "$0")"
open ./content
SHORTCUT
    
    chmod +x "$INSTALL_DIR/"*.command
    
    show_notification "Installation complete!"
    
    # Show completion dialog
    osascript << APPLESCRIPT
    tell application "System Events"
        display dialog "Installation Complete! ✅

Your documentation system is ready at:
Documents/Documentation System

To get started:
• Double-click '🚀 Start Documentation System.command'
• Double-click '📁 Open Documents Folder.command' to access your files

Would you like to open the folder now?" buttons {"Later", "Open Folder"} default button "Open Folder" with title "Documentation System"
        
        if button returned of result is "Open Folder" then
            tell application "Finder"
                open folder POSIX file "$INSTALL_DIR"
            end tell
        end if
    end tell
APPLESCRIPT

else
    # Already installed - just launch
    cd "$INSTALL_DIR"
    
    # Check if system is already running
    if pgrep -f "hugo serve" > /dev/null; then
        osascript << 'APPLESCRIPT'
        tell application "System Events"
            display dialog "Documentation System is already running!

You can access it at: http://localhost:1313

Would you like to open it in your browser?" buttons {"Cancel", "Open Browser"} default button "Open Browser" with title "Documentation System"
            
            if button returned of result is "Open Browser" then
                open location "http://localhost:1313"
            end if
        end tell
APPLESCRIPT
    else
        # Start the system
        show_notification "Starting Documentation System..."
        
        osascript << 'APPLESCRIPT'
        tell application "System Events"
            display dialog "Starting your documentation system...

• Location: Documents/Documentation System
• Website: http://localhost:1313
• Edit documents in: content/ folder

The system will start in a new terminal window." buttons {"OK"} default button "OK" with title "Documentation System"
        end tell
APPLESCRIPT
        
        # Open terminal and start
        osascript << APPLESCRIPT
        tell application "Terminal"
            do script "cd '$INSTALL_DIR' && ./launch.sh"
            activate
        end tell
APPLESCRIPT
    fi
fi
EOF

# Make executable
chmod +x "$BUNDLE_NAME/Contents/MacOS/Documentation System"

echo "✅ App bundle created: $BUNDLE_NAME"
echo ""
echo "To distribute:"
echo "1. Optionally bundle the source code in Contents/Resources/"
echo "2. Create a DMG or ZIP file"
echo "3. Users can drag the app to Applications folder"