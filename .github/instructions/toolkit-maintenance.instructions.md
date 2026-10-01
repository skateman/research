---
description: Maintain portable Copilot agents, skills, configuration, and their execution helpers.
applyTo: ".github/agents/**,.github/skills/**,.github/instructions/**,.github/copilot-instructions.md,.github/workflows/**,.github/mcp.json,scripts/**,tests/**,Dockerfile,requirements-dev.txt,.mcp.json,.vscode/mcp*.json"
---

# Toolkit Maintenance

- Check current official GitHub, VS Code, and Agent Skills documentation before
  changing configuration syntax. Community examples are not a support contract.
  These academic roles are bespoke, not copies to replace with same-named assets.
- Keep `.github/copilot-instructions.md` focused on shared context; put
  file-specific conventions in `.instructions.md` with a nonempty `applyTo`.
- Agents use `.github/agents/*.agent.md` with a description and deliberate tools.
  Prefer portable tool aliases (`read`, `edit`, `search`, `web`, `execute`,
  `agent`) and discovered MCP names such as `paper-search/*`. Do not invent
  `vision`/`create` tool aliases or assume excluded MCP tools remain available.
- Only orchestrators that actually delegate need `agent`. Preserve host model
  defaults; do not introduce version-pinned model names or host-specific
  orchestration fields without a demonstrated requirement.
- Each skill lives in `.github/skills/<lowercase-hyphenated-name>/SKILL.md`.
  Its `name` must match the directory; its description should say when to use
  it. Keep detailed guidance and bundled resources out of the always-on context.
- Do not use agent-only `tools` or `mcp-servers` frontmatter in skills. Skills
  use the caller's exposed tools. CLI `allowed-tools` can pre-approve execution;
  do not add it mechanically. VS Code's experimental `context: fork` requires
  an opt-in and is not used by this repository's portable skill profiles.
- Keep host-specific MCP configurations separate. VS Code uses `servers` in
  `.vscode/mcp.json`; do not blindly copy another client's `mcpServers` wrapper.
  CLI loads trusted `.mcp.json` or `.github/mcp.json` project configuration;
  its user file is `~/.copilot/mcp-config.json`, not a repository-local `.copilot`
  file. Host-specific environment/input expansion also differs.
  Do not change personal settings or overwrite existing server launchers,
  environment values, trust decisions, or tool permissions.
- Keep `.vscode/mcp.example.json` credential-free. The actual `.vscode/mcp.json`
  is local and ignored; never symlink it to a different client's configuration.
- Do not commit credentials, enable blanket auto-approval, or assume every MCP
  source works without authentication. Discover available tools at runtime and
  document missing-provider behavior.
- Use explicit per-file write ownership, bounded tasks, and honest completion
  criteria. Avoid concurrent manuscript edits, duplicate pipelines, mandatory
  background tasks, and auto-fanout based on the number of human reviewers.
- Keep helper paths independent of the caller's working directory. Validate
  arguments before invoking Docker, quote paths, propagate failures, and do not
  replace good artifacts with success-shaped output after a failed operation.
- Share container setup in `scripts/lib/research-container.sh`. The Docker build
  context must not include manuscripts, data, or MCP credentials.
- After changes, run `python3 scripts/validate_customizations.py` and the focused
  tests with `python3 -m unittest discover -s tests -q`. Install development
  dependencies from `requirements-dev.txt` in a virtual environment when needed.
  Helper tests use command doubles; real container execution is a separate check.
