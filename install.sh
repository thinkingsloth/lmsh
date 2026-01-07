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

# Setup configuration
setup_config() {
    CONFIG_DIR="$HOME/.config/lmsh"
    CONFIG_FILE="$CONFIG_DIR/config"

    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "  Configuration Setup" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2

    # Check if config already exists
    if [ -f "$CONFIG_FILE" ]; then
        print_warning "Configuration file already exists: $CONFIG_FILE"
        printf "Overwrite existing configuration? [y/N] " >&2
        read -r response </dev/tty
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                ;;
            *)
                print_info "Keeping existing configuration"
                return 0
                ;;
        esac
    fi

    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    # Prompt for provider
    echo "Which LLM provider do you want to use?" >&2
    echo "" >&2
    echo "  1) Claude (Anthropic)" >&2
    echo "  2) ChatGPT (OpenAI)" >&2
    echo "  3) Custom OpenAI-compatible API" >&2
    echo "" >&2
    printf "Enter choice [1-3]: " >&2
    read -r provider_choice </dev/tty

    case "$provider_choice" in
        1)
            # Claude/Anthropic
            BASE_URL="https://api.anthropic.com/v1"
            echo "" >&2
            printf "Enter your Anthropic API token: " >&2
            read -r API_TOKEN </dev/tty
            echo "" >&2
            printf "Enter model ID (default: claude-sonnet-4.5-20250514): " >&2
            read -r MODEL_ID </dev/tty
            MODEL_ID=${MODEL_ID:-claude-sonnet-4.5-20250514}
            ;;
        2)
            # ChatGPT/OpenAI
            BASE_URL="https://api.openai.com/v1"
            echo "" >&2
            printf "Enter your OpenAI API token: " >&2
            read -r API_TOKEN </dev/tty
            echo "" >&2
            printf "Enter model ID (default: chatgpt-4o-latest): " >&2
            read -r MODEL_ID </dev/tty
            MODEL_ID=${MODEL_ID:-chatgpt-4o-latest}
            ;;
        3)
            # Custom
            echo "" >&2
            printf "Enter base URL (default: http://127.0.0.1:7980/v1): " >&2
            read -r BASE_URL </dev/tty
            BASE_URL=${BASE_URL:-http://127.0.0.1:7980/v1}
            echo "" >&2
            printf "Enter API token: " >&2
            read -r API_TOKEN </dev/tty
            echo "" >&2
            printf "Enter model ID: " >&2
            read -r MODEL_ID </dev/tty
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    # Validate inputs
    if [ -z "$API_TOKEN" ]; then
        print_error "API token is required"
        exit 1
    fi

    if [ -z "$MODEL_ID" ]; then
        print_error "Model ID is required"
        exit 1
    fi

    # Write config file
    print_info "Creating configuration file..."
    cat > "$CONFIG_FILE" <<EOF
# lmsh configuration file
# Edit this file to change your settings

# API endpoint URL
base_url=$BASE_URL

# API authentication token
api_token=$API_TOKEN

# Model ID to use
model_id=$MODEL_ID

# Default output format (bash, python, node, etc.)
# Defaults to current shell if not set
# output=bash

# Allow sudo commands (true/false)
# allow_sudo=false
EOF

    chmod 600 "$CONFIG_FILE"
    print_success "Configuration saved to $CONFIG_FILE"

    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    print_success "lmsh installed and configured successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2
    echo "Try it out:" >&2
    echo "" >&2
    printf "   ${GREEN}lmsh find all python files modified today${NC}\n" >&2
    printf "   ${GREEN}lmsh --output=python read json file and print keys${NC}\n" >&2
    printf "   ${GREEN}lmsh --help${NC}\n" >&2
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

    # Setup configuration
    setup_config
}

# Run the installer
main
