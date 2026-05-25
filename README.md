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
