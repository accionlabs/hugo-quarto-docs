#!/bin/bash
# GUI Installer for Hugo-Quarto Documentation System
# This script provides a user-friendly installation experience

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Clear screen and show welcome
clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              📚 Documentation System Setup                     ║"
echo "║                                                               ║"
echo "║  This installer will set up your documentation system         ║"
echo "║  and create easy shortcuts for you to use.                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Function to show progress
show_progress() {
    local message="$1"
    echo -e "${BLUE}📋 ${message}${NC}"
    sleep 1
}

# Function to show success
show_success() {
    local message="$1"
    echo -e "${GREEN}✅ ${message}${NC}"
    sleep 1
}

# Function to show error
show_error() {
    local message="$1"
    echo -e "${RED}❌ ${message}${NC}"
}

# Function to ask user questions
ask_user() {
    local question="$1"
    local default="$2"
    echo -e "${YELLOW}❓ ${question}${NC}"
    if [ -n "$default" ]; then
        echo -e "   Press Enter for default: ${default}"
    fi
    read -r response
    echo "${response:-$default}"
}

echo "Let's get started! We'll ask you a few simple questions."
echo ""

# Ask where to install
echo -e "${YELLOW}📁 Where would you like to install your documentation system?${NC}"
echo "   This will create a folder where all your documents will be stored."
echo ""
echo "   Recommended locations:"
echo "   1) Documents folder (recommended)"
echo "   2) Desktop"
echo "   3) Custom location"
echo ""
read -p "Enter your choice (1, 2, or 3): " location_choice

case $location_choice in
    1)
        INSTALL_DIR="$HOME/Documents/my-documentation"
        ;;
    2)
        INSTALL_DIR="$HOME/Desktop/my-documentation"
        ;;
    3)
        INSTALL_DIR=$(ask_user "Enter the full path where you'd like to install:" "$HOME/my-documentation")
        ;;
    *)
        INSTALL_DIR="$HOME/Documents/my-documentation"
        echo -e "${BLUE}Using default: Documents folder${NC}"
        ;;
esac

echo ""
show_progress "Creating your documentation system at: $INSTALL_DIR"

# Create installation directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Clone the repository
show_progress "Downloading documentation system..."
if git clone https://github.com/accionlabs/hugo-quarto-docs.git . > /dev/null 2>&1; then
    show_success "Documentation system downloaded successfully"
else
    show_error "Failed to download. Please check your internet connection."
    exit 1
fi

