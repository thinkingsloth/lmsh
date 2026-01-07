#!/bin/sh
set -e

# lmsh uninstaller
# Usage: curl -sSf https://raw.githubusercontent.com/thinkingsloth/lmsh/main/uninstall.sh | sh

BINARY_NAME="lmsh"
POSSIBLE_LOCATIONS="/usr/local/bin/$BINARY_NAME $HOME/.local/bin/$BINARY_NAME"
CONFIG_DIR="$HOME/.config/lmsh"

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

# Find installed lmsh binary
find_lmsh() {
    for location in $POSSIBLE_LOCATIONS; do
        if [ -f "$location" ]; then
            echo "$location"
            return 0
        fi
    done
    return 1
}

# Remove lmsh binary
remove_binary() {
    LMSH_PATH=$1

    print_info "Removing $LMSH_PATH..."

    if rm -f "$LMSH_PATH" 2>/dev/null; then
        print_success "Removed lmsh binary"
        return 0
    else
        print_error "Failed to remove $LMSH_PATH"
        print_warning "You may need to run with sudo:"
        echo "" >&2
        printf "  ${GREEN}curl -sSf https://raw.githubusercontent.com/thinkingsloth/lmsh/main/uninstall.sh | sudo sh${NC}\n" >&2
        echo "" >&2
        return 1
    fi
}

# Ask about removing config directory
remove_config() {
    if [ ! -d "$CONFIG_DIR" ]; then
        return 0
    fi

    echo "" >&2
    print_warning "Configuration directory found: $CONFIG_DIR"
    echo "" >&2
    printf "Remove configuration directory? [y/N] " >&2
    read -r response

    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            if rm -rf "$CONFIG_DIR" 2>/dev/null; then
                print_success "Removed configuration directory"
            else
                print_error "Failed to remove configuration directory"
            fi
            ;;
        *)
            print_info "Keeping configuration directory"
            ;;
    esac
}

# Main uninstallation flow
main() {
    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "  lmsh uninstaller" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2

    # Find lmsh installation
    print_info "Looking for lmsh installation..."

    if LMSH_PATH=$(find_lmsh); then
        print_success "Found lmsh at: $LMSH_PATH"

        # Remove the binary
        if remove_binary "$LMSH_PATH"; then
            # Ask about config directory
            remove_config

            echo "" >&2
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            print_success "lmsh has been uninstalled successfully!"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            echo "" >&2
            echo "To reinstall lmsh in the future, visit:" >&2
            echo "  https://github.com/thinkingsloth/lmsh" >&2
            echo "" >&2
        else
            exit 1
        fi
    else
        print_warning "lmsh is not installed"
        echo "" >&2
        echo "Searched in:" >&2
        for location in $POSSIBLE_LOCATIONS; do
            echo "  - $location" >&2
        done
        echo "" >&2
        exit 1
    fi
}

# Run the uninstaller
main
