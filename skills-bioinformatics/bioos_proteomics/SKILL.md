---
name: bioos_proteomics
description: Route protein-centric Bio-OS workflows. Use this skill for protein
  sequence alignment and other proteomics-adjacent workflows that should run as
  Bio-OS WDLs.
disable: true
---

# Bio-OS Proteomics

## Scope
This is the business-layer skill for protein-focused workflows, currently centered on imported protein sequence alignment tools.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use the workflow description below as the routing entry rather than exposing internal tasks directly.
- For WDL `File` inputs, follow the `bioos_platform_operator` skill's file path instructions.

## Included Workflows

## Imported Proteomics Atomic Tools
These atomic workflows were imported from the source RO-Crate workspace. Each entry keeps the original RO-Crate metadata, source WDL path, paired exported input JSON, and cataloged runtime image references.

### `diamond`
**Path**: `scripts/diamond.wdl`  
**Test Input**: `tests/diamond.inputs.json`  
**Source Workspace**: `Tool_DIAMOND` (`Tool_DIAMOND`)  
**Source WDL**: `workflow/diamond/default/Tool_DIAMOND.wdl`  
**Source Input**: `submission/diamond-history-2025-09-05-16-05-50/default/input.json`
**Original Metadata**: dataset `td3vhbfliveb89860rv1g`, author `liuyuanbin`, published `2025-10-27T06:48:10Z`

Uses DIAMOND to align query sequences against a protein database.

- Inputs: `evalue`, `prefix`, `args_threads`, `args_outfmt`, `query_fasta`, `db_fasta`, `args_cand`.
- Outputs: `diamond.diamond_result`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/diamond:latest`.

## Execution Handoff
- Use this skill for protein sequence alignment, not for variant calling, RNA processing, or pathogen surveillance workflows.
