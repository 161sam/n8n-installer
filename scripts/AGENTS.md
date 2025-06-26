# Guidance for Codex Agents (scripts/)

This folder contains shell scripts used to install and maintain the workspace.

## Conventions
- All scripts are Bash and start with `#!/bin/bash` and `set -e`.
- Use the helper functions from `utils.sh` for logging.
- Keep indentation with two spaces.
- Do not store secrets or generated `.env` files in version control.

## Validation
Before committing changes to any `.sh` file run:
```bash
bash -n <script>
```
`shellcheck` is recommended if available.
