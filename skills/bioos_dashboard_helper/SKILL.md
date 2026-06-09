---
name: bioos_dashboard_helper
description: Create the Bio-OS workspace introduction and usage-guide artifact (`__dashboard__.md`) by exporting workspace metadata, reading WDL/profile context, and uploading it with Bio-OS platform tools. Trigger this skill when a Bio-OS workspace, workflow, or local WDL tool folder needs a user-facing overview, usage guide, publishing guide, landing page, onboarding document, or other workspace-level explanation.
---

# Bio-OS Dashboard Helper

## 1. Operating Principle
In Bio-OS, `__dashboard__.md` is the workspace-level introduction and usage guide. Treat "dashboard" requests as requests to explain the whole workspace to an end user, not as chart/dashboard analytics work.

This skill creates and uploads workspace-level guide content through Bio-OS platform tools:

1. export a Bio-OS workspace package
2. parse the exported RO-Crate, WDL, existing guide, and profile metadata
3. write a factual `__dashboard__.md`
4. upload `__dashboard__.md` to the target workspace

All local file paths passed to tools must be absolute. Never print, write, or commit access keys, secret keys, bearer tokens, signed URLs, or private model keys.

## 2. Tool Surface
Use these Bio-OS tools when available:

- `export_bioos_workspace`: export an existing workspace to a local directory.
- `upload_dashboard_file`: upload a local `__dashboard__.md` to the workspace root.
- `create_workspace_bioos`: create a workspace for a local tool folder.
- `import_workflow`: import a local WDL file or WDL directory.
- `check_workflow_import_status`: poll WDL import validation.
- `submit_workflow`: optionally submit an example inputs JSON after import.
- `get_workspace_profile`: inspect an existing workspace when export data is incomplete.

Use local file operations directly for archive extraction, JSON parsing, Markdown writing, and folder discovery. Do not use shell commands to display secrets.

## 3. Existing Workspace Guide
Use this workflow when the user gives one or more Bio-OS workspace names and asks to introduce, document, publish, package, explain, refresh, or make the workspace easier for users to understand.

1. Create a local working directory such as `/tmp/bioos_dashboard_helper/<workspace_name>`.
2. Call `export_bioos_workspace` with `workspace_name` and `export_path`. Include endpoint or credentials only when the active tool requires explicit values.
3. Find the exported archive in `export_path`, unzip it to `export_path/unzip`, and parse `ro-crate-metadata.json` with a JSON parser.
4. Resolve the main WDL path from RO-Crate fields such as `MainEntity`, `mainWorkflowPath`, `hasPart`, `@graph`, or the only `.wdl` file. If multiple WDLs are relevant, read each one and identify the top-level workflow.
5. Call `get_workspace_profile` when export data is incomplete or when recent workflow/data-model context would improve the guide.
6. Build a local fact bundle from the workspace export, WDL, existing guide files, and optional profile result:
   - workspace name and description
   - workflow name and purpose
   - WDL input names, types, defaults, required/optional status, and meaning
   - WDL outputs and output file patterns
   - task runtime values such as docker, cpu, memory, disk, gpu, and preemptible
   - example input JSON from export, existing guide, local inputs JSON, or platform input template
   - recent successful submission/result summaries only when present in profile data
7. Write `__dashboard__.md` locally and validate it before upload.
8. Call `upload_dashboard_file` with `workspace_name` and the absolute `local_file_path`.

If export fails, do not invent a guide from memory. If profile data is unavailable, continue from the export and mark missing profile-only facts as unavailable.

## 4. Local Tool Folder Mode
Use this workflow when the user provides local tool folders and needs to create or update the corresponding Bio-OS workspace guide.

For each folder:

1. Resolve one primary Markdown file, one primary `.wdl`, and one `*.inputs.json`; if absent, use one representative `.json`.
2. Infer `workspace_name` and `workspace_description` from the Markdown title and overview; fall back to the folder name.
3. Infer `workflow_name` from the WDL workflow block; fall back to `workspace_name`.
4. Call `create_workspace_bioos` with `workspace_name`, `workspace_description`, and workspace type `workflow` when required by the tool.
5. Call `import_workflow` with `workspace_name`, `workflow_name`, the absolute WDL path, and a concise `workflow_desc`.
6. Poll `check_workflow_import_status` until success or failure. On failure, summarize the validation error and stop for that folder.
7. Only call `submit_workflow` with the discovered inputs JSON when the user explicitly asks to run the imported workflow.
8. Generate, validate, and upload `__dashboard__.md` using the same workspace guide standards below.

## 5. Local Metadata Extraction
Use this workflow when local folders already contain `__dashboard__.md` and the user wants `meta.json`.

For each guide:

1. Read `__dashboard__.md`.
2. Extract the strict JSON schema below.
3. Use empty strings or empty arrays for missing facts. Do not invent inputs, outputs, formats, or tags.
4. Verify the JSON against the original Markdown: remove hallucinated inputs/outputs, restore omitted documented inputs/outputs, and correct file formats.
5. Write `meta.json` beside the guide.

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

## 6. Workspace Guide Standard
Write concise Chinese Markdown unless the user requests another language. The file must be named exactly `__dashboard__.md`.

Use this structure:

- `# <workspace_or_tool_name>使用指南`
- `## 概述`
- `## 工作流信息`
- `## 输入参数`
- `## 输出文件`
- `## 运行环境`
- `## 运行示例`
- `## 注意事项`

Quality checks before upload:

- no access keys, secret keys, bearer tokens, signed URLs, or private model keys are present
- every required WDL input appears in `输入参数`
- every declared WDL output appears in `输出文件`
- runtime values match the WDL; missing values are marked `未声明`
- the run example uses the actual inputs JSON structure when available
- the guide is substantive, not a placeholder

## 7. Final Reporting
For one target, report the action, local guide or metadata path, upload status, and any validation warning.

For batches, report a compact table with target, action, local path, status, and failure reason. Do not include raw credentials or large JSON dumps.
