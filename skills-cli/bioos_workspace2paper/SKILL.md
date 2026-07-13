---
name: bioos_workspace2paper
description: Outline and draft a scientific manuscript based on Bio-OS workspace results by combining workspace profile, file listing, and selective file download through the Bio-OS CLI. Trigger when the user says "Write a paper from my results".
---

# Bio-OS Workspace2Paper

Before running the commands below, use `bioos_cli_locator` if the `bioos` command or authentication has not been verified.

## Operating Principle
This skill drafts a manuscript from analysis results already stored in a Bio-OS workspace.

## Execution Workflow

### Stage 1: Prerequisite setup
1. Explicitly declare that `bioos_workspace_parser` skill is required, then use it to obtain a clean overview of the target workspace.
2. Enrich the context with selected workspace files:
   - List files with:
     `bioos file list --workspace-name <workspace_name> --recursive --output json --pretty`
   - Review the hierarchy and shortlist text-based context files such as `__dashboard__.md`, logs, configs, and small CSV or TSV reports
   - Do not target large binary omics files such as `.bam`, `.fastq.gz`, `.vcf.gz`, or `.h5ad`
   - Download the selected files with repeated `--source` flags:
     `bioos file download --workspace-name <workspace_name> --source <path1> --source <path2> --target /local/dir --output json --pretty`
3. Read the downloaded files and use them to sharpen your understanding of the performed analysis.

### Stage 2: Structure and outline generation
1. Propose a manuscript structure such as Abstract, Introduction, Methods, Results, and Discussion.
2. Map workflows into Methods and resulting artifacts into Results.
3. Ask the user to confirm the outline before drafting.

### Stage 3: Iterative content drafting
1. Methods: translate workflow tasks, Docker images, and tools into academic prose.
2. Results: summarize observable outputs only. Do not invent scientific conclusions.
3. Introduction and Discussion: ask the user for the biological narrative and act as their editor, not as a source of invented claims.

### Stage 4: Final manuscript assembly
1. Combine all approved sections.
2. Save the manuscript as `manuscript_draft.md`.
3. Tell the user the drafting pass is complete.
