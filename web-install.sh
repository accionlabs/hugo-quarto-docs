#!/bin/bash
# One-Click Web Installer for Documentation System
# This runs directly from the web with zero downloads required

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Clear screen and show welcome
clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              📚 Documentation System - One-Click Setup         ║"
echo "║                                                               ║"
echo "║  Welcome! This installer will set up your documentation       ║"
echo "║  system automatically with zero technical knowledge required.  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Show progress
show_progress() {
    local message="$1"
    echo -e "${BLUE}📋 ${message}${NC}"
    sleep 1
}

show_success() {
    local message="$1"
    echo -e "${GREEN}✅ ${message}${NC}"
    sleep 1
}

show_error() {
    local message="$1"
    echo -e "${RED}❌ ${message}${NC}"
}

# Ask for installation location with smart defaults
echo -e "${YELLOW}📁 Choose your installation location:${NC}"
echo ""
echo "   We recommend your Documents folder for easy access."
echo "   Your documents will be stored in: [Location]/Documentation System/content/"
echo ""
echo "   Press Enter to install in Documents (recommended)"
echo "   Or type a different location (like Desktop):"
echo ""
read -p "   Location: " custom_location

if [ -z "$custom_location" ]; then
    INSTALL_DIR="$HOME/Documents/Documentation System"
    LOCATION_NAME="Documents"
else
    case "$custom_location" in
        [Dd]esktop)
            INSTALL_DIR="$HOME/Desktop/Documentation System"
            LOCATION_NAME="Desktop"
            ;;
        [Dd]ocuments)
            INSTALL_DIR="$HOME/Documents/Documentation System"
            LOCATION_NAME="Documents"
            ;;
        *)
            INSTALL_DIR="$HOME/$custom_location/Documentation System"
            LOCATION_NAME="$custom_location"
            ;;
    esac
fi

echo ""
show_progress "Installing Documentation System to: $LOCATION_NAME/Documentation System"

# Create installation directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download and extract
show_progress "Downloading system files..."
if command -v curl &> /dev/null; then
    curl -sSL https://github.com/accionlabs/hugo-quarto-docs/archive/main.zip -o temp.zip
elif command -v wget &> /dev/null; then
    wget -q https://github.com/accionlabs/hugo-quarto-docs/archive/main.zip -O temp.zip
else
    show_error "Neither curl nor wget found. Please install one of them and try again."
    exit 1
fi

if [ ! -f "temp.zip" ]; then
    show_error "Failed to download system files. Please check your internet connection."
    exit 1
fi

