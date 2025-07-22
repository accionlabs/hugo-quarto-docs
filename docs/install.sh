#!/bin/bash

# Hugo + Quarto Documentation System - One-Click Installer
# Usage: curl -sSL https://accionlabs.github.io/hugo-quarto-docs/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/accionlabs/hugo-quarto-docs.git"
INSTALL_DIR="$HOME/hugo-quarto-docs"
REQUIRED_TOOLS=("git" "curl")

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║    Hugo + Quarto Documentation System Installer             ║"
    echo "║                                                              ║"
    echo "║    This will install the documentation system locally       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking system prerequisites..."
    
    local missing_tools=()
    
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool is installed"
        else
            missing_tools+=("$tool")
            print_warning "$tool is not installed"
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install the missing tools and run this script again."
        
        local os=$(detect_os)
        echo
        print_info "Installation instructions:"
        if [ "$os" = "mac" ]; then
            echo "  brew install git curl"
        elif [ "$os" = "linux" ]; then
            echo "  sudo apt-get update && sudo apt-get install git curl"
            echo "  # or for RPM-based: sudo yum install git curl"
        fi
        exit 1
    fi
}

# Install Hugo
install_hugo() {
    if command_exists hugo; then
        local hugo_version=$(hugo version | head -n 1)
        print_success "Hugo is already installed: $hugo_version"
        return 0
    fi
    
    print_step "Installing Hugo..."
    
    local os=$(detect_os)
    local install_success=false
    
    case $os in
        "mac")
            if command_exists brew; then
                brew install hugo && install_success=true
            else
                print_warning "Homebrew not found. Installing Hugo manually..."
                # Download latest Hugo for macOS
                local hugo_url="https://github.com/gohugoio/hugo/releases/download/v0.148.1/hugo_extended_0.148.1_darwin-universal.tar.gz"
                curl -L -o /tmp/hugo.tar.gz "$hugo_url"
                tar -xzf /tmp/hugo.tar.gz -C /tmp
                sudo mv /tmp/hugo /usr/local/bin/
                install_success=true
            fi
            ;;
        "linux")
            # Try package managers
            if command_exists apt-get; then
                sudo apt-get update && sudo apt-get install -y hugo && install_success=true
            elif command_exists yum; then
                sudo yum install -y hugo && install_success=true
            elif command_exists snap; then
                sudo snap install hugo --channel=extended && install_success=true
            else
                print_warning "Package manager not found. Installing Hugo manually..."
                # Download latest Hugo for Linux
                local hugo_url="https://github.com/gohugoio/hugo/releases/download/v0.148.1/hugo_extended_0.148.1_linux-amd64.tar.gz"
                curl -L -o /tmp/hugo.tar.gz "$hugo_url"
                tar -xzf /tmp/hugo.tar.gz -C /tmp
                sudo mv /tmp/hugo /usr/local/bin/
                install_success=true
            fi
            ;;
        *)
            print_error "Unsupported operating system: $os"
            print_info "Please install Hugo manually from: https://gohugo.io/installation/"
            exit 1
            ;;
    esac
    
    if [ "$install_success" = true ]; then
        print_success "Hugo installed successfully"
    else
        print_error "Failed to install Hugo"
        exit 1
    fi
}

# Install Quarto
install_quarto() {
    if command_exists quarto; then
        local quarto_version=$(quarto --version 2>/dev/null || echo "version unknown")
        print_success "Quarto is already installed: $quarto_version"
        return 0
    fi
    
    print_step "Installing Quarto..."
    
    local os=$(detect_os)
    local install_success=false
    
    case $os in
        "mac")
            if command_exists brew; then
                brew install --cask quarto && install_success=true
            else
                print_warning "Homebrew not found. Please install Quarto manually."
                print_info "Download from: https://quarto.org/docs/get-started/"
                print_info "After installation, run this script again."
                exit 1
            fi
            ;;
        "linux")
            print_info "Installing Quarto for Linux..."
            local quarto_url="https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.450/quarto-1.3.450-linux-amd64.deb"
            curl -L -o /tmp/quarto.deb "$quarto_url"
            
            if command_exists dpkg; then
                sudo dpkg -i /tmp/quarto.deb && install_success=true
            else
                print_warning "dpkg not found. Please install Quarto manually."
                print_info "Download from: https://quarto.org/docs/get-started/"
                exit 1
            fi
            ;;
        *)
            print_error "Unsupported operating system for automatic Quarto installation"
            print_info "Please install Quarto manually from: https://quarto.org/docs/get-started/"
            exit 1
            ;;
    esac
    
    if [ "$install_success" = true ]; then
        print_success "Quarto installed successfully"
    else
        print_error "Failed to install Quarto"
        exit 1
    fi
}

