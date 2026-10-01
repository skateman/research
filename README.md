# Academic Research Paper Writing Toolkit

Seven specialized GitHub Copilot agents and ten supporting skills for developing
academic papers. Manuscripts normally live under `papers/<name>/`. The toolkit
assists research and production; authors remain responsible for evidence,
disclosures, venue compliance, and the final submission decision.

## Quick Start

Open this repository in the Copilot host you use, select an agent, and provide
the paper directory and task.

| Host | Selecting an agent |
|------|--------------------|
| Copilot CLI | Use `/agent` and select **Idea Coach**, **Paper**, or another role |
| VS Code | Select the custom agent from the Chat agent picker |

`@paper`, `@writer`, and similar names in older workflow descriptions are role
shorthand, **not portable invocation syntax**. In Copilot CLI, `@` mentions files.
CLI `/skills` and `/mcp` help inspect skill discovery and server configuration.
For a noninteractive CLI request, the agent identifier is its filename stem:

```bash
copilot --agent paper --prompt "Review papers/my-paper against its CFP without editing it."
```

Open the repository root for straightforward discovery. In VS Code, opening
only a paper subfolder may require the trusted-parent opt-in
`chat.useCustomizationsInParentRepositories`. For **CLI-based Copilot sessions
inside VS Code**, custom agents additionally require
`github.copilot.chat.cli.customAgents.enabled`; this is not a standalone CLI or
ordinary Local Chat requirement. Standard agent-skill and instruction-file
support is already enabled by default in current VS Code.

Start with **Idea Coach** for rough notes, **Researcher** for a literature survey,
or **Paper** for a coordinated pipeline. With Paper selected, example requests are:

```text
Work on papers/my-paper using its plan.md and cfp.md. Prepare an author-review draft.
Review papers/my-paper against the CFP; do not edit the manuscript.
Fix the formatting in papers/my-paper without changing the venue template.
```

Plan mode is optional. Do not assume `/plan` writes a file at a particular path:
pass the actual plan artifact or brief to the next agent. An agreed research
direction is sufficient; a `plan.md` file is useful but not mandatory.

Optional context files:

```text
papers/my-paper/
  plan.md           Research direction, scope, and author decisions
  cfp.md            Venue requirements or a link to the current CFP
  review-guide.md   Reviewer rubric or specific evaluation criteria
```

## Agents

| Agent | Responsibility |
|-------|----------------|
| [Paper](.github/agents/paper.agent.md) | Coordinate only the requested stages, with explicit ownership and completion criteria |
| [Idea Coach](.github/agents/idea-coach.agent.md) | Refine ideas through focused questions and a bounded novelty check |
| [Researcher](.github/agents/researcher.agent.md) | Survey literature, record evidence depth, and produce research handoffs |
| [Drafter](.github/agents/drafter.agent.md) | Create a compilable structure with explicit unresolved evidence |
| [Writer](.github/agents/writer.agent.md) | Develop evidence-backed prose, either standalone or as a bounded writing stage |
| [Reviewer](.github/agents/reviewer.agent.md) | Assess the manuscript, sources, and presentation without modifying them |
| [Illustrator](.github/agents/illustrator.agent.md) | Produce SVG figures and verified PNG/PDF conversions |

Models and reasoning settings are intentionally not pinned. Use the host's
user/session preferences rather than aging model names in shared profiles.
Tool aliases and MCP allowlists are deliberate. Host support still differs:
for example, the shared tool reference currently lists no cloud-agent mapping
for `web`. Visual inspection requires an actual image-viewing capability, not a
made-up `vision` tool.

## Pipeline and Ownership

The full pipeline is:

```text
research -> draft -> write -> references -> prose polish -> figures
  -> anonymity if required -> build -> layout -> review -> scoped revisions
```

Existing-paper requests start at the relevant stage; a review does not imply
permission to rewrite. The coordinator prevents nested duplicate pipelines and
stops on missing data or decisions instead of inventing results.

- Citation editing and prose polishing are normally **sequential** because both
  modify `.tex`. Different paragraphs do not make concurrent writes safe.
- Independent figures may run in parallel with explicitly assigned files.
- Compile/render once after source edits finish. Reviewers reuse the same checked
  artifact instead of rebuilding a shared output directory.
- One reviewer is the default. Additional independent reviewers require an
  explicit request; a CFP's human-reviewer count is not an agent budget.
- Anonymization follows the actual venue policy, is reversible, and preserves
  real self-citations unless the venue expressly requires masking.
- Page limits are met through appropriate content/layout changes, not by
  shrinking mandated fonts, margins, or spacing.

For a resumable full pipeline, Paper records stage status and evidence in the
paper's `output/pipeline-state.json`. A file's existence alone never marks a stage
complete. Remaining limitations are reported rather than hidden behind a
"submission-ready" claim.

## Skills

Skill names are lowercase slugs matching their directories. Descriptions drive
discovery; detailed instructions and resources load only when relevant.

