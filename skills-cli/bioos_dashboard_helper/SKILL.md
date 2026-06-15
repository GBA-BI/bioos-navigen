---
name: bioos_dashboard_helper
description: Create the Bio-OS workspace introduction and usage-guide artifact (`__dashboard__.md`) by exporting workspace metadata, reading WDL/profile context, and uploading it with the Bio-OS CLI. Trigger this skill when a Bio-OS workspace, workflow, or local WDL tool folder needs a user-facing overview, usage guide, publishing guide, landing page, onboarding document, or other workspace-level explanation.
---

# Bio-OS Dashboard Helper

Resolve the Bio-OS CLI launcher first and refer to it as `<bioos_launch>`. If it is not known yet, explicitly load the `bioos_cli_locator` skill before running the commands below.

## Operating Principle
In Bio-OS, `__dashboard__.md` is the workspace-level introduction and usage guide. Treat "dashboard" requests as requests to explain the whole workspace to an end user, not as chart/dashboard analytics work.

This skill creates and uploads workspace-level guide content through the Bio-OS CLI:

1. export a Bio-OS workspace package
2. parse the exported RO-Crate, WDL, existing guide, and profile metadata
3. write a factual `__dashboard__.md`
4. upload `__dashboard__.md` to the target workspace

All local file paths passed to CLI commands must be absolute. Prefer credentials from environment variables or `~/.bioos/config.yaml`; pass `--ak`, `--sk`, or `--endpoint` only when the user explicitly provides overrides. Never write secrets, signed URLs, or bearer tokens into generated workspace guides.

## Execution Workflow

### Step 1: Identify the target
Determine which mode applies:

- Existing workspace introduction: the user gives one or more Bio-OS workspace names and asks to introduce, document, publish, package, explain, refresh, or make the workspace easier for users to understand.
- Existing local guide upload: the user already has a local `__dashboard__.md` or workspace usage guide and a target workspace.
- Local tool folder upload: the user provides folders containing Markdown, WDL, and inputs JSON, and needs a workspace-level guide as part of the upload/publishing flow.
- Metadata extraction: the user asks for local `meta.json` from existing `__dashboard__.md` workspace guides.

For multiple targets, process each target independently and continue after recoverable per-target failures.

### Step 2: Export an existing workspace
For an existing workspace introduction, create a per-workspace working directory:

`/tmp/bioos_dashboard_helper/<workspace_name>/`

Run the export:

`<bioos_launch> workspace export --workspace-name <workspace_name> --export-path /tmp/bioos_dashboard_helper/<workspace_name> --output json --pretty`

Find the exported `.zip`, unzip it into:

`/tmp/bioos_dashboard_helper/<workspace_name>/unzip/`

Parse `ro-crate-metadata.json` with a JSON parser. Resolve the main WDL from fields such as `MainEntity`, `mainWorkflowPath`, `hasPart`, `@graph`, or the only `.wdl` file in the export.

Fetch profile context as a supplement:

`<bioos_launch> workspace profile --workspace-name <workspace_name> --submission-limit 5 --artifact-limit-per-submission 10 --sample-rows-per-data-model 3 --output json --pretty`

If `workspace profile` fails but export succeeds, continue from the export and mark missing profile-only facts as unavailable. If export fails, do not invent a dashboard from memory.

### Step 3: Extract workspace guide facts
Build a local fact bundle from the export, WDL files, existing guide files, optional profile JSON, and optional workflow input template.

Capture:

- workspace name and description
- workflow name and purpose
- WDL input names, types, defaults, required/optional status, and meaning
- WDL outputs and output file patterns
- task runtime values such as docker, cpu, memory, disk, gpu, and preemptible
- example input JSON from export, existing guide, local inputs JSON, or `workflow input-template`
- recent successful submission/result summaries only when present in profile data

Use this command when an imported workflow exists and a template is useful:

`<bioos_launch> workflow input-template --workspace-name <workspace_name> --workflow-name <workflow_name> --output json --pretty`

Do not guess scientific meaning, file formats, reference database paths, or result locations. If a value is not declared, write `未声明` or `未提供`.

### Step 4: Write `__dashboard__.md`
Write concise Chinese Markdown unless the user requests another language. The file name must be exactly `__dashboard__.md`.

Recommended structure:

- `# <workspace_or_tool_name>使用指南`
- `## 概述`
- `## 工作流信息`
- `## 输入参数`
- `## 输出文件`
- `## 运行环境`
- `## 运行示例`
- `## 注意事项`

The workspace guide must explain what the workspace does, which workflow to run, required inputs, generated outputs, declared runtime resources, and an example JSON input shape when available.

### Step 5: Validate the workspace guide
Before upload, check:

- no AK/SK/token/signed URL/private endpoint is present
- every required WDL input appears in `输入参数`
- every WDL output appears in `输出文件`
- runtime values match the WDL, with missing values marked `未声明`
- example JSON matches the actual WDL input keys or local inputs JSON
- the guide is substantive, not a placeholder

Fix the local Markdown before uploading if any check fails.

### Step 6: Upload the workspace guide
Upload the validated file:

`<bioos_launch> workspace dashboard-upload --workspace-name <workspace_name> --local-file-path /abs/path/__dashboard__.md --output json --pretty`

Report the local path and upload status.

## Local Tool Folder Mode
Use this mode when the user provides local tool folders and needs to create or update the corresponding Bio-OS workspace guide.

For each folder:

1. Resolve one primary Markdown file, one primary `.wdl`, and one `*.inputs.json` or representative `.json`.
2. Infer `workspace_name` and `workspace_description` from the Markdown title and overview; fall back to the folder name.
3. Infer `workflow_name` from the WDL workflow block; fall back to `workspace_name`.
4. Create the workspace:
   `<bioos_launch> workspace create --workspace-name <workspace_name> --workspace-description <workspace_description> --output json --pretty`
5. Import the WDL:
   `<bioos_launch> workflow import --workspace-name <workspace_name> --workflow-name <workflow_name> --workflow-source /abs/path/workflow.wdl --workflow-desc <workflow_desc> --output json --pretty`
6. Resolve the workflow id with `workflow list` if needed:
   `<bioos_launch> workflow list --workspace-name <workspace_name> --search-keyword <workflow_name> --output json --pretty`
7. Poll import validation:
   `<bioos_launch> workflow import-status --workspace-name <workspace_name> --workflow-id <workflow_id> --output json --pretty`
8. Generate, review, and upload `__dashboard__.md` using the same workspace guide standards above.

Only submit the example inputs JSON when the user explicitly asks to run the imported workflow:

`<bioos_launch> workflow submit --workspace-name <workspace_name> --workflow-name <workflow_name> --input-json /abs/path/inputs.json --output json --pretty`

## Local Metadata Extraction
Use this mode when local folders already contain `__dashboard__.md` and the user wants `meta.json`.

For each guide, read the Markdown, extract the JSON schema below, verify the JSON against the original Markdown, and write `meta.json` beside the guide. Use empty strings or arrays for missing facts; do not invent inputs, outputs, formats, or tags.

```json
{
  "tool_name": "",
  "category": "",
  "description": "",
  "tags": [],
  "inputs": [
    {
      "name": "",
      "description": "",
      "format": "",
      "required": true
    }
  ],
  "outputs": [
    {
      "name": "",
      "description": "",
      "format": ""
    }
  ]
}
```

## Final Reporting
For one target, report the action, local guide or metadata path, upload status, and any validation warning.

For batches, report a compact table with target, action, local path, status, and failure reason. Do not include raw credentials or large JSON dumps.