# Install optional tools
install_optional_tools() {
    print_step "Installing optional tools..."
    
    # Pandoc (recommended)
    if ! command_exists pandoc; then
        print_info "Installing Pandoc (recommended for better table conversion)..."
        local os=$(detect_os)
        case $os in
            "mac")
                command_exists brew && brew install pandoc
                ;;
            "linux")
                if command_exists apt-get; then
                    sudo apt-get install -y pandoc
                elif command_exists yum; then
                    sudo yum install -y pandoc
                fi
                ;;
        esac
        
        if command_exists pandoc; then
            print_success "Pandoc installed"
        else
            print_warning "Pandoc installation failed (optional)"
        fi
    else
        print_success "Pandoc is already installed"
    fi
}

# Clone repository
clone_repository() {
    print_step "Downloading Hugo + Quarto Documentation System..."
    
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Directory $INSTALL_DIR already exists"
        if [ ! -t 0 ]; then
            # Non-interactive mode: backup existing directory
            local backup_dir="${INSTALL_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
            mv "$INSTALL_DIR" "$backup_dir"
            print_info "Existing directory backed up to $backup_dir"
        else
            read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "$INSTALL_DIR"
                print_info "Removed existing directory"
            else
                print_info "Installation cancelled"
                exit 0
            fi
        fi
    fi
    
    git clone "$REPO_URL" "$INSTALL_DIR"
    print_success "Repository cloned to $INSTALL_DIR"
}

# Setup application
setup_application() {
    print_step "Setting up application..."
    
    cd "$INSTALL_DIR"
    
    # Make scripts executable
    chmod +x build.sh setup.sh launch.sh
    
    # Copy sample content to get started
    if [ -d "content-sample" ] && [ ! -d "content" ]; then
        cp -r content-sample/ content/
        print_success "Sample content copied to content/"
    fi
    
    # Test Hugo build
    print_info "Testing Hugo build..."
    if hugo --quiet; then
        print_success "Hugo build test successful"
    else
        print_warning "Hugo build test failed (you may need to add content)"
    fi
}

# Create desktop shortcut (optional)
create_shortcuts() {
    print_step "Creating shortcuts..."
    
    # Make sure launch.sh is executable
    chmod +x "$INSTALL_DIR/launch.sh"
    
    # Try to create desktop shortcut on macOS
    if [[ $(detect_os) == "mac" ]]; then
        local desktop_file="$HOME/Desktop/Hugo Docs.command"
        echo "#!/bin/bash" > "$desktop_file"
        echo "cd '$INSTALL_DIR' && ./launch.sh" >> "$desktop_file"
        chmod +x "$desktop_file"
        print_success "Desktop shortcut created: Hugo Docs.command"
    fi
    
    print_success "Launch script ready: $INSTALL_DIR/launch.sh"
}

# Print completion message
print_completion() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  🎉 Installation completed successfully!                    ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    print_info "What's next:"
    echo "  1. Navigate to your documentation directory:"
    echo "     cd $INSTALL_DIR"
    echo
    echo "  2. Start the documentation system:"
    echo "     ./launch.sh"
    echo "     # or: hugo serve"
    echo
    echo "  3. Open your browser and visit:"
    echo "     http://localhost:1313"
    echo
    echo "  4. Add your content to the content/ directory"
    echo
    print_info "For help and documentation:"
    echo "  • README: $INSTALL_DIR/README.md"
    echo "  • Setup guide: Run './setup.sh' for interactive setup"
    echo "  • GitHub: https://github.com/accionlabs/hugo-quarto-docs"
    echo
    print_success "Happy documenting! 📚"
}

# Main installation function
main() {
    print_header
    
    # Check if user wants to proceed (auto-yes if non-interactive)
    echo "This installer will:"
    echo "  • Install Hugo (static site generator)"
    echo "  • Install Quarto (document processor)"
    echo "  • Install Pandoc (optional, for better table conversion)"
    echo "  • Download the documentation system to: $INSTALL_DIR"
    echo "  • Set up sample content to get you started"
    echo
    
    # Check if running non-interactively (piped from curl)
    if [ ! -t 0 ]; then
        print_info "Running in non-interactive mode, proceeding with installation..."
    else
        read -p "Continue with installation? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
    
    check_prerequisites
    install_hugo
    install_quarto
    install_optional_tools
    clone_repository
    setup_application
    create_shortcuts
    print_completion
}

# Run main function
main "$@"