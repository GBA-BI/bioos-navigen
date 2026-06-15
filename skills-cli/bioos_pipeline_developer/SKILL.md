---
name: bioos_pipeline_developer
description: Interactively design and assemble deployable Bio-OS analysis pipelines by coordinating Docker image creation, WDL authoring, and optional platform execution. Trigger this skill when a new Bio-OS pipeline must be developed.
---

# Bio-OS Pipeline Developer

## Operating Principle
This skill translates high-level analysis requirements into a complete Bio-OS pipeline by coordinating environment design and workflow authoring.

## Execution Workflow

### Step 1: Requirements engineering
Determine the exact scientific steps, tool versions, input and output contracts, and parameter flow.

- If the pipeline is being designed from conversation, gather those details from the user.
- If the pipeline comes from a reproduction card, extract the steps and dependencies from `{UUID}_p2w_card.json`.
- If the Bio-OS CLI launcher is still unknown, explicitly declare that `bioos_cli_locator` is required before invoking any downstream CLI-based Bio-OS skill.

### Step 2: Environment provisioning
Every distinct task environment must be backed by a Bio-OS-compatible Docker image.

- For each unique environment, explicitly declare that `bioos_docker_builder` is required.
- Follow that skill to obtain a validated `docker_image` URL for every environment.

### Step 3: Workflow scripting
After the images are ready:

- Explicitly declare that `bioos_wdl_scripter` is required.
- Use it to translate the logical steps and Docker image URLs into one generated WDL file.

### Step 4: Pipeline finalization
Once the WDL file is produced:

- If the user only asked for pipeline construction, present the finalized WDL and image plan.
- If the pipeline must be executed on Bio-OS immediately, explicitly declare that `bioos_platform_operator` is required to handle CLI-based deployment.
