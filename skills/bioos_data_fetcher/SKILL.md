---
name: bioos_data_fetcher
description: Download biological datasets (SRA for SRR IDs, GEO for GSE IDs) directly to the Bio-OS cloud platform using bundled WDL workflows. Use this skill when an analysis requires downloading data from external databases into a Bio-OS workspace.
---

# Bio-OS Data Fetcher

## 1. Operating Principle
This procedure outlines how to fetch biological datasets from external databases (SRA, GEO) and deposit them directly into a Bio-OS workspace by executing predefined WDL workflows. 

**CRITICAL RULE**: ALL downloading must happen on the Bio-OS cloud platform via WDL tasks. Do not attempt to use local bash commands (like `wget` or `fasterq-dump`) on the local agent machine.

## Supported Data Sources
This skill currently ONLY supports:
1.  **SRA** (Accessions starting with SRR, ERR, DRR)
2.  **GEO** (Accessions starting with GSE)

If the requested data source is not one of the above, you MUST explicitly state that this skill cannot handle it and proceed to alternative strategies within your current context or ask the user for clarification.

## Bundled WDL Scripts
You have access to predefined, validated WDL scripts in your `scripts/` directory:
-   `scripts/download_sra.wdl` (For SRA data)
-   `scripts/download_gse_data.wdl` (For GEO data)

## Execution Workflow

When invoked to download data, follow these steps strictly:

### 3. Identify Data Source and WDL Path
*   **SRA** data: Use `scripts/download_sra.wdl`.
*   **GEO** data: Use `scripts/download_gse_data.wdl`.

### 4. Execution Requirement
You do NOT generate `inputs.json`, `import_workflow`, or `submit_workflow` independently. 
Instead, state in the conversation that you have identified the target WDL path and the required accession IDs. 

Then, explicitly state that the **`bioos_platform_operator`** skill is required to configure the `inputs.json` (via batch array) and execute the deployment. This explicit statement ensures the execution instructions are correctly loaded into the context window.