| Skill | Use |
|-------|-----|
| [referencer](.github/skills/referencer/SKILL.md) | Verify publication metadata, claim support, citations, and BibTeX |
| [research](.github/skills/research/SKILL.md) | Small literature lookups and bibliography organization |
| [gap-analysis](.github/skills/gap-analysis/SKILL.md) | Bounded overlap, coverage, and positioning checks |
| [data-processor](.github/skills/data-processor/SKILL.md) | Preserve raw data while documenting approved cleaning and transformations |
| [statistician](.github/skills/statistician/SKILL.md) | Design-aware analyses, effect estimates, uncertainty, and reproducibility |
| [humanizer](.github/skills/humanizer/SKILL.md) | Improve readability without changing evidence or promising detector evasion |
| [anonymizer](.github/skills/anonymizer/SKILL.md) | Prepare an author-anonymous submission variant when required |
| [compiler](.github/skills/compiler/SKILL.md) | Build LaTeX, render pages, and publish checked page metadata |
| [svg-renderer](.github/skills/svg-renderer/SKILL.md) | Convert SVG to PNG/PDF with explicit output paths and sizes |
| [formatter](.github/skills/formatter/SKILL.md) | Inspect publication-size pages and fix template-compatible layout issues |

These skills contain instructions and optional resources, not `tools` or
`mcp-servers` configuration blocks. They deliberately omit `allowed-tools`,
which can **pre-approve tool use in CLI**, and VS Code's experimental
`context: fork` mode. Ordinary skill loading here does not start another worker
or provision an MCP server. The pipeline also does not require VS Code's
separate nested-subagent opt-in.

## Runtime Setup

**Docker must be installed and running** for the supplied execution helpers.
Build the image from the repository root:

```bash
docker build -t research-latex .
```

The image supplies pdfLaTeX/LuaLaTeX, latexmk, bibliography tools, Poppler,
`rsvg-convert`, and scientific Python packages. Optional Excel/Parquet engines
are not guaranteed; consult the data-processor skill before requesting them.
The build context excludes manuscripts, data, and MCP settings.

Run helper commands from the repository root:

```bash
.github/skills/compiler/scripts/build-pdf.sh papers/my-paper main.tex
.github/skills/compiler/scripts/build-pdf.sh papers/my-paper main.tex --engine lualatex
.github/skills/svg-renderer/scripts/render-svg.sh papers/my-paper/figures/architecture.svg --format both
.github/skills/statistician/scripts/run-analysis.sh papers/my-paper analysis/run.py --args --seed 42
```

Python script arguments and LaTeX includes are relative to the paper directory.
Other shell paths in these examples are repository-relative.

The PDF is written beside the entry file, not inside `output/`. Numbered page
images and `pages.json` go in `output/pages/`. The manifest records the PDF hash,
page count, rendered-image count, and rendering mode. `--pages-only` renders an
existing PDF but does not prove that it reflects current source files.
Compilation uses a fresh latexmk run and a writable, paper-relative font cache
in `output/texmf-cache/`, including when the container runs as a non-root user.

## MCP Setup Is Host-Specific

The profiles refer to two existing server names:

| Name | Launcher used in the existing configuration |
|------|--------------------------------------------|
| `paper-search` | `npx -y paper-search-mcp-nodejs` |
| `paper-search-py` | `npx -y @smithery/cli run @openags/paper-search-mcp` |

