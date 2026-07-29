# Bio-OS WDL common failure catalog

## Contents

- Admission rule
- 1. GPU and accelerators
- 2. Outputs and result collection
- 3. Container images and startup
- 4. WDL validation, import, and versioning
- 5. Inputs, localization, and data contracts
- 6. Resources, scheduling, and nested workflows
- 7. Task execution environments and tool contracts
- Repair and verification loop

## Admission rule

Keep an issue only when it is cross-workflow, mechanism-based, recognizable from evidence, and paired with a reusable confirmation and repair. Do not catalog a missing `import os`, a typo, a model-specific exception, a private filename, or a single project's scientific bug.

When a specific incident reveals a common mechanism, keep only the mechanism. For example:

| Specific incident | Reusable form |
| --- | --- |
| One task forgot a Python import | Do not catalog; fix that task only |
| Several images fail because dependencies are absent outside the source directory | Runtime image dependency/package path is incomplete |
| One project wrote `result_x.tsv` to `/app` | WDL outputs must exist under the Cromwell execution directory |
| One model used an incompatible CUDA wheel | Framework CUDA build must match the Bio-OS node driver/GPU |

## 1. GPU and accelerators

### 1.1 GPU resource envelope

The current verified Bio-OS GPU allocation is `4c16g`, `gpuCount=1`, and `gpuType="Tesla-V100"`. Requests above the verified envelope can remain queued without starting a container. Treat this as a platform-specific rule and reconfirm it when infrastructure changes.

### 1.2 Driver, CUDA, and framework compatibility

The recorded nodes use Tesla V100/Volta `sm_70`, NVIDIA Driver `470.129.06`, and report CUDA compatibility up to 11.4. `torch==2.4.0+cu121` failed while `torch==2.0.0+cu117` was verified. Do not blindly preserve these exact versions after node upgrades; preserve the compatibility rule.

Confirm with both layers:

```bash
nvidia-smi
python - <<'PY'
import torch
print(torch.__version__, torch.version.cuda)
print(torch.cuda.is_available(), torch.cuda.device_count())
if torch.cuda.is_available():
    print(torch.cuda.get_device_name(0))
    print(torch.cuda.get_device_capability(0))
    print(torch.ones(1, device="cuda"))
PY
```

GPU visibility in `nvidia-smi` does not prove framework CUDA initialization works.

### 1.3 GPU task stability

For long GPU/PyTorch tasks, use short temporary paths (`TMPDIR=/tmp`), low DataLoader worker counts, unbuffered timestamped logs, and bounded timeouts. Distinguish unscheduled GPU work, CUDA initialization failure, and an application deadlock.

## 2. Outputs and result collection

### 2.1 Execution-directory contract

Cromwell collects outputs from the task execution directory. Files left under `/app`, `/root`, `/opt`, or `/workspace` are not automatically collected.

```bash
set -euo pipefail
EXEC_DIR="$(pwd)"
mkdir -p "${EXEC_DIR}/results"

cd /opt/tool
python run.py --out "${EXEC_DIR}/results/result.tsv"

cd "${EXEC_DIR}"
test -s results/result.tsv
find results -maxdepth 2 -type f -print
```

Typical evidence includes command `rc=0` followed by `not exist, just skip`, `cromwell_glob_control_file`, or output evaluation failure.

### 2.2 Stable paths versus `glob()`

Use a fixed path for each single critical output. Use `glob()` only for genuinely variable collections, and verify the match count in the command log. Avoid `glob()[0]` for a required result whose real filename can be made stable.

### 2.3 Optional branches

Every declared non-optional `File` must exist on every successful branch. For a disabled optional analysis, return a truthful empty table, manifest, or notice only when that preserves the output contract; never fabricate scientific results.

### 2.4 Output manifests and failure logs

Do not expose `/cromwell-executions/...` paths in user-facing summaries. Return stable filenames or platform output URLs. Preserve stdout, stderr, the rendered execution script, and tool logs as outputs when the failure evidence would otherwise disappear.

## 3. Container images and startup

### 3.1 Image architecture

`exec format error` or an arm64/amd64 mismatch means an incompatible image reached an amd64 node. Build for `linux/amd64` or publish a verified multi-architecture manifest. Validate the registry manifest and run `uname -m` inside the exact image.

### 3.2 Manifest digest, pull, and authentication

Use a pull-tested manifest/index digest. A config digest is not a pullable image reference. Keep the WDL default image and `inputs.json` override aligned. When execution duration is zero, check image resolution, registry authentication, and scheduling before debugging the scientific command.

### 3.3 CPU instruction compatibility

`linux/amd64` only establishes the ISA family. `SIGILL`, `Illegal instruction`, or return `-4` can mean a native binary uses CPU extensions absent from the node. Run the real binary on the target CPU class and pin/rebuild a compatible version.

### 3.4 ENTRYPOINT and shell contract

Prefer WDL images without a strong `ENTRYPOINT`/`CMD`, so Cromwell controls the injected command. Confirm that `bash`, `coreutils`, and other assumed shell tools exist. If an entrypoint is unavoidable, test the rendered execution command with the exact image configuration.

### 3.5 Build completeness and cache

Build/push success does not prove the runtime path works. Verify critical executables, imports, prewarmed environments/caches, and one minimal real command. Use a new immutable tag/digest for fixes. Inspect the built image before assuming Docker layer cache contains the latest code or data.

## 4. WDL validation, import, and versioning

### 4.1 Validate the complete project

Validate the entry WDL with every local import and preserved relative path. Fix the first parser/type error; later messages can be cascades. Require remote HTTP `200` plus `ok=true`.

### 4.2 WDL type and structure rules

