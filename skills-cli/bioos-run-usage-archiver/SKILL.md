---
name: bioos-run-usage-archiver
description: Archive Bio-OS workflow run resource usage into a durable Markdown or text report under the submission object-storage folder using Bio-OS CLI commands. Use when a Bio-OS submission or run has completed and the user wants CPU, memory, GPU, storage, task status, requested resources, metric summaries, or lightweight utilization analysis preserved for later review.
---

# Bio-OS Run Usage Archiver

## Operating Principle

After a run finishes, preserve the usage evidence by generating a small report and uploading it into the submission's object-storage folder.

Resolve the Bio-OS CLI launcher first and refer to it as `<bioos_launch>`. If it is not known yet, explicitly load the `bioos_cli_locator` skill before running commands.

Never print, write, or commit access keys, secret keys, bearer tokens, AAIPassport values, signed URLs, or private credentials. Do not include raw `submission list` JSON in the final answer or report because it can include sensitive fields.

## Quick Start

Use only the commands relevant to the identifiers the user provided.

```bash
<bioos_launch> submission list --workspace-name <workspace> --page-size 20 --output json --pretty
<bioos_launch> run list --workspace-name <workspace> --submission-id <submission_id> --page-size 0 --output json --pretty
<bioos_launch> run tasks --workspace-name <workspace> --run-id <run_id> --page-size 0 --output json --pretty
<bioos_launch> run metric-data --workspace-name <workspace> --run-id <run_id> --task-name <task_name> --period 1m --start-time <task_start> --end-time <task_finish> --output json --pretty
```

Then write a compact local Markdown or text report from the CLI outputs and upload it:

```bash
<bioos_launch> file upload --workspace-name <workspace> --source /abs/path/to/report.md --target <submission_target_prefix>/resource_usage/ --flatten --output json --pretty
```

## Workflow

1. Confirm the target:
   - Require the workspace name and either a submission id or a run id.
   - If neither a submission id nor a run id is provided or already available in the conversation, ask the user which run or submission should be archived before querying Bio-OS.
   - If only a run id is provided, use it for task and metric queries; resolve the submission folder from task log paths when possible, otherwise ask the user for the submission id before upload.
2. If a submission id is known, identify submission metadata:
   `<bioos_launch> submission list --workspace-name <workspace> --page-size 20 --output json --pretty`
3. If a submission id is known, list runs under the submission:
   `<bioos_launch> run list --workspace-name <workspace> --submission-id <submission_id> --page-size 0 --output json --pretty`
4. If only a run id is known, skip submission/run listing and list tasks directly.
5. For each target run, list tasks:
   `<bioos_launch> run tasks --workspace-name <workspace> --run-id <run_id> --page-size 0 --output json --pretty`
6. For each task with complete `StartTime` and `FinishTime`, query metrics with period `1m` unless the user asks for another granularity:
   `<bioos_launch> run metric-data --workspace-name <workspace> --run-id <run_id> --task-name <task_name> --period 1m --start-time <StartTime> --end-time <FinishTime> --output json --pretty`
7. Summarize metric arrays by point count, min, average, and peak. Use local JSON tooling such as `jq`, spreadsheet-style calculation, or Codex reasoning over the bounded JSON output. Keep the raw time series out of the final report unless the user explicitly asks for it.
8. Write the report to a local `.md` or `.txt` file.
9. Upload the report with `file upload` to the submission object-storage folder.
10. Report back only the concise result: workspace, submission, run count, task count, local report path, uploaded object key or prefix, and any metric gaps.

## Report Content

Include these facts:

- workspace, submission id/name/status, run ids/statuses, task names/statuses
- run and task start/finish times as both Unix timestamps and Asia/Shanghai-readable time unless the user requests another timezone
- requested resources from `ResourceClaimed`: CPUCore, MemoryGiB, StorageGiB, GPUGiB
- metric summaries for CPU, memory, storage, and GPU when available
- lightweight notes such as memory/GPU/storage headroom, missing metric windows, failed metric queries, or unusually high peak-to-claim ratios

Keep the report compact. Do not embed full metric time series by default.

## Metric Gaps

If `run metric-data` fails or returns empty arrays:

- still write and upload the report
- preserve task status, timestamps, logs, and requested resources
- add a clear note that detailed metric data was unavailable

## Upload Target

Prefer the submission's `FinalExecutionDir` when available. Convert:

`s3://<bucket>/analysis/<submission_id>`

to the workspace-internal target prefix:

`analysis/<submission_id>/resource_usage/`

If `FinalExecutionDir` is unavailable, fall back to:

`analysis/<submission_id>/resource_usage/`

The uploaded file should be small, deterministic, and named with the submission id and generation timestamp.

## CLI-Only Report Template

Use this compact Markdown structure:

```markdown
# Bio-OS Run Resource Usage Report - <submission_id>

- Workspace: <workspace>
- Submission: <submission_id> / <name> / <status>
- Submission time: <start> -> <finish>
- Metric period: 1m

## Runs

| Run ID | Status | Start | Finish | Duration(s) | Workflow |
|---|---|---|---|---:|---|

## Task: <task_name>

- Run ID: <run_id>
- Status: <status>
- Requested resources: CPUCore=<n>, MemoryGiB=<n>, StorageGiB=<n>, GPUGiB=<n>

| Metric | Points | Average | Peak |
|---|---:|---:|---:|
| CPU usage | <n> | <avg> | <max> |
| Memory usage | <n> | <avg> | <max> |
| Storage usage | <n> | <avg> | <max> |
| GPU usage | <n> | <avg> | <max> |

## Notes

- <short resource-utilization observations>
- Sensitive fields and signed URLs are excluded.
```
