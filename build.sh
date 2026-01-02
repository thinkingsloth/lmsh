#!/bin/bash
set -e

# Build script for lmshell
# This script combines the wrapper and Python code into a single executable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    printf "${BLUE}ℹ${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}✗${NC} %s\n" "$1"
}

# Configuration - Update these values for your repository
GITHUB_USER="${GITHUB_USER:-USER}"
GITHUB_REPO="${GITHUB_REPO:-REPO}"

# File paths
CONSTANTS_FILE="constants"
WRAPPER_FILE="lmshell_wrapper.sh"
PYTHON_FILE="lmshell.py"
INSTALL_FILE="install.sh"
OUTPUT_FILE="lmshell"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Building lmshell"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if required files exist
print_info "Checking required files..."
if [ ! -f "$CONSTANTS_FILE" ]; then
    print_error "constants file not found"
    exit 1
fi
if [ ! -f "$WRAPPER_FILE" ]; then
    print_error "lmshell_wrapper.sh not found"
    exit 1
fi
if [ ! -f "$PYTHON_FILE" ]; then
    print_error "lmshell.py not found"
    exit 1
fi
if [ ! -f "$INSTALL_FILE" ]; then
    print_error "install.sh not found"
    exit 1
fi
print_success "All required files found"

# Read constants
print_info "Reading constants..."
source "$CONSTANTS_FILE"
if [ -z "$VERSION" ]; then
    print_error "VERSION not found in constants file"
    exit 1
fi
if [ -z "$DEFAULT_BASE_URL" ]; then
    print_error "DEFAULT_BASE_URL not found in constants file"
    exit 1
fi
print_info "Version: $VERSION"
print_info "Default Base URL: $DEFAULT_BASE_URL"
print_info "GitHub: $GITHUB_USER/$GITHUB_REPO"

# Create temporary directory for build
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

# Process Python file - replace placeholders
print_info "Processing Python code..."
sed -e "s|__VERSION__|$VERSION|g" \
    -e "s|__DEFAULT_BASE_URL__|$DEFAULT_BASE_URL|g" \
    "$PYTHON_FILE" > "$BUILD_DIR/lmshell.py"

# Combine wrapper and Python code
print_info "Combining wrapper and Python code..."
cat "$WRAPPER_FILE" > "$OUTPUT_FILE"
cat "$BUILD_DIR/lmshell.py" >> "$OUTPUT_FILE"
echo "PYTHON_SCRIPT" >> "$OUTPUT_FILE"

# Make executable
chmod +x "$OUTPUT_FILE"
print_success "Created $OUTPUT_FILE"

# Update install.sh with GitHub info
print_info "Updating install.sh with GitHub repository..."
sed "s|USER/REPO|$GITHUB_USER/$GITHUB_REPO|g" "$INSTALL_FILE" > "$BUILD_DIR/install.sh.tmp"
mv "$BUILD_DIR/install.sh.tmp" "$INSTALL_FILE"
print_success "Updated install.sh"

# Show file sizes
LMSHELL_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
print_success "Build complete! ($LMSHELL_SIZE)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Build Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Version:    $VERSION"
echo "Output:     $OUTPUT_FILE ($LMSHELL_SIZE)"
echo "Repository: https://github.com/$GITHUB_USER/$GITHUB_REPO"
echo ""
echo "Next steps:"
echo "  1. Test the build:"
echo "     ./$OUTPUT_FILE --version"
echo "     ./$OUTPUT_FILE --help"
echo ""
echo "  2. Commit and push:"
echo "     git add ."
echo "     git commit -m \"Release v$VERSION\""
echo "     git push"
echo ""
echo "  3. Users can install with:"
echo "     curl -sSf https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main/install.sh | sh"
echo ""