- Prefer WDL 1.0 unless the deployed parser/backend is verified for another version.
- For `T?`, use `select_first`/`select_all` and same-type branches instead of assuming `defined()` narrows every expression.
- Keep one intended `version`, one main workflow, and unique task/workflow names after multi-round edits.

### 4.3 CLI capability drift

Do not assume a documented `bioos workflow validate` exists in the installed CLI. Check the current `--help`. Use the remote womtool service or an already installed local validator, then use Bio-OS import/import-status as the platform-specific gate.

### 4.4 Asynchronous import and name conflicts

An accepted import/update is not immediately submit-ready. Poll until `Succeeded`/`ReadyToUse`. If the platform rejects a duplicate name and does not support the intended update path, use an explicit versioned workflow name and record which version is current.

## 5. Inputs, localization, and data contracts

### 5.1 Singleton versus batch JSON

For a single run, submit one JSON object. A one-element top-level array can select Bio-OS batch mode and stringify nested `Array[String]`/`Array[File]`, producing a `JsString` to `Array` coercion error. Test genuine batch behavior with a minimal input before full data.

### 5.2 `File` values and localized paths

Keep real file dependencies as WDL `File`, not `String` object-store URIs. When wrapping Nextflow/Snakemake, pass engine-localized files to the child workflow. A samplesheet containing an original workspace `s3://` URI can make the child tool use public AWS semantics and fail with `NoSuchBucket`.

Avoid basename-only discovery when different inputs can share a filename. Stage files explicitly or maintain an exact mapping.

### 5.3 Hidden dependencies and migration inventory

Before migrating a research repository, inventory code, weights, databases, indexes, preprocessing artifacts, example inputs, expected outputs, and data licenses. Scan for author-environment paths such as `/lustre`, `/home`, `sbatch`, and `conda activate`. Separate training requirements from inference/smoke-test requirements.

### 5.4 Internal metadata compatibility

Valid paths can still contain incompatible data. Check:

- VCF samples, contigs, FORMAT fields, and indexes
- FASTA/FAI names and lengths
- BED/reference contig naming and coordinates
- CSV/TSV delimiters, columns, sample IDs, and file mapping
- compressed extension versus actual bytes (`gzip -t`)

Treat mock/synthetic input as a smoke test, not production or paper reproduction.

## 6. Resources, scheduling, and nested workflows

### 6.1 Backend-supported runtime keys

`UnknownRuntimeKey` means a field may be ignored. Do not assume `disk_space` or another generic attribute took effect because it appears in WDL. Compare the declaration with Bio-OS `ResourceClaimed` and container `nproc`, `free -h`, `df -h`, and `nvidia-smi`.

### 6.2 Outer and inner resource envelopes

For a WDL wrapper around Nextflow/Snakemake, the outer task must cover the largest static child request. Small test data does not reduce a child process's declared memory. Put smoke-only downscaling behind an explicit non-production flag.

### 6.3 Disk exhaustion

For `No space left on device`, measure the actual failing filesystem. Reduce Docker build context, repeated model/data layers, task intermediates, and logs. Do not rely on a runtime disk field that the backend reports as unsupported.

## 7. Task execution environments and tool contracts

### 7.1 Working directory and runner structure

Save `EXEC_DIR="$(pwd)"`. Test from an empty working directory, not only the source directory. Put complex Python/R logic in a bundled runner script rather than a large WDL heredoc.

### 7.2 Heredoc rendering

`wanted 'EOF'` plus `unexpected end of file` usually means the terminator was indented. Keep the opener, content, and terminator at column zero, or replace the heredoc with a runner file/`printf`.

### 7.3 Actual CLI contract

WDL validation cannot check command options. For `invalid choice`, `unknown option`, or `unrecognized arguments`, inspect `--version`, top-level `--help`, and subcommand `--help` in the exact submitted image. Base the WDL command on that output, not a paper or stale README.

### 7.4 Runtime dependency packaging

Repeated `ModuleNotFoundError` from clean execution directories can indicate an image/package-path contract problem. Prefer installing the project as a package; use `PYTHONPATH` only as an explicit verified fallback. Do not catalog a task that simply forgot `import os` or contains an ordinary code typo.

### 7.5 Conda and unattended execution

If an upstream workflow expects Conda, provide the full contract: channels output, `info --base`, activation, `conda run`, and non-interactive environment creation. Do not assume a renamed micromamba shim is equivalent. For `Confirm changes: [Y/n]`, use the tool's real non-interactive flag; some variables require literal `true`, not `1`.

### 7.6 Temporary paths, tracking, and logs

- For `AF_UNIX path too long`, set `TMPDIR`, `TMP`, and `TEMP` to `/tmp`; reduce multiprocessing workers.
- Disable unnecessary experiment tracking, online sync, and interactive login in inference tasks.
- Use `PYTHONUNBUFFERED=1`, timestamped stage logs, and bounded timeouts.
- Disable or normalize `tqdm` carriage-return output when it creates huge log lines.

### 7.7 Large assets

Verify publisher checksums, file size, archive integrity, minimal model load, and all sidecar/config/index files before building the image. A renamed extension is not a format conversion.

## Repair and verification loop

1. Preserve the exact WDL, inputs, image reference, identifiers, and logs.
2. Assign the failure to one common category, or mark it `project-specific/not cataloged`.
3. Identify the earliest causal execution stage.
4. Run one discriminating confirmation check.
5. Patch the smallest responsible component.
6. Revalidate WDL until the response has `ok=true`.
7. Poll import readiness.
8. Run the production WDL/image with a small structurally valid input.
9. Confirm task exit code, declared outputs, and usable output contents.
10. Record what remains unverified; do not promote a project-specific mistake into this catalog.
