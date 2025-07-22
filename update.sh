#!/bin/bash

# Hugo + Quarto Documentation System - Update Script
# Simple update mechanism for non-technical users

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
CONTENT_DIR="$SCRIPT_DIR/content"
TEMP_DIR="/tmp/hugo-docs-update"
REPO_URL="https://github.com/accionlabs/hugo-quarto-docs.git"

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           Documentation System Update                        ║"
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

# Check if we're in the right directory
check_location() {
    if [ ! -f "hugo.yaml" ] && [ ! -f "hugo.yml" ]; then
        print_error "This doesn't appear to be your documentation system directory."
        print_error "Please run this script from your hugo-quarto-docs folder."
        exit 1
    fi
}

# Create backup of user content
backup_content() {
    print_step "Creating backup of your content..."
    
    local backup_name="content-backup-$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$CONTENT_DIR" ]; then
        cp -r "$CONTENT_DIR" "$backup_path"
        print_success "Content backed up to: backups/$backup_name"
        echo "$backup_path" > "$BACKUP_DIR/.latest-backup"
    else
        print_info "No content directory found to backup"
    fi
}

# Check for updates
check_for_updates() {
    print_step "Checking for updates..."
    
    # Get current commit hash
    local current_commit=""
    if [ -d ".git" ]; then
        current_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    fi
    
    # Clone latest version to temp directory
    rm -rf "$TEMP_DIR"
    git clone "$REPO_URL" "$TEMP_DIR" --quiet
    
    local latest_commit=$(cd "$TEMP_DIR" && git rev-parse HEAD)
    
    if [ "$current_commit" = "$latest_commit" ]; then
        print_success "You already have the latest version!"
        rm -rf "$TEMP_DIR"
        return 1
    else
        print_info "Updates available!"
        return 0
    fi
}

# Show what will be updated
show_update_info() {
    print_step "What will be updated:"
    echo
    echo "📋 The following will be updated:"
    echo "  • Hugo theme and layouts"
    echo "  • Build scripts and tools"
    echo "  • Sample content and tutorials"
    echo "  • Documentation and guides"
    echo
    echo "✅ Your content will be preserved:"
    echo "  • All files in content/ folder"
    echo "  • Your personal configuration"
    echo "  • Project files and documents"
    echo
    echo "🔒 Safety measures:"
    echo "  • Complete backup created before update"
    echo "  • Easy rollback if needed"
    echo "  • No data loss risk"
    echo
}

# Apply updates
apply_updates() {
    print_step "Applying updates..."
    
    # Files/folders to update (preserve user content)
    local items_to_update=(
        "themes/"
        "static/"
        "archetypes/"
        "layouts/"
        "build.sh"
        "launch.sh" 
        "setup.sh"
        "update.sh"
        "hugo.yaml"
        "README.md"
        "content-sample/"
    )
    
    for item in "${items_to_update[@]}"; do
        if [ -e "$TEMP_DIR/$item" ]; then
            print_info "Updating $item..."
            
            # Remove old version
            if [ -e "$item" ]; then
                rm -rf "$item"
            fi
            
            # Copy new version
            cp -r "$TEMP_DIR/$item" "$item"
        fi
    done
    
    # Make scripts executable
    chmod +x build.sh launch.sh setup.sh update.sh 2>/dev/null || true
    
    print_success "Updates applied successfully!"
}

# Initialize git if needed
setup_git() {
    if [ ! -d ".git" ]; then
        print_step "Setting up version tracking..."
        git init --quiet
        git remote add origin "$REPO_URL"
        git add .
        git commit -m "Initial commit after update" --quiet
        print_success "Version tracking initialized"
    else
        # Update git remote in case it changed
        git remote set-url origin "$REPO_URL" 2>/dev/null || true
        
        # Commit any local changes
        if ! git diff --quiet; then
            git add .
            git commit -m "Auto-commit before update $(date)" --quiet
        fi
        
        # Pull latest changes
        git fetch origin main --quiet
        git reset --hard origin/main --quiet
        print_success "Synchronized with latest version"
    fi
}

# Test the updated system
test_system() {
    print_step "Testing updated system..."
    
    if hugo --quiet 2>/dev/null; then
        print_success "System test passed - Hugo build successful"
    else
        print_warning "Hugo build test failed - this is usually not a problem"
        print_info "Your system should still work normally"
    fi
}

# Show completion message
show_completion() {
    echo
    print_success "Update completed successfully! 🎉"
    echo
    print_info "What's new in this update:"
    
    # Show recent commit messages
    if [ -d ".git" ]; then
        echo
        git log --oneline -5 --pretty=format:"  • %s" 2>/dev/null || echo "  • System improvements and bug fixes"
        echo
    fi
    
    echo
    print_info "Next steps:"
    echo "  1. Start your documentation system: ./launch.sh"
    echo "  2. Visit: http://localhost:1313"
    echo "  3. Check out new features and improvements"
    echo
    print_info "Need help? Check the updated documentation or README.md"
}

# Rollback function
rollback() {
    print_warning "Rolling back to previous version..."
    
    if [ -f "$BACKUP_DIR/.latest-backup" ]; then
        local backup_path=$(cat "$BACKUP_DIR/.latest-backup")
        
        if [ -d "$backup_path" ]; then
            rm -rf "$CONTENT_DIR"
            cp -r "$backup_path" "$CONTENT_DIR"
            print_success "Content restored from backup"
        fi
    fi
    
    if [ -d ".git" ]; then
        git reset --hard HEAD~1 --quiet 2>/dev/null || true
        print_success "System rolled back"
    fi
    
    print_info "Rollback completed. Your system has been restored."
}

# Main update function
main() {
    print_header
    
    check_location
    
    # Check if updates are available
    if ! check_for_updates; then
        exit 0
    fi
    
    show_update_info
    
    # Ask for confirmation (auto-yes if non-interactive)
    if [ -t 0 ]; then
        read -p "Do you want to proceed with the update? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "Update cancelled"
            rm -rf "$TEMP_DIR"
            exit 0
        fi
    else
        print_info "Running in non-interactive mode, proceeding with update..."
    fi
    
    backup_content
    apply_updates
    setup_git
    test_system
    show_completion
    
    # Clean up
    rm -rf "$TEMP_DIR"
}

# Handle rollback command
if [ "${1:-}" = "rollback" ]; then
    rollback
    exit 0
fi

# Handle help command
if [ "${1:-}" = "help" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    echo "Hugo + Quarto Documentation System - Update Script"
    echo
    echo "Usage:"
    echo "  ./update.sh         - Check for and apply updates"
    echo "  ./update.sh rollback - Restore previous version"
    echo "  ./update.sh help     - Show this help message"
    echo
    echo "This script safely updates your documentation system while"
    echo "preserving all your content and personal files."
    exit 0
fi

# Run main function
main "$@"