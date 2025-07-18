#!/bin/bash
# STAG Hugo Build Script with Quarto Integration
# Usage: ./build.sh [dev|prod]

set -e

MODE=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="$SCRIPT_DIR/content"
CACHE_DIR="$SCRIPT_DIR/.quarto_cache"
TEMP_DIR="$SCRIPT_DIR/.temp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}✅ ${1}${NC}"
}

log_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  ${1}${NC}"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v hugo &> /dev/null; then
        log_error "Hugo not found. Install with: brew install hugo"
        exit 1
    fi
    
    if ! command -v quarto &> /dev/null; then
        log_error "Quarto not found. Install with: brew install quarto"
        exit 1
    fi
    
    log_success "Dependencies check passed"
}

# Create necessary directories
setup_directories() {
    mkdir -p "$CACHE_DIR" "$TEMP_DIR"
    log_success "Directories created"
}

# Process .qmd files
convert_grid_tables_to_pipes() {
    log_info "Converting grid tables to pipe tables..."
    
    # Find all .qmd and .md files
    find "$CONTENT_DIR" -name "*.qmd" -o -name "*.md" | while read -r file; do
        local relative_path="${file#$CONTENT_DIR/}"
        
        # Check if file contains grid tables (lines with multiple dashes)
        if grep -q "^[[:space:]]*-\{3,\}.*-\{3,\}[[:space:]]*$" "$file"; then
            log_info "  → Converting tables in: $relative_path"
            
            # Create backup
            cp "$file" "${file}.backup"
            
            # Convert grid tables to pipe tables using pandoc
            if command -v pandoc &> /dev/null; then
                # Use pandoc to convert grid tables to pipe tables
                pandoc "$file" --from markdown --to gfm --wrap=none --output "$file.tmp" 2>/dev/null
                if [ $? -eq 0 ] && [ -f "$file.tmp" ]; then
                    mv "$file.tmp" "$file"
                    log_success "    ✓ Converted using pandoc"
                else
                    # Fallback: simple regex conversion for basic grid tables
                    python3 -c "
import re
import sys

def convert_grid_to_pipe(content):
    lines = content.split('\n')
    in_table = False
    table_lines = []
    result_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Detect start of grid table
        if re.match(r'^\\s*-{3,}.*-{3,}\\s*$', line):
            in_table = True
            table_lines = []
            # Skip the dashes line
            i += 1
            continue
            
        # Detect end of grid table
        if in_table and (re.match(r'^\\s*-{3,}.*-{3,}\\s*$', line) or line.strip() == ''):
            if table_lines:
                # Convert collected table lines to pipe format
                converted_table = convert_table_lines(table_lines)
                result_lines.extend(converted_table)
                table_lines = []
            in_table = False
            if line.strip() != '':
                result_lines.append(line)
        elif in_table:
            table_lines.append(line)
        else:
            result_lines.append(line)
        
        i += 1
    
    return '\\n'.join(result_lines)

def convert_table_lines(lines):
    if not lines:
        return []
    
    # Simple conversion: split by multiple spaces and create pipe table
    table_data = []
    for line in lines:
        if line.strip():
            # Split by multiple spaces (2 or more)
            cells = re.split(r'\\s{2,}', line.strip())
            table_data.append(cells)
    
    if not table_data:
        return []
    
    # Create pipe table
    pipe_table = []
    
    # Header
    if table_data:
        header = '| ' + ' | '.join(table_data[0]) + ' |'
        pipe_table.append(header)
        
        # Separator
        separator = '|' + '|'.join(['-' * (len(cell) + 2) for cell in table_data[0]]) + '|'
        pipe_table.append(separator)
        
        # Data rows
        for row in table_data[1:]:
            # Pad row to match header length
            while len(row) < len(table_data[0]):
                row.append('')
            row_str = '| ' + ' | '.join(row[:len(table_data[0])]) + ' |'
            pipe_table.append(row_str)
    
    return pipe_table

try:
    with open('$file', 'r', encoding='utf-8') as f:
        content = f.read()
    
    converted = convert_grid_to_pipe(content)
    
    with open('$file', 'w', encoding='utf-8') as f:
        f.write(converted)
    
    print('Converted grid tables to pipe tables')
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" && log_success "    ✓ Converted using Python fallback"
                fi
            else
                log_warning "    ⚠ Pandoc not available, skipping conversion"
            fi
        fi
    done
}

# Preprocess mermaid syntax to ensure consistency
preprocess_mermaid_syntax() {
    log_info "Preprocessing mermaid syntax for Hugo compatibility..."
    
    # Process all .qmd files to remove brackets for Hugo
    find "$CONTENT_DIR" -name "*.qmd" | while read -r file; do
        local relative_path="${file#$CONTENT_DIR/}"
        
        # Check if file contains {mermaid} syntax
        if grep -q '```{mermaid}' "$file"; then
            log_info "  → Removing brackets for Hugo compatibility in: $relative_path"
            
            # Convert {mermaid} to standard mermaid for Hugo processing
            sed -i.tmp 's/```{mermaid}/```mermaid/g' "$file"
            rm -f "${file}.tmp"
            
            log_success "    ✓ Removed brackets for Hugo compatibility"
        fi
    done
    
    log_success "Mermaid syntax preprocessing completed"
}

