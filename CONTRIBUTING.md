# Contributing

This repository holds my personal GitHub configuration, but suggestions are welcome.

> 🇧🇷 Sugestões em português também são bem-vindas.

1. Open an [issue](../../issues/new/choose) describing the idea or problem.
2. For changes, fork the repository and create a branch: `git checkout -b fix/short-description`.
3. Check your changes locally:
   ```bash
   uvx pre-commit run --all-files
   uvx pytest tests
   ```
4. Commit using [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:` ...).
5. Open a pull request and fill in the template.

PowerShell scripts must be saved as **UTF-8 with BOM** (required by Windows PowerShell 5.1).

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
