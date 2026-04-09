---
name: bioos_data_fetcher
description: Download biological datasets (SRA for SRR/ERR/DRR IDs, GEO for GSE IDs) into a Bio-OS workspace with bundled WDL workflows and the Bio-OS CLI. Use this skill when an analysis needs external data staged into Bio-OS instead of downloading locally.
---

# Bio-OS Data Fetcher

Resolve the Bio-OS CLI launcher first and refer to it as `<bioos_launch>`. If it is not known yet, explicitly load the `bioos_cli_locator` skill before running the commands below.

## Operating Principle
This skill fetches biological datasets from external databases and deposits them into a Bio-OS workspace by running predefined WDL workflows on the Bio-OS platform.

CRITICAL: all real downloading must happen on Bio-OS through the bundled WDL workflows. Do not use local `wget`, `curl`, `prefetch`, `fasterq-dump`, or similar commands to download the analysis payload onto the agent machine.

## Supported Data Sources
- `SRA`: accessions starting with `SRR`, `ERR`, or `DRR`
- `GEO`: accessions starting with `GSE`

If the request targets anything else, explicitly say this skill does not support it and switch to another strategy or ask the user for clarification.

## Bundled WDL Scripts
- `scripts/download_sra.wdl`
- `scripts/download_gse_data.wdl`

## Execution Workflow

### 1. Identify the data source and WDL path
- `SRA` data: use `scripts/download_sra.wdl`
- `GEO` data: use `scripts/download_gse_data.wdl`

### 2. Hand off platform execution
This skill does not prepare `inputs.json`, import workflows, or submit runs by itself.

Instead, do all of the following:
- State the resolved local WDL path.
- State the exact accession IDs that must be passed into the workflow.
- Explicitly declare that the `bioos_platform_operator` skill is required to finish the run with Bio-OS CLI workflow commands.

If multiple IDs must be processed independently, tell the operator to use a batch `inputs.json` array of objects.
