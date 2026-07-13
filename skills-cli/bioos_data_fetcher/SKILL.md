---
name: bioos_data_fetcher
description: Download biological datasets (SRA for SRR/ERR/DRR IDs, GEO for GSE IDs, or public HTTP/HTTPS URLs) into a Bio-OS workspace with bundled WDL workflows and the Bio-OS CLI. Use this skill when an analysis needs external data staged into Bio-OS instead of downloading locally.
---

# Bio-OS Data Fetcher

Before running Bio-OS CLI commands, use `bioos_cli_locator` if the `bioos` command or authentication has not been verified.

## Operating Principle
This skill fetches biological datasets from external databases and deposits them into a Bio-OS workspace by running predefined WDL workflows on the Bio-OS platform.

CRITICAL: all real downloading must happen on Bio-OS through the bundled WDL workflows. Do not use local `wget`, `curl`, `prefetch`, `fasterq-dump`, or similar commands to download the analysis payload onto the agent machine.

## Supported Data Sources
- `SRA`: accessions starting with `SRR`, `ERR`, or `DRR`
- `GEO`: accessions starting with `GSE`
- `HTTP/HTTPS`: one or more public URLs, optionally described by a TSV manifest

If the request targets anything else, explicitly say this skill does not support it and switch to another strategy or ask the user for clarification.

## Bundled WDL Scripts
- `scripts/download_sra.wdl`
- `scripts/download_gse_data.wdl`
- `scripts/download_http_files.wdl`

## HTTP/HTTPS Input Contract

Use either or both inputs:

- `DownloadHTTPFiles.urls`: public URLs whose output names can be inferred from their paths.
- `DownloadHTTPFiles.manifest`: an optional TSV with `url`, `file_name`, and `sha256` columns. Use `-` when the checksum is unknown.

The manifest must use a unique, simple `file_name` for every row. Example:

```tsv
url	file_name	sha256
https://example.org/data/matrix.h5ad	matrix.h5ad	-
```

## Execution Workflow

### 1. Identify the data source and WDL path
- `SRA` data: use `scripts/download_sra.wdl`
- `GEO` data: use `scripts/download_gse_data.wdl`
- Public HTTP/HTTPS data: use `scripts/download_http_files.wdl`

### 2. Hand off platform execution
This skill does not prepare `inputs.json`, import workflows, or submit runs by itself.

Instead, do all of the following:
- State the resolved local WDL path.
- State the exact accession IDs, URLs, or manifest that must be passed into the workflow.
- Explicitly declare that the `bioos_platform_operator` skill is required to finish the run with Bio-OS CLI workflow commands.

If multiple IDs must be processed independently, tell the operator to use a batch `inputs.json` array of objects.
