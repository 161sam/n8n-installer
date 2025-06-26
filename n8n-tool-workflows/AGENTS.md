# Guidance for Codex Agents (n8n-tool-workflows/)

This directory stores example n8n workflows in JSON format.  Some files have the extension `.json`, others `.md` but contain JSON.

## Conventions
- Format workflow files as JSON with two-space indentation.
- File names use CapitalizedWords separated by underscores or hyphens (e.g., `Create_Google_Doc.json`).
- Keep workflow descriptions and metadata intact.

## Validation
To test a workflow locally you can run:
```bash
n8n import:workflow --input <file>
```
The CLI might not be installed in this environment, so document in your PR if the import test cannot run.
