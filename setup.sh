#!/bin/bash

# Hugo + Quarto Documentation System Setup Script
# This script helps new users get started with the documentation system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_header() {
    echo -e "${BLUE}
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        Hugo + Quarto Documentation System Setup             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system requirements
check_requirements() {
    print_info "Checking system requirements..."
    
    local requirements_met=true
    
    # Check Hugo
    if command_exists hugo; then
        local hugo_version=$(hugo version | head -n 1)
        print_status "Hugo found: $hugo_version"
    else
        print_error "Hugo not found. Please install Hugo first."
        print_info "Visit: https://gohugo.io/installation/"
        requirements_met=false
    fi
    
    # Check Quarto
    if command_exists quarto; then
        local quarto_version=$(quarto --version 2>/dev/null || echo "version unknown")
        print_status "Quarto found: $quarto_version"
    else
        print_error "Quarto not found. Please install Quarto first."
        print_info "Visit: https://quarto.org/docs/get-started/"
        requirements_met=false
    fi
    
    # Check Git
    if command_exists git; then
        print_status "Git found"
    else
        print_warning "Git not found. Version control features will be limited."
        print_info "Visit: https://git-scm.com/downloads"
    fi
    
    # Check Pandoc (optional but recommended)
    if command_exists pandoc; then
        local pandoc_version=$(pandoc --version | head -n 1)
        print_status "Pandoc found: $pandoc_version"
    else
        print_warning "Pandoc not found. Grid table conversion will use Python fallback."
        print_info "Install with: brew install pandoc (recommended for better table conversion)"
    fi
    
    if [ "$requirements_met" = false ]; then
        print_error "Please install the required dependencies and run this script again."
        exit 1
    fi
}

# Setup content directory
setup_content() {
    print_info "Setting up content directory..."
    
    if [ -d "content" ]; then
        print_warning "Content directory already exists."
        read -p "Do you want to backup existing content? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local backup_dir="content-backup-$(date +%Y%m%d-%H%M%S)"
            mv content "$backup_dir"
            print_status "Existing content backed up to $backup_dir"
        else
            print_warning "Skipping content setup to preserve existing content."
            return
        fi
    fi
    
    if [ -d "content-sample" ]; then
        print_info "Copying sample content to content directory..."
        cp -r content-sample/ content/
        print_status "Sample content copied to content/"
        print_info "You can now customize the content in the content/ directory"
    else
        print_info "Creating basic content structure..."
        mkdir -p content/private content/projects content/shared
        
        # Create basic index files
        cat > content/_index.md << 'EOF'
---
title: "Documentation System"
description: "Your team's documentation hub"
---

# Welcome to Your Documentation System

Replace this content with your own documentation.

## Getting Started

1. Add your content to the `content/` directory
2. Use `.md` files for basic documentation
3. Use `.qmd` files for rich documents with export capabilities
4. Run `hugo serve` to start the development server

## Structure

- **Private**: Personal and confidential content
- **Projects**: Project documentation and deliverables
- **Shared**: Team knowledge base and methodologies
EOF

        cat > content/private/_index.md << 'EOF'
---
title: "Private"
description: "Personal and confidential content"
---

# Private Content

This section is for personal and confidential content.
EOF

        cat > content/projects/_index.md << 'EOF'
---
title: "Projects"
description: "Project documentation and deliverables"
---

# Projects

This section contains project documentation and deliverables.
EOF

        cat > content/shared/_index.md << 'EOF'
---
title: "Shared"
description: "Team knowledge base and methodologies"
---

# Shared Knowledge

This section contains team knowledge base and shared methodologies.
EOF

        print_status "Basic content structure created"
    fi
}

# Test the setup
test_setup() {
    print_info "Testing the setup..."
    
    # Test Hugo build
    print_info "Testing Hugo build..."
    if hugo --quiet; then
        print_status "Hugo build successful"
    else
        print_error "Hugo build failed"
        return 1
    fi
    
    # Test Quarto if there are .qmd files
    if find content -name "*.qmd" | head -1 | grep -q .; then
        print_info "Testing Quarto processing..."
        if ./build.sh > /dev/null 2>&1; then
            print_status "Quarto processing successful"
        else
            print_warning "Quarto processing failed (this is normal if no .qmd files are found)"
        fi
    fi
    
    print_status "Setup test completed successfully"
}

# Start development server
start_server() {
    print_info "Starting development server..."
    print_status "Your documentation site will be available at: http://localhost:1313"
    print_info "Press Ctrl+C to stop the server"
    print_info "Starting server in 3 seconds..."
    sleep 3
    hugo serve
}

# Main setup function
main() {
    print_header
    
    # Check if we're in the right directory
    if [ ! -f "hugo.yaml" ] && [ ! -f "hugo.yml" ] && [ ! -f "config.toml" ]; then
        print_error "This doesn't appear to be a Hugo site directory."
        print_error "Please run this script from the root of your Hugo site."
        exit 1
    fi
    
    check_requirements
    setup_content
    test_setup
    
    print_status "Setup completed successfully!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Customize the content in the content/ directory"
    print_info "2. Run 'hugo serve' to start the development server"
    print_info "3. Visit http://localhost:1313 to view your site"
    print_info "4. Use './build.sh' to process Quarto documents and generate exports"
    print_info ""
    
    read -p "Would you like to start the development server now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        start_server
    else
        print_info "You can start the server later by running: hugo serve"
    fi
}

# Handle command line arguments
case "${1:-}" in
    "content")
        setup_content
        ;;
    "test")
        test_setup
        ;;
    "server")
        start_server
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  content  - Set up content directory only"
        echo "  test     - Test the setup"
        echo "  server   - Start development server"
        echo "  help     - Show this help message"
        echo ""
        echo "Run without arguments for full interactive setup."
        ;;
    *)
        main
        ;;
esac