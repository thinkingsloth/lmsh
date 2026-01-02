#!/bin/sh
set -e

# lmshell installer
# Usage: curl -sSf https://raw.githubusercontent.com/USER/REPO/main/install.sh | sh

GITHUB_RAW_URL="https://raw.githubusercontent.com/USER/REPO/main/lmshell"
INSTALL_DIR=""
BINARY_NAME="lmshell"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    printf "${BLUE}ℹ${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}⚠${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}✗${NC} %s\n" "$1"
}

# Check if uv is installed
check_uv() {
    if ! command -v uv >/dev/null 2>&1; then
        print_error "uv is not installed"
        echo ""
        echo "lmshell requires uv to run. To install uv, run:"
        echo ""
        printf "  ${GREEN}curl -LsSf https://astral.sh/uv/install.sh | sh${NC}\n"
        echo ""
        echo "For more information, visit: https://docs.astral.sh/uv/"
        echo ""
        exit 1
    fi
    print_success "uv is installed"
}

# Determine install directory
determine_install_dir() {
    # Try /usr/local/bin first (requires sudo)
    if [ -w "/usr/local/bin" ]; then
        INSTALL_DIR="/usr/local/bin"
    # Try ~/.local/bin (user directory)
    elif [ -d "$HOME/.local/bin" ]; then
        INSTALL_DIR="$HOME/.local/bin"
    # Create ~/.local/bin if it doesn't exist
    else
        mkdir -p "$HOME/.local/bin"
        INSTALL_DIR="$HOME/.local/bin"
    fi

    print_info "Installing to: $INSTALL_DIR"
}

# Check if curl or wget is available
check_download_tool() {
    if command -v curl >/dev/null 2>&1; then
        DOWNLOAD_TOOL="curl"
    elif command -v wget >/dev/null 2>&1; then
        DOWNLOAD_TOOL="wget"
    else
        print_error "Neither curl nor wget found"
        echo "Please install curl or wget and try again"
        exit 1
    fi
}

# Download the script
download_lmshell() {
    print_info "Downloading lmshell from GitHub..."

    TEMP_FILE=$(mktemp)

    if [ "$DOWNLOAD_TOOL" = "curl" ]; then
        if curl -fsSL "$GITHUB_RAW_URL" -o "$TEMP_FILE"; then
            print_success "Downloaded successfully"
        else
            print_error "Failed to download lmshell"
            rm -f "$TEMP_FILE"
            exit 1
        fi
    else
        if wget -q "$GITHUB_RAW_URL" -O "$TEMP_FILE"; then
            print_success "Downloaded successfully"
        else
            print_error "Failed to download lmshell"
            rm -f "$TEMP_FILE"
            exit 1
        fi
    fi

    echo "$TEMP_FILE"
}

# Install the script
install_lmshell() {
    TEMP_FILE=$1
    INSTALL_PATH="$INSTALL_DIR/$BINARY_NAME"

    print_info "Installing lmshell..."

    # Copy to install directory
    if cp "$TEMP_FILE" "$INSTALL_PATH"; then
        chmod +x "$INSTALL_PATH"
        rm -f "$TEMP_FILE"
        print_success "Installed to $INSTALL_PATH"
    else
        print_error "Failed to install lmshell"
        print_warning "You may need to run with sudo or install to a different directory"
        rm -f "$TEMP_FILE"
        exit 1
    fi
}

# Check if install directory is in PATH
check_path() {
    case ":$PATH:" in
        *":$INSTALL_DIR:"*)
            print_success "$INSTALL_DIR is in your PATH"
            ;;
        *)
            print_warning "$INSTALL_DIR is not in your PATH"
            echo ""
            echo "Add it to your PATH by adding this line to your shell config:"
            echo ""
            if [ "$INSTALL_DIR" = "$HOME/.local/bin" ]; then
                printf "  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n"
            else
                printf "  ${GREEN}export PATH=\"$INSTALL_DIR:\$PATH\"${NC}\n"
            fi
            echo ""
            echo "Then restart your shell or run:"
            printf "  ${GREEN}source ~/.bashrc${NC}  # or ~/.zshrc, depending on your shell\n"
            echo ""
            ;;
    esac
}

# Print configuration instructions
print_config_instructions() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "lmshell installed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Configure environment variables:"
    echo ""
    printf "   ${GREEN}export LMSHELL_API_TOKEN=\"your-api-token\"${NC}\n"
    printf "   ${GREEN}export LMSHELL_MODEL_ID=\"your-model-id\"${NC}\n"
    echo ""
    echo "   Optional:"
    printf "   ${GREEN}export LMSHELL_BASE_URL=\"http://127.0.0.1:7980/v1\"${NC}  # Default\n"
    printf "   ${GREEN}export LMSHELL_OUTPUT=\"auto\"${NC}                        # Default: current shell\n"
    printf "   ${GREEN}export LMSHELL_ALLOW_SUDO=\"false\"${NC}                   # Default: false\n"
    echo ""
    echo "2. Try it out:"
    echo ""
    printf "   ${GREEN}lmshell find all python files modified today${NC}\n"
    printf "   ${GREEN}lmshell --output=python read json file and print keys${NC}\n"
    printf "   ${GREEN}lmshell --help${NC}\n"
    echo ""
    echo "3. For convenience, add helper functions to ~/.bashrc:"
    echo ""
    printf "   ${GREEN}# Execute immediately${NC}\n"
    printf "   ${GREEN}lm() { eval \"\$(lmshell \"\$@\")\"; }${NC}\n"
    echo ""
    printf "   ${GREEN}# Preview then execute${NC}\n"
    printf "   ${GREEN}lmp() {${NC}\n"
    printf "   ${GREEN}    local cmd; cmd=\$(lmshell \"\$@\")${NC}\n"
    printf "   ${GREEN}    echo \"Command: \$cmd\"${NC}\n"
    printf "   ${GREEN}    read -p \"Execute? [y/N] \" -n 1 -r; echo${NC}\n"
    printf "   ${GREEN}    [[ \$REPLY =~ ^[Yy]\$ ]] && eval \"\$cmd\"${NC}\n"
    printf "   ${GREEN}}${NC}\n"
    echo ""
    echo "For more information, visit:"
    echo "  https://github.com/USER/REPO"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  lmshell installer"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check prerequisites
    print_info "Checking prerequisites..."
    check_uv
    check_download_tool

    # Determine where to install
    determine_install_dir

    # Download the script
    TEMP_FILE=$(download_lmshell)

    # Install it
    install_lmshell "$TEMP_FILE"

    # Check PATH
    check_path

    # Show configuration instructions
    print_config_instructions
}

# Run the installer
main
