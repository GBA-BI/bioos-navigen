---
name: bioos_wdl_scripter
description: Generate, validate, diagnose, and repair WDL workflows for Bio-OS platform execution. Use when custom WDL code needs to be developed or edited, before Bio-OS import or submission, when womtool/miniwdl validation fails, or when a Bio-OS/Cromwell/TES run fails, stalls, produces no outputs, or emits suspicious runtime logs.
---

# Bio-OS WDL Scripter

## Operating Principle
Generate platform-compliant WDL 1.0, validate every new or edited WDL before import, and diagnose run failures from evidence. Apply the smallest responsible repair and prove it through validation or a minimal run. Preserve the original WDL, inputs, logs, image reference, and run identifiers before editing.

## Route the request

- For a new workflow, generate the WDL and run preflight validation.
- For an edited WDL or a validation failure, inspect the full WDL project, repair the first parser, import, or type error, and repeat preflight validation.
- For a failed or stalled run, diagnose the run evidence first. Re-run preflight validation after every WDL repair.
- For image build failures that occur before a WDL run exists, identify the relevant evidence and hand image work to `bioos_docker_builder`.

## Execution Workflow

### Step 1: Write the WDL script

Generate one complete `.wdl` file locally.

#### WDL Generation Standard

You must follow these rules.

1. Overall structure

- Derive the workflow from the user request or any project card already in context
- Break the scientific goal into discrete logical steps
- Implement each step as its own `task`
- Keep the full set of tasks and the `workflow` block in one file
- Do not leave placeholders, pseudo-code, or hardcoded reference paths
- Every required file must be exposed as a `File` input

2. Task-level structure

- Each `task` must have an `input` block
- File inputs must use `File`, not `String`
- Each task must declare these runtime variables with sensible defaults:
  - `String docker_image`
  - `Int memory_gb = 8`
  - `Int disk_space_gb = 100`
  - `Int cpu_threads = 4`
- Do not embed multi-line Python, R, or Perl scripts inside `command <<< >>>`
- Every task must include this exact runtime mapping:

```wdl
runtime {
    docker: docker_image
    memory: memory_gb + "GB"
    disk_space: disk_space_gb + "GB"
    cpu: cpu_threads
}
```

- Every task must include an explicit `output` block

3. Workflow structure

- The `workflow` block is mandatory
- The `workflow` block must connect tasks in the intended execution order

### Step 2: Run preflight validation

1. Inspect the WDL entry file and every local `import`. Determine the project root instead of validating an entry file without its dependencies.
2. Validate a single-file WDL directly with `curl`:

   ```bash
   curl --fail-with-body --silent --show-error \
     -X POST "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/validate" \
     -F "wdl_file=@/abs/path/main.wdl"
   ```

3. For a WDL project with local imports, zip the `.wdl` files while preserving their paths and use archive mode:

   ```bash
   WDL_ARCHIVE_DIR="$(mktemp -d)"
   (cd /abs/path/project && zip -q -r "${WDL_ARCHIVE_DIR}/project.zip" . -i '*.wdl')
   curl --fail-with-body --silent --show-error \
     -X POST "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/validate" \
     -F "archive_file=@${WDL_ARCHIVE_DIR}/project.zip;type=application/zip" \
     -F "root_wdl_path=main.wdl"
   ```

4. Treat HTTP `200` plus response `ok=false` as a WDL validation failure. Use `stderr`, or `stdout` when `stderr` is empty, as repair evidence.
5. Fix the first parser, import, or type error with the smallest change and validate again. Continue until `ok=true`; HTTP success alone does not make the WDL ready.
6. If the remote service is unavailable, record a transport/service failure. Check health with `curl --fail-with-body --silent --show-error "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/healthz"`. Fall back to an already available `womtool validate` or `miniwdl check`; do not report service unavailability as invalid WDL.
7. After validation passes, import or update the workflow, poll Bio-OS import status until `Succeeded` or `ReadyToUse`, and only then submit.

Read [remote-validator-api.md](references/remote-validator-api.md) before changing the service URL, request mode, timeout, or response handling.

### Step 3: Diagnose a failed or stalled run

1. Collect the exact WDL, submitted `inputs.json`, submission ID, run ID, workflow/run status, import status, image reference, stdout, stderr, rendered execution script, and available Cromwell/TES/tool logs. Do not wait for every artifact when the existing evidence is decisive.
2. Trace the run in execution order: validation/import, input evaluation, scheduling, image startup, task command, then output collection. Quote the earliest concrete error rather than a later wrapper failure.
3. Read [error-catalog.md](references/error-catalog.md) and classify the evidence under one or more common categories:

   1. GPU and accelerators
   2. outputs and result collection
   3. container images and startup
   4. WDL validation, import, and versioning
   5. inputs, localization, and data contracts
   6. resources, scheduling, and nested workflows
   7. task execution environments and tool contracts

4. Use a catalog entry only when the failure can recur across workflows, has a mechanism-based evidence pattern, and has a reusable confirmation and repair. Mark one-off code mistakes such as a missing `import os`, a typo, or a model-specific exception as `project-specific/not cataloged`.
5. Confirm the hypothesis with the narrowest relevant check. Examples include inspecting the exact image platform, running the tool's real `--help`, listing files in the Cromwell execution directory, comparing input metadata, or checking framework-level CUDA state.
6. Patch the smallest responsible surface: WDL, inputs JSON, image, runner script, or platform configuration. Do not hide a failed command with `|| true`, fabricate missing scientific results, or broaden resource requests without evidence.
7. Re-run preflight validation after every WDL edit. If execution or repair was requested, use `bioos_platform_operator` for a minimal smoke test before a costly full rerun.

### Step 4: Return the result

For a generated or edited WDL, return the file path or final content, validation method, validation result, and import readiness. Mark it ready for Bio-OS import only after validation returns `ok=true`; otherwise return it as a draft with the blocker.

For a runtime diagnosis, return:

- failing stage and status
- common category, or `project-specific/not cataloged`
- primary root cause and confidence
- exact evidence and artifact source
- smallest proposed or applied repair
- validation and smoke-test results, if run
- unresolved risks, missing evidence, and the next discriminating check

Distinguish `validated`, `import-ready`, `smoke-tested`, and `production-verified`. Never infer production readiness from WDL validation or synthetic data alone.

## Safety boundaries

- The default remote validator is an unauthenticated internal service. Do not place credentials in WDL text or upload sensitive WDL outside the approved network boundary.
- Redact tokens, credentials, and unrelated biological identifiers from shared logs while preserving the failing lines.
- Preserve image tags/digests and run identifiers in the report.
- Ask before initiating a costly full workflow rerun. Syntax validation and read-only log inspection do not require confirmation.