# New function to prepare mermaid syntax for Quarto rendering
prepare_mermaid_for_quarto() {
    local temp_file="$1"
    
    # Convert ```mermaid to ```{mermaid} for Quarto compatibility
    if grep -q '```mermaid' "$temp_file"; then
        sed -i.tmp 's/```mermaid/```{mermaid}/g' "$temp_file"
        rm -f "${temp_file}.tmp"
    fi
}

process_quarto_files() {
    log_info "Processing Quarto files..."
    
    local qmd_count=0
    local processed_count=0
    
    # Find all .qmd files
    while IFS= read -r -d '' qmd_file; do
        ((qmd_count++))
        
        local relative_path="${qmd_file#$CONTENT_DIR/}"
        local dir_name="$(dirname "$qmd_file")"
        local base_name="$(basename "$qmd_file" .qmd)"
        
        log_info "Processing: $relative_path"
        
        # Create temporary directory for this file
        local temp_file_dir="$TEMP_DIR/$(dirname "$relative_path")"
        mkdir -p "$temp_file_dir"
        
        # Copy file to temp directory
        cp "$qmd_file" "$temp_file_dir/"
        
        # Change to temp directory for processing
        cd "$temp_file_dir"
        
        # Extract front matter to check for exports
        local front_matter=$(awk '/^---$/{if(++n==2) exit} n>=1' "$base_name.qmd")
        local exports=$(echo "$front_matter" | grep "quarto_exports:" | sed 's/quarto_exports: *\[\(.*\)\]/\1/' | tr -d '"[]')
        
        # Hugo will treat QMD files as markdown directly, so we only need to generate exports
        log_success "  → QMD file will be processed by Hugo as markdown"
        
        # Generate exports if specified
        if [ -n "$exports" ]; then
            log_info "  → Checking exports: $exports"
            IFS=',' read -ra EXPORT_FORMATS <<< "$exports"
            local needs_render=false
            local formats_to_render=()
            
            # Check if any export files are missing or older than source
            for format in "${EXPORT_FORMATS[@]}"; do
                format=$(echo "$format" | xargs) # trim whitespace
                local export_file="$dir_name/$base_name.$format"
                
                if [ ! -f "$export_file" ]; then
                    log_info "    → $format export missing, will generate"
                    needs_render=true
                    formats_to_render+=("$format")
                elif [ "$qmd_file" -nt "$export_file" ]; then
                    log_info "    → $format export outdated, will regenerate"
                    needs_render=true
                    formats_to_render+=("$format")
                else
                    log_info "    → $format export up to date, skipping"
                fi
            done
            
            # Only render if needed
            if [ "$needs_render" = true ]; then
                log_info "  → Rendering needed formats: ${formats_to_render[*]}"
                
                # Prepare mermaid syntax for Quarto before rendering
                prepare_mermaid_for_quarto "$base_name.qmd"
                
                for format in "${formats_to_render[@]}"; do
                    if quarto render "$base_name.qmd" --to "$format" --quiet; then
                        # Copy export files back to content directory
                        if [ -f "$base_name.$format" ]; then
                            cp "$base_name.$format" "$dir_name/"
                            log_success "    ✓ Created: $base_name.$format"
                            
                            # Also copy to static directory to make it accessible via URL
                            local relative_static_path="${dir_name#$CONTENT_DIR/}"
                            local static_dir="$SCRIPT_DIR/static/$relative_static_path"
                            mkdir -p "$static_dir"
                            cp "$base_name.$format" "$static_dir/"
                            log_success "    ✓ Copied to static: $static_dir/$base_name.$format"
                        fi
                    else
                        log_warning "    ⚠ Failed to create: $base_name.$format"
                    fi
                done
                
                # Revert mermaid syntax back to Hugo format after rendering
                if grep -q '```{mermaid}' "$base_name.qmd"; then
                    sed -i.tmp 's/```{mermaid}/```mermaid/g' "$base_name.qmd"
                    rm -f "${base_name.qmd}.tmp"
                fi
            else
                log_success "  → All exports up to date, skipping render"
            fi
        fi
        
        ((processed_count++))
        
        cd "$SCRIPT_DIR"
        
    done < <(find "$CONTENT_DIR" -name "*.qmd" -type f -print0)
    
    log_success "Processed $processed_count/$qmd_count Quarto files"
}

# Build Hugo site
build_hugo() {
    log_info "Building Hugo site..."
    
    if [ "$MODE" = "dev" ]; then
        hugo --buildDrafts --buildFuture
    else
        hugo --minify
    fi
    
    log_success "Hugo build completed"
}

