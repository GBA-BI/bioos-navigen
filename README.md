# Bio-OS Navigen Agent

Bio-OS Navigen is a skill-based agent instruction set for operating Bio-OS workflows through natural language. It separates scientific routing from execution details, so the same bioinformatics workflow knowledge can run through either MCP/plugin tools or the pybioos CLI.

## Skill Layout

This repository maintains three complementary skill trees:

| Directory | Use Case | Execution Surface |
| --- | --- | --- |
| `skills-bioinformatics/` | Domain/business-layer skills for genomics, transcriptomics, microbiome, pathogen analysis, early warning, proteomics, and Bio-OS image catalogs. | Execution-neutral. These skills route scientific intent and refer to stable skill names such as `bioos_platform_operator`, without depending on whether the backend is MCP/plugin or CLI. |
| `skills/` | Platform-operation skills for agents connected to Bio-OS through tools exposed by `bioos-mcp-server` or the OpenClaw BioOS plugin. | Uses tool names such as `submit_workflow`, `upload_files_to_workspace`, `get_workflow_logs`, and `create_iesapp`. |
| `skills-cli/` | Platform-operation skills for agents that call pybioos directly from a shell. | Uses concrete CLI commands such as `<bioos_launch> workflow submit ...` and `<bioos_launch> file upload ...`. This tree includes `bioos_cli_locator` because CLI launchers vary by environment. |

The intended pairing is:

- MCP/plugin mode: install `skills/` plus `skills-bioinformatics/`.
- Direct CLI mode: install `skills-cli/` plus `skills-bioinformatics/`.

Use only one platform-operation tree at a time: choose `skills/` if the machine is wired to `bioos-mcp-server` or the OpenClaw plugin, and choose `skills-cli/` if the machine only needs to call pybioos directly. You do not need to install both.

`skills/` and `skills-cli/` should stay behaviorally synchronized. `skills-bioinformatics/` should remain neutral and should not mention either directory by name; that is the small trick that lets the same business-layer workflows work with both execution surfaces.

## Installation

To load these skills into your developer assistant, you can use the automatic setup script or configure them manually. The installation is configured at the project level.

### Quick Install (Project-Level)

To automatically install these skills into your project directory:

1. Clone or pull the `bioos-navigen` repository to your local machine:
   ```bash
   git clone https://github.com/GBA-BI/bioos-navigen.git
   ```

2. Enter your project directory, copy the `setup_skills.sh` script, grant execution permissions, and run it by specifying the source repository path:
   ```bash
   # Enter your project directory
   cd /path/to/your/project

   # Copy setup_skills.sh from the cloned repo
   cp /path/to/bioos-navigen/setup_skills.sh .

   # Grant execution permission
   chmod +x setup_skills.sh

   # Run setup and specify the source path of bioos-navigen
   ./setup_skills.sh --copy --source /path/to/bioos-navigen
   ```

This script will automatically detect and install the skills into the local config folders of the following developers' assistants in your project:
- **Antigravity** (`.agent/skills/`)
- **Codex** (`.agents/skills/` and `.codex/skills/`)
- **Claude Code** (`.claude/skills/`)



### Manual Installation (Project-Level)

If you prefer to configure the skills manually, run the following commands from the repository root.

#### Copying Skills Physically (Deployment)

```bash
# Create local agent configuration directories
mkdir -p .agent/skills .agents/skills .codex/skills .claude/skills

# Copy skills (e.g. for Antigravity)
cp -R skills-cli/* .agent/skills/
cp -R skills-bioinformatics/* .agent/skills/
```

#### Linking Skills Relatively (Development)

To link custom skills without duplicating files, you can create relative symlinks:

```bash
# Create directories if not exists
mkdir -p .agent/skills

# Create relative symlinks
cd .agent/skills
ln -s ../../skills-cli/* .
ln -s ../../skills-bioinformatics/* .
```

## Architecture

Bio-OS Navigen uses a three-tier capability model:

| Tier | Layer | Examples |
| --- | --- | --- |
| Tier 1 | Atomic platform capabilities | `bioos_data_fetcher`, `bioos_docker_builder`, `bioos_wdl_scripter`, `bioos_workspace_parser`, `bioos_platform_operator` |
| Tier 2 | Pipeline orchestration | `bioos_pipeline_developer` |
| Tier 3 | End-to-end SOPs | `bioos_paper2workspace`, `bioos_workspace2paper` |

The bioinformatics skills sit above this stack: they choose the right workflow and hand execution to the synchronized platform-operation skills.

## Related Projects

- `pybioos`: install with `pip install pybioos`; provides the root `bioos` CLI used by `skills-cli/`.
- `bioos-mcp-server`: [GBA-BI/bioos-mcp-server](https://github.com/GBA-BI/bioos-mcp-server); exposes Bio-OS operations as MCP tools used by `skills/`.
- `bioos-claw`: [GBA-BI/BioOS-Claws](https://github.com/GBA-BI/BioOS-Claws); OpenClaw tools aligned with the MCP tool names.

## Development Notes

- Keep workflow-facing file-input behavior synchronized between `skills/` and `skills-cli/`.
- Keep business-layer guidance in `skills-bioinformatics/` execution-neutral.
- The legacy modular prompt files live under `system_prompt/`, and `GEMINI.md` is the compiled single-file prompt for agents that cannot load skills directly.

## Contact

For feedback or issues during the trial phase, please contact the development team.
