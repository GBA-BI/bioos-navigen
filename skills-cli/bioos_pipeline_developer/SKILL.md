---
name: bioos_pipeline_developer
description: Interactively design and assemble deployable Bio-OS analysis pipelines by coordinating Docker image creation, WDL authoring, and optional platform execution. Trigger this skill whenever the user indicates that they want to develop a new analysis workflow on Bio-OS, even if they do not mention WDL, Docker, images, tasks, or tools.
---

# Bio-OS Pipeline Developer

## Operating Principle
This skill translates high-level analysis requirements into a complete Bio-OS pipeline by coordinating environment design and workflow authoring.

## Execution Workflow

### Step 1: Requirements engineering
Determine the exact scientific steps, tool versions, input and output contracts, and parameter flow.

- If the pipeline is being designed from conversation, gather those details from the user.
- If the pipeline comes from a reproduction card, extract the steps and dependencies from `{UUID}_p2w_card.json`.
- Before invoking a downstream CLI-based Bio-OS skill, use `bioos_cli_locator` if the `bioos` command or authentication has not been verified.

### Step 2: Environment provisioning
Every distinct task environment must be backed by a Bio-OS-compatible Docker image.

- For each unique task environment, first declare that
  `bioos_docker_registry_catalog` is required.
- Use its REST API search workflow to find an existing image, inspect the
  complete effective package inventory, and record the exact returned
  `image_url` plus evidence.
- Reuse a catalog image directly in the WDL when mandatory tools, versions,
  platform, and hardware requirements match.
- Declare `bioos_docker_builder` only when the catalog search and retry sequence
  finds no adequate image or the user explicitly requires a custom environment.
- Pass the missing packages and closest catalog candidates to the builder so it
  can choose the smallest viable base image.

### Step 3: Workflow scripting
After the images are ready:

- Explicitly declare that `bioos_wdl_scripter` is required.
- Use it to translate the logical steps and Docker image URLs into one generated WDL file.

### Step 4: Pipeline finalization
Once the WDL file is produced:

- If the user only asked for pipeline construction, present the finalized WDL and image plan.
- If the pipeline must be executed on Bio-OS immediately, explicitly declare that `bioos_platform_operator` is required to handle CLI-based deployment.
