# Contributing to CommitMate.nvim

Thank you for your interest in contributing to CommitMate! We welcome contributions from the community.

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- A clear and descriptive title
- Steps to reproduce the behavior
- Expected behavior vs actual behavior
- Your environment (Neovim version, OS, plugin manager)
- Relevant configuration from your `init.lua` or `init.vim`
- Any error messages or logs

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- A clear and descriptive title
- A detailed description of the proposed feature
- Examples of how the feature would be used
- Any relevant screenshots or mockups

### Pull Requests

1. **Fork the repository** and create your branch from `main`:
   ```bash
   git checkout -b feat/my-new-feature
   # or
   git checkout -b fix/my-bug-fix
   ```

2. **Make your changes** following the code style guidelines below

3. **Test your changes** thoroughly:
   - Test with different Neovim configurations
   - Verify the plugin works with lazygit integration
   - Check for any error messages or warnings

4. **Commit your changes** using conventional commits:
   ```bash
   git commit -m "feat: add new commit template feature"
   git commit -m "fix: resolve issue with git staging"
   git commit -m "docs: update installation instructions"
   ```

5. **Push to your fork** and submit a pull request

## Development Setup

1. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/commitmate.nvim.git
   cd commitmate.nvim
   ```

2. **Set up for local development**:
   - Create a minimal Neovim config for testing:
     ```lua
     -- test-config.lua
     vim.opt.runtimepath:append(".")
     require("commitmate").setup({
       -- your test configuration
     })
     ```
   - Run Neovim with the test config:
     ```bash
     nvim -u test-config.lua
     ```

3. **Test your changes** in a real git repository

## Code Style Guidelines

### Lua Code Style

- Use 2 spaces for indentation
- Use snake_case for variables and functions
- Use clear, descriptive variable and function names
- Add comments for complex logic
- Keep functions focused and modular

Example:
```lua
local function generate_commit_message(diff)
  -- Extract file changes from diff
  local files = extract_changed_files(diff)
  
  -- Generate message based on changes
  return format_commit_message(files)
end
```

### Documentation

- Update the README.md if you add new features or change behavior
- Add comments to explain non-obvious code
- Update [doc/commitmate.txt](doc/commitmate.txt) for user-facing features
- Include examples in documentation

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `chore:` for maintenance tasks
- `refactor:` for code restructuring
- `test:` for adding or updating tests
- `perf:` for performance improvements

Examples:
```
feat: add support for custom commit templates
fix: resolve lazygit integration timeout issue
docs: update configuration examples in README
```

## Project Structure

```
commitmate.nvim/
├── lua/
│   └── commitmate/
│       └── init.lua          # Main plugin logic
├── plugin/
│   └── commitmate.lua        # Plugin initialization
├── doc/
│   └── commitmate.txt        # Vim help documentation
└── README.md
```

## Testing

Before submitting a pull request:

1. Test the plugin in a clean Neovim environment
2. Verify integration with lazygit works correctly
3. Test with different git workflows (staging, unstaging, amending)
4. Check for any Lua errors or warnings
5. Ensure backwards compatibility

## Questions?

Feel free to open an issue for any questions about contributing. We're here to help!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
