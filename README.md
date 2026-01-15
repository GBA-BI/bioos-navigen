# Bio-OS Navigen Agent

The **Bio-OS Navigen Agent** is a specialized, intelligent assistant designed to operate on the Bio-OS platform. It empowers users to perform complex biomedical big data analysis through natural language interaction, bridging the gap between scientific intent and computational execution.

## Project Status

> [!IMPORTANT]
> **Current Phase**: Pilot / Trial Run (试运行阶段)

This project is currently in a **Trial / Beta** phase. We are actively refining the agent's capabilities and stability.

| Mode | Function | Status |
| :--- | :--- | :--- |
| **Mode 1** | **General Mode**<br>Interactive guide for general bioinformatics analysis. | ✅ **Available for Trial** |
| **Mode 2** | **Paper2Workspace**<br>Reproduce analysis environments/workflows from scientific papers. | ✅ **Available for Trial** |
| **Mode 3** | **Talk2Workspace**<br>Chat with your existing Bio-OS workspace (Q&A, Operations). | ✅ **Available for Trial** |
| **Mode 4** | **Workspace2Paper**<br>Draft scientific manuscripts based on workspace results. | ✅ **Available for Trial** |

## Core Features

- **Tripartite Expertise**: Acts as a Bioinformatics Scientist, Automation Engineer, and Bio-OS Platform Specialist.
- **Standards-Compliant**: Strictly adheres to unified standards for Dockerfiles, WDL scripts, log formats, and error handling.
- **Agentic Workflow**: Autonomous planning, execution, and verification of tasks across different modes.

## Development

The system prompt is maintained in a modular format under `system_prompt/` and compiled into a single file `GEMINI.md` for deployment.

### Automated Prompt Management

We provide scripts to automate the maintenance of the system prompt:

-   `validate_prompts.py`: Validates the syntax of all markdown files in `system_prompt/`, checking for valid JSON blocks and structural issues.
-   `compile_prompts.py`: Concatenates all files in `system_prompt/` into the single `GEMINI.md` file.

These checks are automatically run via GitHub Actions on every push.

### Development Structure
- Select a general coding agent like Cursor,Claude Code, Gemini CLI, CLINE.
- Configure [bioos-mcp-server](https://github.com/GBA-BI/bioos-mcp-server/tree/main) to the general agent.
- Deploy Bio-OS Navigen System pormpts to the general agent follow eithier way:
    - `system_prompt/`: Modular source files for agent that supports multiple system instruction files.
    - `GEMINI.md`: Compiled single-instruction file for agent that supports one system instruction file.



## Contact

For feedback or issues during the trial phase, please contact the development team.
