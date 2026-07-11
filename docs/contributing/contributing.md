# Contributing

We welcome contributions to Pulse! Whether it's bug reports, feature requests, or code contributions, your help is appreciated.

## Getting Started

### Setting Up Your Development Environment

1. Clone the repository:
   ```bash
   git clone https://github.com/Mystifine/Pulse.git
   cd Pulse
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Install the project locally:
   ```bash
   wally install
   rojo build -o "Pulse.rbxlx"
   ```

## Development Workflow

### Code Style

- Use Luau with proper type annotations
- Follow Roblox naming conventions
- Keep functions small and focused
- Add comments for complex logic

### Type Annotations

Always include type annotations:

```lua
local function add(a: number, b: number): number
  return a + b
end

type Config = {
  frequency: number,
  dampingRatio: number,
}
```

### Testing

Before submitting changes, test thoroughly:

1. Create a test in Roblox Studio
2. Verify your changes work as expected
3. Check for edge cases
4. Run selene for linting:
   ```bash
   selene src/
   ```

## Submitting Changes

### Branch Naming

Use descriptive branch names:
- `feature/add-signal-support` - New features
- `fix/memory-leak-in-effects` - Bug fixes
- `docs/add-api-examples` - Documentation

### Commit Messages

Write clear commit messages:

```
feature: Add support for Color3 springs

- Automatically detect Color3 values
- Animate component channels separately
- Clamp values to 0-1 range

Fixes #42
```

### Pull Requests

When submitting a PR:

1. **Title**: Clear, descriptive title
2. **Description**: Explain what changed and why
3. **Testing**: Describe how you tested the changes
4. **Screenshots**: Include if UI changes
5. **Breaking Changes**: Clearly mark any breaking changes

### PR Checklist

- [ ] Tests pass
- [ ] Linter passes (`selene src/`)
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Commit messages are clear
- [ ] Code follows style guide

## Issues

### Reporting Bugs

Include:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Pulse version
- Roblox Studio version
- Any error messages

### Requesting Features

Explain:
- What problem you're solving
- How you'd use the feature
- Alternative approaches
- Any concerns

## Documentation

### Adding Documentation

1. Keep documentation up-to-date with code changes
2. Add examples for new features
3. Use clear language
4. Link related pages

### Building Documentation Locally

```bash
cd docs
pip install mkdocs mkdocs-material
mkdocs serve
```

Then visit `http://localhost:8000` in your browser.

## Code Review

All contributions go through code review. Reviewers may:
- Request changes
- Ask questions
- Suggest improvements
- Approve changes

Be respectful and constructive in discussions. We're all here to improve Pulse!

## Releases

Releases follow semantic versioning:
- **Major**: Breaking changes
- **Minor**: New features
- **Patch**: Bug fixes

Release process:
1. Update version in `wally.toml`
2. Update CHANGELOG
3. Tag release
4. Publish to Wally

## Community

- **Discussions**: Ask questions in GitHub Discussions
- **Issues**: Report bugs and request features
- **Pull Requests**: Contribute code changes
- **Email**: Contact the maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue or start a discussion if you have any questions about contributing!

Thank you for helping make Pulse better! 🚀
