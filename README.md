# Bio-OS Navigen Agent

The **Bio-OS Navigen Agent** is a specialized, intelligent assistant designed to operate on the Bio-OS platform. It empowers users to perform complex biomedical big data analysis through natural language interaction, bridging the gap between scientific intent and computational execution.

## Project Status

> [!IMPORTANT]
> **Current Phase**: V1 Release (Agent SKILLs Edition)

Bio-OS Navigen has evolved into a fully modular, plug-and-play **3-Tier Agent Capability Architecture**.

| Tier | Abstraction Layer | Core SKILLs |
| :--- | :--- | :--- |
| **Tier 1** | **Atomic Capabilities**<br>Focused, script-backed tools (Data fetching, environment building). | `bioos_data_fetcher`, `bioos_docker_builder`, `bioos_wdl_scripter`, `bioos_workspace_parser`, `bioos_platform_operator` |
| **Tier 2** | **Core Workflows**<br>Orchestrators for building pipelines or complex sub-routines. | `bioos_pipeline_developer` |
| **Tier 3** | **Business Modes / SOPs**<br>High-level intent handlers that orchestrate Tiers 1 and 2. | `bioos_paper2workspace`, `bioos_workspace2paper` |

## Core Features

- **Tripartite Expertise**: Acts as a Bioinformatics Scientist, Automation Engineer, and Bio-OS Platform Specialist.
- **Standards-Compliant**: Strictly adheres to unified standards for Dockerfiles, WDL scripts, log formats, and error handling.
- **Agentic Workflow**: Autonomous planning, execution, and verification of tasks across different modes.

## Development

The system prompt is maintained in a modular format under `system_prompt/` and compiled into a single file `GEMINI.md` for deployment.

### Deployment Options
To use Bio-OS Navigen, configure your preferred agent (e.g., Cline, Cursor, Google Antigravity) with the [bioos-mcp-server](https://github.com/GBA-BI/bioos-mcp-server/tree/main). 

Then, provide the Navigen instructions to your agent using one of the following methods:
1. **Agent SKILLs (Recommended)**: Copy the entire `skills/` directory into your agent's designated workspace or `.agent/skills` folder. This leverages the new modular 3-Tier architecture.
2. **Single File `GEMINI.md`**: For agents supporting only a single system prompt, use the compiled monolithic file.
3. **Modular `system_prompt/`**: For general agents supporting multiple prompt imports.



## Contact

For feedback or issues during the trial phase, please contact the development team.