show_progress "Extracting files..."
if command -v unzip &> /dev/null; then
    unzip -q temp.zip
    cp -r hugo-quarto-docs-main/* .
    rm -rf hugo-quarto-docs-main temp.zip
else
    show_error "unzip not found. Please install unzip and try again."
    exit 1
fi

show_success "System files downloaded and extracted"

# Set up content
show_progress "Setting up your content folder..."
if [ -d "content-sample" ] && [ ! -d "content" ]; then
    cp -r content-sample content
    show_success "Sample content copied"
fi

# Make scripts executable
chmod +x *.sh 2>/dev/null || true

# Create user-friendly shortcuts
show_progress "Creating easy-to-use shortcuts..."

# Create the main launcher
cat > "$INSTALL_DIR/🚀 Start.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# Clear terminal and show friendly message
clear
echo "🚀 Documentation System Starting..."
echo ""
echo "📍 Location: $(pwd)"
echo "📂 Your documents: $(pwd)/content/"
echo "🌐 Website will open at: http://localhost:1313"
echo ""
echo "💡 To edit documents:"
echo "   • Double-click '📁 Documents.command'"
echo "   • Or use Obsidian/VS Code shortcuts if available"
echo ""
echo "🔄 Refresh your browser after editing documents to see changes"
echo ""
echo "⏳ Starting system... (this may take a moment)"
echo ""

# Start the system
./launch.sh
EOF

# Create content folder opener
cat > "$INSTALL_DIR/📁 Documents.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
open ./content
EOF

# Create system stopper
cat > "$INSTALL_DIR/⏹️ Stop.command" << 'EOF'
#!/bin/bash
echo "🛑 Stopping Documentation System..."
pkill -f "hugo serve" 2>/dev/null || true
pkill -f "launch.sh" 2>/dev/null || true
echo "✅ Documentation System stopped"
echo ""
echo "💡 To start again, double-click '🚀 Start.command'"
read -p "Press Enter to close..."
EOF

# Check for and create app-specific shortcuts
if [ -d "/Applications/Obsidian.app" ]; then
    cat > "$INSTALL_DIR/📝 Obsidian.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
open -a "Obsidian" ./content
EOF
    chmod +x "$INSTALL_DIR/📝 Obsidian.command"
    show_success "Obsidian shortcut created"
fi

if [ -d "/Applications/Visual Studio Code.app" ] || command -v code &> /dev/null; then
    cat > "$INSTALL_DIR/💻 VS Code.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
if command -v code &> /dev/null; then
    code ./content
else
    open -a "Visual Studio Code" ./content
fi
EOF
    chmod +x "$INSTALL_DIR/💻 VS Code.command"
    show_success "VS Code shortcut created"
fi

# Make all shortcuts executable
chmod +x "$INSTALL_DIR/"*.command

# Create comprehensive user guide
show_progress "Creating user guide..."
cat > "$INSTALL_DIR/📖 Quick Start.md" << 'EOF'
# 📖 Quick Start Guide - Documentation System

## 🚀 Getting Started (3 Easy Steps)

### Step 1: Start the System
**Double-click: `🚀 Start.command`**
- Wait for "Site will be available at: http://localhost:1313"
- Your browser will open automatically
- Leave the terminal window open while working

### Step 2: Access Your Documents  
**Double-click: `📁 Documents.command`**
- This opens the folder where you create/edit documents
- All your files go in the `content/` folder that opens

### Step 3: Create Your First Document
1. In the documents folder, go to `projects/`
2. Create a new folder for your project (no spaces, use hyphens)
3. Create a new file ending in `.md` or `.qmd`
4. Start with this template:

```
---
title: "My First Document"
description: "Learning the system"
date: 2025-01-22
---

# My First Document

This is my first document in the system!

## What I'm learning
- How to create documents
- How to organize projects
- How to export to Word/PowerPoint
```

## 📁 Folder Structure
```
content/
├── projects/     ← Client work and projects
├── shared/       ← Team resources and guides  
├── private/      ← Your personal notes
└── assets/       ← Images and files
```

## 💡 Daily Workflow
1. **Double-click** `🚀 Start.command`
2. **Double-click** `📁 Documents.command` 
3. **Edit your documents** in the content folder
4. **Refresh your browser** to see changes
5. **When done, double-click** `⏹️ Stop.command`

## 🔄 For Documents You Want to Export to Word/PowerPoint
- Use `.qmd` files instead of `.md`
- Add this to the top section: `quarto_exports: ["docx", "pptx"]`
- Export links appear automatically on the website

## 🆘 Need Help?
- Check the `shared/getting-started-for-beginners/` folder for detailed guides
- Look at sample content for examples
- All shortcuts have descriptive names - just double-click them!

## ✅ Remember
- **Always keep the terminal window open** while working
- **Edit files in the content/ folder** (not content-sample)
- **Refresh browser** after making changes
- **Use hyphens instead of spaces** in file names

**You're all set! Happy documenting! 📝**
EOF

show_success "User guide created"

# Create desktop alias/shortcut if possible
if [ -d "$HOME/Desktop" ]; then
    show_progress "Creating desktop shortcut..."
    ln -sf "$INSTALL_DIR/🚀 Start.command" "$HOME/Desktop/🚀 Docs.command" 2>/dev/null || true
    show_success "Desktop shortcut created"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 Installation Complete!                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Your Documentation System is ready to use!${NC}"
echo ""
echo -e "${BLUE}📍 Location:${NC} $LOCATION_NAME/Documentation System"
echo -e "${BLUE}📂 Your documents:${NC} $LOCATION_NAME/Documentation System/content/"
echo ""
echo -e "${YELLOW}🚀 To get started right now:${NC}"
echo "   1. Double-click '🚀 Start.command'"
echo "   2. Double-click '📁 Documents.command'"
echo "   3. Read '📖 Quick Start.md' for step-by-step instructions"
echo ""
echo -e "${GREEN}💡 Everything is ready - no technical knowledge required!${NC}"
echo ""

# Ask if they want to start immediately
echo "Would you like to:"
echo "1) Start the Documentation System now"
echo "2) Open the installation folder"
echo "3) Exit (start manually later)"
echo ""
read -p "Choose (1, 2, or 3): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Starting Documentation System..."
        echo "🌐 Website will open at: http://localhost:1313"
        echo "📂 Edit documents in: $INSTALL_DIR/content/"
        echo ""
        exec "$INSTALL_DIR/🚀 Start.command"
        ;;
    2)
        echo ""
        echo "📁 Opening installation folder..."
        open "$INSTALL_DIR"
        ;;
    *)
        echo ""
        echo "✅ Installation complete!"
        echo "📍 Find your system at: $LOCATION_NAME/Documentation System"
        echo "🚀 Start anytime by double-clicking '🚀 Start.command'"
        ;;
esac