# Contributing to lmshell

Thank you for your interest in contributing to lmshell! We welcome contributions from the community.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, Python version, shell type)
- Relevant error messages

### Suggesting Features

Feature suggestions are welcome! Please open an issue describing:
- The use case for the feature
- How it should work
- Example usage

### Pull Requests

1. **Fork the repository**

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Keep functions well-commented
   - Test your changes with different output formats

4. **Test thoroughly**
   ```bash
   # Test basic functionality
   ./lmshell --output=bash say hello
   ./lmshell --output=python say hello
   ./lmshell --output=auto find all files

   # Test error cases
   ./lmshell --output=invalid say hello
   ./lmshell  # Should show help
   ```

5. **Commit your changes**
   - Write clear commit messages
   - Reference any related issues

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**
   - Describe what your PR does
   - Link to any related issues
   - Explain any design decisions

## Code Style

- Follow PEP 8 for Python code
- Use clear, descriptive function and variable names
- Add docstrings to all functions
- Keep code well-organized with section comments
- Use type hints where helpful

## Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/llm-command.git
cd llm-command

# Make the script executable
chmod +x lmshell

# Set up environment variables for testing
export LMSHELL_API_TOKEN="your-test-token"
export LMSHELL_MODEL_ID="your-test-model"
export LMSHELL_BASE_URL="http://127.0.0.1:7980/v1"

# Test the script
./lmshell --help
```

## Areas for Contribution

Here are some areas where contributions would be especially valuable:

- **New output formats**: Add support for more languages/shells
- **Improved prompts**: Better system prompts for more accurate output
- **Error handling**: Better error messages and recovery
- **Documentation**: Examples, tutorials, use cases
- **Testing**: Automated tests, edge case coverage
- **Performance**: Optimizations, caching

## Questions?

Feel free to open an issue for any questions about contributing.

## License

By contributing to lmshell, you agree that your contributions will be licensed under the Apache License 2.0.
