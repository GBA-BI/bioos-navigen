---
name: bioos_proteomics
description: Route protein-centric Bio-OS workflows. Use this skill for protein
  sequence alignment and other proteomics-adjacent workflows that should run as
  Bio-OS WDLs.
disable: false
---

# Bio-OS Proteomics

## Scope
This is the business-layer skill for protein-focused workflows, currently centered on protein sequence alignment workflows.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use workflow names below as the user-facing routing units; internal task names are implementation details.
- For WDL `File` inputs, use the `bioos_platform_operator` skill and follow its file-input instructions.

## Included Workflows

### `diamond`
**Path**: `scripts/diamond.wdl`
**Test Input**: `tests/diamond.inputs.json`

Uses DIAMOND to align query sequences against a protein database.

- Trigger when: the user asks for `diamond` or the described workflow capability.
- Required parameters: `evalue`, `prefix`, `args_threads`, `args_outfmt`, `query_fasta`, `db_fasta`, `args_cand`.
- Optional parameters: none documented.
- Outputs: `diamond.diamond_result`.

## Execution Handoff
- Start from the matching `tests/*.inputs.json` template and use the `bioos_platform_operator` skill for file inputs and workflow submission.
- Use this skill for protein sequence alignment, not for variant calling, RNA processing, or pathogen surveillance workflows.