# Set up content from sample
show_progress "Setting up your content folder..."
if [ -d "content-sample" ]; then
    cp -r content-sample/* content/ 2>/dev/null || true
    show_success "Sample content copied to your content folder"
else
    show_error "Sample content not found"
fi

# Make scripts executable
chmod +x *.sh 2>/dev/null || true

# Create desktop shortcuts
show_progress "Creating desktop shortcuts..."

# Create launch script wrapper
cat > "$INSTALL_DIR/🚀 Start.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "🚀 Starting your documentation system..."
echo "📁 Location: $(pwd)"
echo "🌐 Opening browser to: http://localhost:1313"
echo ""
echo "💡 Your content folder is at: $(pwd)/content"
echo ""
./launch.sh
EOF

chmod +x "$INSTALL_DIR/🚀 Start.command"

# Create content folder opener
cat > "$INSTALL_DIR/📁 Documents.command" << EOF
#!/bin/bash
cd "$(dirname "\$0")"
open ./content
EOF

chmod +x "$INSTALL_DIR/📁 Documents.command"

# Create Obsidian launcher if Obsidian is available
if [ -d "/Applications/Obsidian.app" ]; then
    cat > "$INSTALL_DIR/📝 Obsidian.command" << EOF
#!/bin/bash
cd "$(dirname "\$0")"
open -a "Obsidian" ./content
EOF
    chmod +x "$INSTALL_DIR/📝 Obsidian.command"
    show_success "Obsidian shortcut created (Obsidian detected)"
fi

# Create VS Code launcher if VS Code is available
if [ -d "/Applications/Visual Studio Code.app" ] || command -v code &> /dev/null; then
    cat > "$INSTALL_DIR/💻 VS Code.command" << EOF
#!/bin/bash
cd "$(dirname "\$0")"
if command -v code &> /dev/null; then
    code ./content
else
    open -a "Visual Studio Code" ./content
fi
EOF
    chmod +x "$INSTALL_DIR/💻 VS Code.command"
    show_success "VS Code shortcut created"
fi

show_success "Desktop shortcuts created successfully"

# Create README for users
show_progress "Creating user guide..."

cat > "$INSTALL_DIR/📖 Quick Start.md" << 'EOF'
# 📖 How to Use Your Documentation System

## 🚀 Quick Start

### Double-click these files to get started:
- **🚀 Start.command** - Starts your website (opens in browser)
- **📁 Documents.command** - Opens your documents folder
- **📝 Obsidian.command** - Opens documents in Obsidian (if installed)
- **💻 VS Code.command** - Opens documents in VS Code (if installed)

### 📁 Your Important Folders:
- **content/** - This is where you put all your documents
- **content/projects/** - For client projects and work documents  
- **content/shared/** - For team resources and templates
- **content/private/** - For your personal notes (not shared)

## ✍️ Creating Documents

### For Simple Notes:
1. Create `.md` files in the content folder
2. Start each file with:
```
---
title: "Your Document Title"
description: "Brief description"
date: 2025-01-22
---

# Your content starts here...
```

### For Professional Documents (with exports):
1. Create `.qmd` files for documents you want to export to Word/PowerPoint
2. Start each file with:
```
---
title: "Your Document Title"  
description: "Brief description"
date: 2025-01-22
quarto_exports: ["docx", "pptx"]
---

# Your content starts here...
```

## 🖥️ Using the Website

1. Double-click **🚀 Start.command**
2. Wait for "Site will be available at: http://localhost:1313"
3. Your browser will open automatically
4. Edit documents in the content folder
5. Refresh browser to see changes

## 🔧 Getting Help

- Check the **shared/getting-started-with-obsidian/** folder for detailed guides
- All sample content includes examples you can copy
- The website includes tutorials and templates

## 🆘 If Something Goes Wrong

- Close the terminal window and double-click **Launch Documentation.command** again
- Make sure you're editing files in the **content/** folder (not content-sample)
- Check that your file names don't have spaces (use hyphens instead)

**Need more help?** Check the documentation in the shared folder!
EOF

show_success "User guide created"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 Installation Complete!                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Your documentation system is ready!${NC}"
echo ""
echo -e "${BLUE}📍 Location:${NC} $INSTALL_DIR"
echo ""
echo -e "${YELLOW}🚀 To get started:${NC}"
echo "   1. Double-click '🚀 Start.command'"
echo "   2. Double-click '📁 Documents.command' to see your documents"
echo "   3. Read '📖 Quick Start.md' for detailed instructions"
echo ""
echo -e "${BLUE}💡 Pro tip:${NC} Bookmark this folder in Finder for easy access!"
echo ""

# Open the installation folder in Finder
if ask_user "Would you like to open the installation folder now? (y/n)" "y" | grep -q "^[Yy]"; then
    open "$INSTALL_DIR"
    show_success "Opening your documentation folder..."
fi

# Ask if they want to start immediately
echo ""
if ask_user "Would you like to start the documentation system now? (y/n)" "y" | grep -q "^[Yy]"; then
    echo ""
    show_success "Starting your documentation system..."
    echo "🔗 Your website will open at: http://localhost:1313"
    echo "📁 Edit documents in: $INSTALL_DIR/content"
    echo ""
    exec "$INSTALL_DIR/🚀 Start.command"
fi

echo ""
show_success "Setup complete! You can start anytime by double-clicking '🚀 Start.command'"