# Function to automatically create missing _index.md files
auto_create_missing_indexes() {
    log_info "Checking for missing _index.md files..."
    
    # Find all directories in content that don't have _index.md
    find "$CONTENT_DIR" -type d -not -path "$CONTENT_DIR" | while read -r dir; do
        local index_file="$dir/_index.md"
        
        if [ ! -f "$index_file" ]; then
            local relative_path="${dir#$CONTENT_DIR/}"
            log_info "Creating missing index for: $relative_path"
            
            # Extract directory name and create title
            local dir_name="$(basename "$dir")"
            local section_name=$(echo "$dir_name" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
            
            # Determine section type and description
            local section_type=""
            local description=""
            local auto_description=""
            
            if [[ "$relative_path" == projects/* ]]; then
                section_type="project"
                auto_description="Client work and project deliverables"
            elif [[ "$relative_path" == shared/* ]]; then
                section_type="shared"  
                auto_description="STAG team resources and templates"
            elif [[ "$relative_path" == private/* ]]; then
                section_type="private"
                auto_description="Personal methodologies and confidential information (local-only)"
            else
                auto_description="Documentation and resources"
            fi
            
            # Try to extract title and metadata from existing files in directory
            local extracted_title=""
            local extracted_description=""
            local extracted_team=""
            local extracted_client=""
            
            # Look for markdown files in the directory to extract metadata
            local first_md_file=$(find "$dir" -maxdepth 1 \( -name "*.md" -o -name "*.qmd" \) | head -1)
            if [ -f "$first_md_file" ]; then
                # Extract title from front matter or first heading
                extracted_title=$(awk '/^---$/{if(++n==2) exit} n>=1' "$first_md_file" | grep "^title:" | sed 's/^title: *//; s/^["'\'']//' | sed 's/["'\'']$//')
                if [ -z "$extracted_title" ]; then
                    extracted_title=$(grep "^# " "$first_md_file" | head -1 | sed 's/^# *//')
                fi
                
                # Extract other metadata
                extracted_description=$(awk '/^---$/{if(++n==2) exit} n>=1' "$first_md_file" | grep "^description:" | sed 's/^description: *//; s/^["'\'']//' | sed 's/["'\'']$//')
                extracted_team=$(awk '/^---$/{if(++n==2) exit} n>=1' "$first_md_file" | grep "^team:" | sed 's/^team: *//')
                extracted_client=$(awk '/^---$/{if(++n==2) exit} n>=1' "$first_md_file" | grep "^client:" | sed 's/^client: *//; s/^["'\'']//' | sed 's/["'\'']$//')
            fi
            
            # Use extracted title or generate from directory name
            local final_title="${extracted_title:-$section_name}"
            local final_description="${extracted_description:-$auto_description}"
            
            # Create the _index.md file
            cat > "$index_file" << EOF
---
title: "$final_title"
description: "$final_description" 
date: $(date +%Y-%m-%d)
EOF

            # Add team information if extracted
            if [ -n "$extracted_team" ]; then
                echo "team:" >> "$index_file"
                echo "  - $extracted_team" >> "$index_file"
            fi

            # Add client information if extracted
            if [ -n "$extracted_client" ]; then
                echo "client: \"$extracted_client\"" >> "$index_file"
            fi

            # Add type for projects
            if [ "$section_type" = "project" ]; then
                echo "type: \"project\"" >> "$index_file"
            fi

            cat >> "$index_file" << EOF
---

# $final_title

$final_description

EOF

            # Add team section if team info exists
            if [ -n "$extracted_team" ]; then
                cat >> "$index_file" << EOF
## Team

- $extracted_team

EOF
            fi

            # Add client section if client info exists
            if [ -n "$extracted_client" ]; then
                cat >> "$index_file" << EOF
## Client

$extracted_client

EOF
            fi

            # Add section-specific content based on type
            case "$section_type" in
                "project")
                    cat >> "$index_file" << EOF
## Project Overview

<!-- Add project overview here -->

## Deliverables

<!-- List project deliverables here -->

## Resources

<!-- Add links to project resources here -->

EOF
                    ;;
                "shared")
                    cat >> "$index_file" << EOF
## Resources

<!-- Add shared resources here -->

## Documentation

<!-- Add documentation links here -->

EOF
                    ;;
            esac
            
            log_success "Created _index.md for: $relative_path"
        fi
    done
    
    log_success "Missing index file creation completed!"
}

# Clean up temporary files
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_success "Cleaned up temporary files"
    fi
}

# Main execution
main() {
    log_info "Starting STAG Hugo build (mode: $MODE)"
    
    check_dependencies
    setup_directories
    auto_create_missing_indexes
    convert_grid_tables_to_pipes
    preprocess_mermaid_syntax
    process_quarto_files
    build_hugo
    cleanup
    
    log_success "Build completed successfully!"
    
    if [ "$MODE" = "dev" ]; then
        log_info "Run 'hugo server' to start development server"
    fi
}

# Run main function
main "$@"