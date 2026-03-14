---
name: bioos_pipeline_developer
description: Interactively design and assemble complete, deployable analytical pipelines for Bio-OS. Trigger this skill when the user or Agent needs to develop a new analysis pipeline to run on the Bio-OS platform.
---

# Bio-OS Pipeline Developer

## 1. Operating Principle
This procedure outlines how to translate high-level analysis requirements into a fully functional, deployable analytical pipeline. Creating a pipeline is a multi-step orchestration process that involves designing the runtime environment and the workflow logic.

## 2. Execution Workflow

### Step 1: Requirements Engineering
Determine the exact sequence of scientific tools, versions, and desired parameter flows for the analysis.
- If creating a pipeline from a conversation, gather these details comprehensively from the user.
- If this pipeline is being recreated from a paper (Paper2Workspace mode), extract the exact commands and dependencies directly from the `{UUID}_p2w_card.json`.

### Step 2: Environment Provisioning
Every distinct tool step (Task in WDL) in the pipeline must run inside a Bio-OS compatible docker container.
- For each unique environment needed, explicitly declare that the **`bioos_docker_builder`** skill is required to resolve dependencies and build a `linux/amd64` Docker image.
- By stating this explicitly, you trigger the progressive disclosure of the `bioos_docker_builder` guidelines into your context.
- Once the environment builder guidelines are loaded, follow them to obtain a validated `docker_image` URL. Record this URL for the next step.

### Step 3: Workflow Scripting
Once all required `docker_image` URLs are built and validated:
- Explicitly declare that the **`bioos_wdl_scripter`** skill is required to translate the logical steps and Docker URLs into a compliant WDL file.
- This will load the WDL structuring guidelines into your context. Follow those rules to generate and validate the `.wdl` code.

### Step 4: Pipeline Finalization
Once the validated WDL file is produced, the pipeline development is complete.
- If the user simply wanted the pipeline built, present the finalized code to them.
- If the pipeline needs to be automatically executed on the cloud platform immediately, explicitly state that the **`bioos_platform_operator`** skill MUST be loaded into your context to handle deployment.
