---
name: bioos_platform_operator
description: Submit Bio-OS WDL workflows without monitor mode, poll run status explicitly, prepare `inputs.json`, and create IES application instances through Bio-OS CLI commands after workflow paths and input parameters are known.
---

# Bio-OS Platform Operator

Resolve the Bio-OS CLI launcher first and refer to it as `<bioos_launch>`. If it is not known yet, explicitly load the `bioos_cli_locator` skill before running the commands below.

## Operating Principle
This skill manages Bio-OS execution for both WDL workflows and IES applications.

## 1. WDL Workflow Submission

### Step 1: Register or resolve the workflow
Determine whether the WDL already exists on Bio-OS.

- Scenario A: local or bundled WDL
  1. Import it:
     `<bioos_launch> workflow import --workspace-name <workspace_name> --workflow-name <workflow_name> --workflow-source /abs/path/to/workflow.wdl`
  2. Resolve the imported workflow id with:
     `<bioos_launch> workflow list --workspace-name <workspace_name> --search-keyword <workflow_name> --output json --pretty`
  3. Match the exact workflow name and record its `ID`
  4. Poll validation with:
     `<bioos_launch> workflow import-status --workspace-name <workspace_name> --workflow-id <workflow_id>`
  5. Continue only when the status becomes `Succeeded`

- Scenario B: existing workflow on Bio-OS
  1. Reuse the existing workflow name directly
  2. If needed, verify its presence with `<bioos_launch> workflow list`

### Step 2: Prepare `inputs.json`
Generate the template and fill it locally.

1. Get the template:
   `<bioos_launch> workflow input-template --workspace-name <workspace_name> --workflow-name <workflow_name> --output json --pretty`
2. Write a local `inputs.json` that fills every required value.
3. For WDL `File` inputs, use `drs://...`, workspace `s3://...`, or local absolute file paths. The Bio-OS CLI submit command (`<bioos_launch> workflow submit ...`) automatically uploads existing local paths to `input_provision/` and replaces them with S3 URLs. For large or reused files, pre-upload with `<bioos_launch> file upload --workspace-name <workspace_name> --source /abs/path/to/file --target input_provision/ --skip-existing --output json --pretty`, then put the returned `s3_url` in `inputs.json`. Do not convert local paths or workspace S3 URLs to DRS.
4. If the template asks for values you cannot safely infer, ask the user immediately. Do not invent reference paths or database locations.
5. For batch runs, the final `inputs.json` must be a JSON array of objects, for example:

```json
[
  {"TargetWDL.id": "ID1"},
  {"TargetWDL.id": "ID2"}
]
```

### Step 3: Submit and poll status
1. Submit the workflow without monitor mode:
   `<bioos_launch> workflow submit --workspace-name <workspace_name> --workflow-name <workflow_name> --input-json /abs/path/to/inputs.json`
2. Record the submission id from the CLI stdout. If stdout parsing is ambiguous, resolve the newest exact-match submission with:
   `<bioos_launch> submission list --workspace-name <workspace_name> --workflow-name <workflow_name> --output json --pretty`
3. Poll the run status with:
   `<bioos_launch> workflow run-status --workspace-name <workspace_name> --submission-id <submission_id>`
4. On failure, download logs with:
   `<bioos_launch> submission logs --workspace-name <workspace_name> --submission-id <submission_id> --output-dir /local/logs`
5. On success, save the full `workflow run-status` stdout to a temporary text file and parse it with the bundled script:
   `python3 scripts/parse_workflow_outputs.py -i /tmp/run_status.txt -o /tmp/results.csv`
6. Read the CSV and use it as the structured output manifest for downstream work.

## 2. IES Applications

### Step 1: Create the instance
Launch the IES app with a validated image URL:

`<bioos_launch> ies create --workspace-name <workspace_name> --ies-name <ies_name> --ies-desc <description> --ies-image <docker_image> --output json --pretty`

### Step 2: Poll readiness
Check status with:

`<bioos_launch> ies status --workspace-name <workspace_name> --ies-name <ies_name> --output json --pretty`

Keep polling until the status becomes `Running`.

### Step 3: Handoff or debug
- If the status becomes `Running`, tell the user the environment is ready and share the access details.
- If the instance fails before `Running`, inspect the events with:
  `<bioos_launch> ies events --workspace-name <workspace_name> --ies-name <ies_name> --output json --pretty`
