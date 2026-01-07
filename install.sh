#!/bin/sh
set -e

# lmsh installer
# Usage: curl -sSf https://raw.githubusercontent.com/thinkingsloth/lmsh/main/install.sh | sh

GITHUB_RAW_URL="https://raw.githubusercontent.com/thinkingsloth/lmsh/main/lmsh"
INSTALL_DIR=""
BINARY_NAME="lmsh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output (to stderr to avoid interfering with return values)
print_info() {
    printf "${BLUE}ℹ${NC} %s\n" "$1" >&2
}

print_success() {
    printf "${GREEN}✓${NC} %s\n" "$1" >&2
}

print_warning() {
    printf "${YELLOW}⚠${NC} %s\n" "$1" >&2
}

print_error() {
    printf "${RED}✗${NC} %s\n" "$1" >&2
}

# Check if uv is installed
check_uv() {
    if ! command -v uv >/dev/null 2>&1; then
        print_error "uv is not installed"
        echo "" >&2
        echo "lmsh requires uv to run. To install uv, run:" >&2
        echo "" >&2
        printf "  ${GREEN}curl -LsSf https://astral.sh/uv/install.sh | sh${NC}\n" >&2
        echo "" >&2
        echo "For more information, visit: https://docs.astral.sh/uv/" >&2
        echo "" >&2
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
        echo "Please install curl or wget and try again" >&2
        exit 1
    fi
}

# Download the script
download_lmsh() {
    print_info "Downloading lmsh from GitHub..."

    TEMP_FILE=$(mktemp)

    if [ "$DOWNLOAD_TOOL" = "curl" ]; then
        if curl -fsSL "$GITHUB_RAW_URL" -o "$TEMP_FILE"; then
            print_success "Downloaded successfully"
        else
            print_error "Failed to download lmsh"
            rm -f "$TEMP_FILE"
            exit 1
        fi
    else
        if wget -q "$GITHUB_RAW_URL" -O "$TEMP_FILE"; then
            print_success "Downloaded successfully"
        else
            print_error "Failed to download lmsh"
            rm -f "$TEMP_FILE"
            exit 1
        fi
    fi

    echo "$TEMP_FILE"
}

# Install the script
install_lmsh() {
    TEMP_FILE=$1
    INSTALL_PATH="$INSTALL_DIR/$BINARY_NAME"

    print_info "Installing lmsh..."

    # Copy to install directory
    if cp "$TEMP_FILE" "$INSTALL_PATH"; then
        chmod +x "$INSTALL_PATH"
        rm -f "$TEMP_FILE"
        print_success "Installed to $INSTALL_PATH"
    else
        print_error "Failed to install lmsh"
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
            echo "" >&2
            echo "Add it to your PATH by adding this line to your shell config:" >&2
            echo "" >&2
            if [ "$INSTALL_DIR" = "$HOME/.local/bin" ]; then
                printf "  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n" >&2
            else
                printf "  ${GREEN}export PATH=\"$INSTALL_DIR:\$PATH\"${NC}\n" >&2
            fi
            echo "" >&2
            echo "Then restart your shell or run:" >&2
            printf "  ${GREEN}source ~/.bashrc${NC}  # or ~/.zshrc, depending on your shell\n" >&2
            echo "" >&2
            ;;
    esac
}

# Print configuration instructions
print_config_instructions() {
    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    print_success "lmsh installed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2
    echo "Next steps:" >&2
    echo "" >&2
    echo "1. Configure environment variables:" >&2
    echo "" >&2
    printf "   ${GREEN}export LMSH_API_TOKEN=\"your-api-token\"${NC}\n" >&2
    printf "   ${GREEN}export LMSH_MODEL_ID=\"your-model-id\"${NC}\n" >&2
    echo "" >&2
    echo "   Optional:" >&2
    printf "   ${GREEN}export LMSH_BASE_URL=\"http://127.0.0.1:7980/v1\"${NC}  # Default\n" >&2
    printf "   ${GREEN}export LMSH_OUTPUT=\"auto\"${NC}                        # Default: current shell\n" >&2
    printf "   ${GREEN}export LMSH_ALLOW_SUDO=\"false\"${NC}                   # Default: false\n" >&2
    echo "" >&2
    echo "2. Try it out:" >&2
    echo "" >&2
    printf "   ${GREEN}lmsh find all python files modified today${NC}\n" >&2
    printf "   ${GREEN}lmsh --output=python read json file and print keys${NC}\n" >&2
    printf "   ${GREEN}lmsh --help${NC}\n" >&2
    echo "" >&2
    echo "3. For convenience, add helper functions to ~/.bashrc:" >&2
    echo "" >&2
    printf "   ${GREEN}# Execute immediately${NC}\n" >&2
    printf "   ${GREEN}lm() { eval \"\$(lmsh \"\$@\")\"; }${NC}\n" >&2
    echo "" >&2
    printf "   ${GREEN}# Preview then execute${NC}\n" >&2
    printf "   ${GREEN}lmp() {${NC}\n" >&2
    printf "   ${GREEN}    local cmd; cmd=\$(lmsh \"\$@\")${NC}\n" >&2
    printf "   ${GREEN}    echo \"Command: \$cmd\"${NC}\n" >&2
    printf "   ${GREEN}    read -p \"Execute? [y/N] \" -n 1 -r; echo${NC}\n" >&2
    printf "   ${GREEN}    [[ \$REPLY =~ ^[Yy]\$ ]] && eval \"\$cmd\"${NC}\n" >&2
    printf "   ${GREEN}}${NC}\n" >&2
    echo "" >&2
    echo "For more information, visit:" >&2
    echo "  https://github.com/thinkingsloth/lmsh" >&2
    echo "" >&2
}

# Main installation flow
main() {
    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "  lmsh installer" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2

    # Check prerequisites
    print_info "Checking prerequisites..."
    check_uv
    check_download_tool

    # Determine where to install
    determine_install_dir

    # Download the script
    TEMP_FILE=$(download_lmsh)

    # Install it
    install_lmsh "$TEMP_FILE"

    # Check PATH
    check_path

    # Show configuration instructions
    print_config_instructions
}

# Run the installer
main
