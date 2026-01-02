#!/bin/bash

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: 'uv' is not installed." >&2
    echo "" >&2
    echo "To install uv, run:" >&2
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
    echo "" >&2
    echo "For more information, visit: https://docs.astral.sh/uv/" >&2
    exit 1
fi

# Execute the Python script using uv
exec uv run --python 3.11 - "$@" <<'PYTHON_SCRIPT'