These are launcher examples, not a guarantee of current provider availability.
They require Node/npm; additional Python/uv dependencies, provider authentication,
API keys, and supported databases depend on the installed server version.
Consult the [Node server](https://github.com/Dianel555/paper-search-mcp-nodejs) and
[Python server](https://github.com/openags/paper-search-mcp) documentation. Verify
and pin versions appropriate to your environment instead of silently replacing
a working launcher with a floating update.

| Host/file | Configuration |
|-----------|---------------|
| Standalone Copilot CLI | Loads trusted project `.mcp.json` or `.github/mcp.json`; private user configuration is `~/.copilot/mcp-config.json`. Use `/mcp` to inspect/manage servers |
| VS Code `.vscode/mcp.json` | Uses a top-level `servers` object; start from the credential-free [example](.vscode/mcp.example.json) if you do not already have a configuration |
| Root `.mcp.json` | Existing CLI project configuration retained with its `mcpServers` wrapper; CLI does not read `.vscode/mcp.json` |
| GitHub-hosted cloud agent | Configure **Settings -> Copilot -> MCP servers**, with explicit server `type`/`tools` and supported Agents secrets/variables; local desktop configuration is not automatically sufficient |

Do not symlink `.vscode/mcp.json` to `.mcp.json`: their wrappers differ. The actual
VS Code configuration is local and git-ignored. Preserve existing server
commands/environment values when adapting its schema.

Keep API keys out of tracked files. Use host-managed secrets, environment
variables, or VS Code secret inputs as supported by that host. CLI supports
`$VAR`, `${VAR}`, and `${VAR:-default}` expansion; VS Code supports its own
`${input:id}`/environment variables and `envFile`. These formats are not
interchangeable. A repository-local `.copilot/mcp-config.json` is not a documented
automatic CLI lookup location.

VS Code's Agent Host can also load `.mcp.json` and receive forwarded editor MCP
configuration, but interactive-input servers and other harness-specific limits
prevent assuming parity with the standalone CLI. See the current
[harness limitations](https://code.visualstudio.com/docs/agents/run/agent-harnesses).

Do not enable blanket auto-approval. After configuration, use the host's MCP
tooling to confirm which tools are exposed; a provider feature list does not
prove runtime access. Unavailable sources must be reported, with legitimate
fallback sources used when possible.

## Repository Structure

```text
.github/
  agents/                 User-facing custom agent profiles
  skills/                 Focused instructions and bundled helpers
  instructions/           Path-scoped manuscript and maintenance conventions
  workflows/              Customization validation
  copilot-instructions.md Concise shared context
.vscode/mcp.example.json   Credential-free VS Code starter
scripts/                  Shared container support and metadata validation
tests/                    Profile and helper regression coverage
papers/<name>/            Manuscript, figures, data, research, and output
Dockerfile                LaTeX/SVG/scientific Python tool image
.mcp.json                 Existing Copilot CLI project MCP configuration
```

## Maintaining the Toolkit

Use Python 3.11+ for development checks:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python scripts/validate_customizations.py
.venv/bin/python -m unittest discover -s tests -q
```

The validator checks frontmatter, skill/directory naming, tool conventions,
local resource links, and host-specific MCP structure without displaying secret
values. Tests exercise argument handling, Docker-root resolution, output
ownership, failure propagation, and page metadata. They use command doubles;
native Poppler/librsvg checks also run when those tools are installed. They do
not substitute for a real Docker/LaTeX build. CI runs the portable checks.

For the opt-in container integration check, start Docker and build the image:

```bash
docker build -t research-latex .
RUN_DOCKER_TESTS=1 python3 -m unittest discover -s tests -p 'test_docker_integration.py' -v
```

This exercises pdfLaTeX/BibTeX, LuaLaTeX/biber, SVG conversion, scientific Python,
paths with spaces, page-manifest freshness, and deliberate compilation failure.
It uses synthetic fixtures, not existing papers. Temporary fixtures are created
under the repository for Docker Desktop/Colima bind-mount compatibility and
removed afterward. To retain outputs for visual inspection, set
`RESEARCH_DOCKER_TEST_ARTIFACTS` to an existing Docker-accessible parent directory;
the test creates a uniquely named child there.

The September 2026 refresh corrects the original metadata/tool mismatches,
conflicting parallel edits, invalid shared MCP schema, helper failures, and
overconfident research/submission claims. The bespoke academic roles remain:
community assets are references for authoring conventions, not drop-in upgrades
to these agents.

The [awesome-copilot snapshot checked on September 15, 2026](https://github.com/github/awesome-copilot/tree/1899b18da3fa5183652f86165917d553cba1850a)
contains no exact counterparts to the seven agent filenames or ten skill paths.
No community package was installed or substituted for a local role.

| Community reference | Local counterpart | Assessment |
|---------------------|-------------------|------------|
| [Agent-authoring guidance](https://github.com/github/awesome-copilot/blob/1899b18da3fa5183652f86165917d553cba1850a/instructions/agents.instructions.md) | [Custom agents](.github/agents) | Adapt tool exposure, bounded delegation, and output contracts; not generic model prescriptions |
| [Skills-authoring guidance](https://github.com/github/awesome-copilot/blob/1899b18da3fa5183652f86165917d553cba1850a/instructions/agent-skills.instructions.md) | [Academic skills](.github/skills) | Adapt naming, progressive disclosure, deterministic helpers, and explicit failures |
| [Instructions-authoring guidance](https://github.com/github/awesome-copilot/blob/1899b18da3fa5183652f86165917d553cba1850a/instructions/instructions.instructions.md) | [Shared context](.github/copilot-instructions.md) and [scoped rules](.github/instructions) | Keep shared rules concise and file-specific guidance scoped |
| [Scientific Paper Research](https://github.com/github/awesome-copilot/blob/1899b18da3fa5183652f86165917d553cba1850a/agents/scientific-paper-research.agent.md) | [Researcher](.github/agents/researcher.agent.md) | Functional overlap, not an upstream replacement; retain the existing research pipeline |

Authoritative references:

- [GitHub: custom-agent configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [GitHub: CLI agent invocation](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)
- [GitHub: CLI MCP setup](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-mcp-servers)
- [GitHub: CLI skill behavior and pre-approval](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills)
- [VS Code: custom agents](https://code.visualstudio.com/docs/agent-customization/custom-agents)
- [VS Code: MCP configuration](https://code.visualstudio.com/docs/agents/reference/mcp-configuration)
- [VS Code: current AI settings](https://code.visualstudio.com/docs/agents/reference/ai-settings)
- [Agent Skills specification](https://agentskills.io/specification)

## License

TBD
