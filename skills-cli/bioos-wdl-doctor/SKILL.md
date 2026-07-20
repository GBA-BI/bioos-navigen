---
name: bioos-wdl-doctor
description: Validate, diagnose, and repair Bio-OS WDL workflows using reusable cross-workflow failure classes for GPU, outputs, container startup, validation/import, inputs, resources, and execution environments. Use after generating or editing a .wdl file, before Bio-OS import or submission, when womtool/miniwdl validation fails, or when a Bio-OS/Cromwell/TES run fails, stalls, produces no outputs, or emits suspicious runtime logs.
---

# Bio-OS WDL Doctor

Use evidence to identify the failing stage, apply the smallest repair, and prove the repair through validation or a minimal run. Preserve the original WDL, inputs, logs, image reference, and run identifiers before editing.

## Keep only common failure patterns

Add a problem to the reusable catalog only when all of these are true:

- It can recur across different workflows or tool stacks.
- Its cause comes from a WDL, Bio-OS, Cromwell/TES, container, resource, file-contract, or runtime-environment mechanism.
- It has a recognizable evidence pattern and a discriminating confirmation check.
- It has a reusable prevention or repair action.

Diagnose project-specific coding mistakes for the current run, but do not add them to the catalog. Exclude examples such as a missing `import os`, a misspelled variable, a model-specific algorithm exception, or one workflow's private filename. If a specific incident exposes a general mechanism, record only the generalized mechanism—for example, "runtime image dependency is not packaged," not "workflow X forgot package Y."

## Route the case

- For a newly written or edited WDL, run the preflight workflow before import.
- For a failed or stalled run, collect run evidence and follow the runtime workflow.
- For a run failure after WDL changes, diagnose the run first, repair the file, then repeat preflight validation.
- For image build failures that occur before a WDL run exists, hand image work to `bioos_docker_builder` after identifying the relevant evidence.

## Preflight workflow

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

4. Treat HTTP `200` plus response `ok=false` as a WDL validation failure. Use `stderr`, or `stdout` when `stderr` is empty, as the repair evidence.
5. Fix the smallest syntax, import, or type error and validate again. Continue until `ok=true`; do not declare the WDL ready merely because the HTTP request succeeded.
6. If the remote service is unavailable, record it as a transport/service failure. Check its health with `curl --fail-with-body --silent --show-error "${BIOOS_WDL_VALIDATOR_URL:-http://10.20.17.123:8078}/api/v1/wdl/healthz"`. Fall back to an already available `womtool validate` or `miniwdl check`; do not mislabel service unavailability as invalid WDL.
7. After validation passes, import or update the workflow, poll Bio-OS import status until `Succeeded` or `ReadyToUse`, and only then submit.

Read [remote-validator-api.md](references/remote-validator-api.md) before changing the service URL, request mode, timeout, or response handling.

## Runtime diagnosis workflow

1. Collect the WDL, exact `inputs.json`, submission ID, run ID, workflow/run status, import status, image reference, stdout, stderr, execution script, and available Cromwell/TES/tool logs. Do not wait for every artifact when the existing evidence is already decisive.
2. Read the collected artifacts directly. Trace the run in execution order—validation/import, input evaluation, scheduling, image startup, task command, then output collection—and quote the earliest concrete error rather than a later wrapper failure.
3. Read [error-catalog.md](references/error-catalog.md) and assign the evidence to one or more of these common categories:

   1. GPU and accelerators
   2. outputs and result collection
   3. container images and startup
   4. WDL validation, import, and versioning
   5. inputs, localization, and data contracts
   6. resources, scheduling, and nested workflows
   7. task execution environments and tool contracts

   Require the catalog's evidence pattern and confirmation check. If no common entry fits, report `project-specific/not cataloged` instead of forcing a match or expanding the catalog with a one-off mistake.
4. Within the matched categories, identify the earliest failing execution stage. Prefer the earliest causal failure over later wrapper errors.
5. Confirm the hypothesis with the narrowest relevant check. Examples include inspecting the actual image platform, running the tool's real `--help`, listing files in the Cromwell execution directory, comparing input metadata, or checking the framework-level CUDA state.
6. Patch the smallest responsible surface: WDL, inputs JSON, image, runner script, or platform configuration. Do not hide a failed command with `|| true`, fabricate a missing scientific result, or broaden resource requests without evidence.
7. Re-run preflight validation after every WDL edit. If the user requested execution or repair, hand the validated workflow to `bioos_platform_operator` for a minimal smoke test before a full rerun.

## Diagnosis report

Return all of the following:

- failing stage and status
- common category, or `project-specific/not cataloged`
- primary root cause, with confidence
- exact evidence and artifact source
- smallest proposed or applied repair
- validation result and smoke-test result, if run
- unresolved risks, missing evidence, and the next discriminating check

Distinguish `validated`, `import-ready`, `smoke-tested`, and `production-verified`. Never infer production readiness from WDL validation or synthetic data alone.

## Safety boundaries

- The default remote validator is an unauthenticated internal service. Do not place credentials in WDL text, and do not upload sensitive WDL outside the approved network boundary.
- Redact tokens, credentials, and unrelated biological identifiers from shared logs while preserving the failing lines.
- Preserve image tags/digests and run identifiers in the report; do not overwrite them during diagnosis.
- Ask before initiating a costly full workflow rerun. Syntax validation and read-only log inspection do not require that confirmation.
