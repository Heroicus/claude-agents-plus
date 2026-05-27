# Contributing to Claude Agents Plus

Thank you for your interest in contributing!

## How to Contribute

### Report Bugs

Open an issue with:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Environment (OS, Claude Code version)

### Suggest Features

Open an issue with:
- Problem statement
- Proposed solution
- Use cases

### Submit Code

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m "feat: add your feature"`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

## Development Setup

```bash
git clone https://github.com/Heroicus/claude-agents-plus.git
cd claude-agents-plus

# Test hooks
echo '{"prompt": "test message"}' | ./hooks/agents-plus-router.sh
```

## Code Style

- Bash hooks: Use `shellcheck` for linting
- SKILL.md: Follow existing format
- Commit messages: Conventional Commits (`feat:`, `fix:`, `docs:`)

## Pull Request Guidelines

- One feature per PR
- Include tests if applicable
- Update documentation
- Describe changes in PR description

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
