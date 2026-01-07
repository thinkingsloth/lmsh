# lmsh

LLM-powered command/script generator that converts natural language queries into executable commands and scripts.

> **Note:** This tool was generated using [Claude Opus 4.5](https://www.anthropic.com/claude).

## ⚠️ IMPORTANT WARNING

**This tool uses Large Language Models (LLMs) to generate commands. LLMs can make mistakes.**

- ❌ **Commands may be incorrect or dangerous**
- ❌ **Unpredictable behavior is possible**
- ❌ **Could potentially damage your system or data**
- ✅ **ALWAYS review commands before executing them**
- ✅ **Never blindly execute generated commands**

**YOU USE THIS TOOL ENTIRELY AT YOUR OWN RISK.**

By using lmsh, you acknowledge that you understand these risks and accept full responsibility for any commands you choose to execute.

## Features

- 🤖 **Natural Language to Code** - Describe what you want in plain English, get executable commands
- 🔄 **Multiple Output Formats** - Generate bash, Python, Node.js, Ruby, Perl scripts, or let the LLM choose
- 🎯 **Smart Auto Mode** - Automatically selects the best tool for the task
- 🔍 **Environment Aware** - Detects your shell and available interpreters
- 🚀 **Zero Dependencies** - Uses only Python standard library
- ⚡ **Fast** - Powered by uv for quick execution

## Installation

### Prerequisites

- [uv](https://docs.astral.sh/uv/) (required)

### Install lmsh

```bash
curl -sSf https://raw.githubusercontent.com/thinkingsloth/lmsh/main/install.sh | sh
```

### Configuration

Configure for your LLM provider:

#### OpenAI (Default)

```bash
export LMSH_API_TOKEN="sk-your-openai-api-key"
export LMSH_MODEL_ID="gpt-4o"
# Base URL defaults to https://api.openai.com/v1
```

#### Claude (Anthropic)

```bash
export LMSH_BASE_URL="https://api.anthropic.com/v1"
export LMSH_API_TOKEN="sk-ant-your-anthropic-key"
export LMSH_MODEL_ID="claude-opus-4-20250514"
```

#### Local vLLM Server

```bash
export LMSH_BASE_URL="http://127.0.0.1:8000/v1"
export LMSH_API_TOKEN="dummy"
export LMSH_MODEL_ID="your-model-name"
```

Add these to your `~/.bashrc` or `~/.zshrc` to make them permanent.

## Usage

### Basic Usage

```bash
lmsh <query>
```

### Command Options

```
--base-url=<url>      API endpoint URL
                      (default: $LMSH_BASE_URL or https://api.openai.com/v1)
--api-token=<token>   API authentication token (default: $LMSH_API_TOKEN)
--model-id=<model>    Model ID to use (default: $LMSH_MODEL_ID)
--output=<format>     Output format: bash, sh, zsh, python, python3, node, ruby, perl
                      (default: $LMSH_OUTPUT or current shell)
--allow-sudo          Allow sudo commands (default: $LMSH_ALLOW_SUDO or false)
--version             Show version information
--help                Show help message
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `LMSH_BASE_URL` | API endpoint URL | `https://api.openai.com/v1` |
| `LMSH_API_TOKEN` | API authentication token | *Required* |
| `LMSH_MODEL_ID` | Model identifier | *Required* |
| `LMSH_OUTPUT` | Output format (bash, python, node, etc.) | Current shell |
| `LMSH_ALLOW_SUDO` | Allow sudo commands (true/false) | `false` |

## Examples

### Shell Commands (Default)

```bash
# Generate command
lmsh find all python files modified today
# Output: find . -name "*.py" -mtime 0

# Execute directly
eval "$(lmsh find all python files modified today)"

# Or pipe to bash
lmsh count lines in all txt files | bash

# Or save and execute
lmsh loop through numbers 1 to 10 and print them > cmd.sh
bash cmd.sh
```

### Python Output

```bash
# Generate Python code
lmsh --output=python read json file and print all keys
# Output: import json; data = json.load(open('file.json')); print(list(data.keys()))

# Execute with Python
lmsh --output=python list all files in current directory | python3

# Or save and run
lmsh --output=python parse json and calculate stats > script.py
python3 script.py
```

### Node.js Output

```bash
# Generate JavaScript code
lmsh --output=node read package.json and print dependencies
# Output: console.log(JSON.parse(require('fs').readFileSync('package.json', 'utf8')).dependencies)

# Execute with Node
lmsh --output=node get current directory files | node

# Or save and run
lmsh --output=node process json data > script.js
node script.js
```

### Other Languages

```bash
# Ruby
lmsh --output=ruby read file and count lines | ruby

# Perl
lmsh --output=perl process text file | perl
```

### Sudo Commands (When Needed)

By default, lmsh will not generate commands requiring sudo for safety. Enable when needed:

```bash
# Without --allow-sudo (default - safer)
lmsh install nginx
# Output: apt install nginx (will fail without sudo)

# With --allow-sudo enabled
lmsh --allow-sudo install nginx
# Output: sudo apt install nginx

# Or set environment variable
export LMSH_ALLOW_SUDO=true
lmsh install nginx
# Output: sudo apt install nginx
```

⚠️ **Security Note:** Only enable `--allow-sudo` when you trust the LLM and understand the commands being generated. Always review commands before executing them.

## Executing Generated Commands

lmsh outputs commands to stdout. You can execute them in several ways:

### 1. Direct Execution with eval

```bash
eval "$(lmsh find all large files)"
```

### 2. Pipe to Shell

```bash
lmsh find all large files | bash
```

### 3. Preview Then Execute with tee

Print the command to terminal before executing it:

```bash
# Shows the command, then executes it
lmsh say hello | tee /dev/tty | sh

# Works with any interpreter
lmsh --output=python read json file | tee /dev/tty | python3
lmsh --output=node get files | tee /dev/tty | node
```

### 4. Convenience Functions (Recommended)

Add to your `~/.bashrc` or `~/.bash_aliases`:

```bash
# Execute immediately
lm() {
    eval "$(lmsh "$@")"
}

# Preview then execute
lmp() {
    local cmd
    cmd=$(lmsh "$@")
    echo "Command: $cmd"
    read -p "Execute? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        eval "$cmd"
    fi
}

# Just preview without executing
lmshow() {
    lmsh "$@"
}
```

Then use:
```bash
lm find all python files         # Executes immediately
lmp delete old log files          # Shows command and asks for confirmation
lmshow list directory contents    # Just displays the command
```

## Supported Output Formats

- **Shell Scripts**: `bash`, `sh`, `zsh`, `fish`, `ksh`
- **Python**: `python`, `python3`
- **JavaScript**: `node`
- **Ruby**: `ruby`
- **Perl**: `perl`

## How It Works

1. **Environment Detection** - Detects your current shell and available interpreters
2. **Query Processing** - Sends your natural language query to an OpenAI-compatible API
3. **Smart Prompting** - Uses context-aware prompts with format-specific examples
4. **Output Generation** - Returns clean, executable commands (no markdown, no explanations)

## Supported Providers

lmsh works with any OpenAI-compatible API:

### Tested Providers
- **OpenAI** - GPT-4o, GPT-4, GPT-3.5
- **Anthropic Claude** - Claude Opus 4, Claude Sonnet 4
- **Local vLLM** - Any OpenAI-compatible local server
- **Azure OpenAI** - Enterprise deployments
- **LM Studio** - Local model serving
- **Ollama** - With OpenAI compatibility enabled

See [Configuration](#configuration) section for setup examples.

## Requirements

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) package manager
- Access to an OpenAI-compatible API

## Development

### Building from Source

The `lmsh` executable is generated from source files using the build script:

```bash
# Clone the repository
git clone <your-repo-url>
cd llm-command

# Build the executable
./build.sh

# Test the build
./lmsh --version
./lmsh --help
```

### Build Process

The build script (`build.sh`) does the following:
1. Reads configuration from `constants` file (version, default base URL)
2. Replaces placeholders in `lmsh.py` with actual values
3. Combines `lmsh_wrapper.sh` (bash wrapper) with the Python code
4. Updates `install.sh` with GitHub repository information
5. Creates the final `lmsh` executable

### Project Structure

```
llm-command/
├── constants            # Version and configuration constants
├── lmsh_wrapper.sh   # Bash wrapper (checks for uv)
├── lmsh.py          # Main Python code
├── build.sh            # Build script
├── install.sh          # Installation script
├── README.md
├── LICENSE
└── ...
```

### Configuration

Edit the `constants` file to change:
- `VERSION` - Version number
- `DEFAULT_BASE_URL` - Default API endpoint

Set GitHub repository in `build.sh`:
```bash
export GITHUB_USER="your-username"
export GITHUB_REPO="your-repo-name"
./build.sh
```

Or edit the defaults in `build.sh` directly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

When contributing:
1. Edit source files (`lmsh.py`, `lmsh_wrapper.sh`, `constants`)
2. Run `./build.sh` to generate the executable
3. Test your changes
4. Commit both source files and the built `lmsh`

## License

Copyright 2025 Thinking Sloth Labs, Inc.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Acknowledgments

- Powered by [uv](https://github.com/astral-sh/uv) for fast Python script execution
- Compatible with OpenAI and compatible APIs
