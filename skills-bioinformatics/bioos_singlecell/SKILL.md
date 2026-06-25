---
name: bioos_singlecell
description: Route single-cell Bio-OS workflows. Use this skill for 10x
  Genomics Cell Ranger scRNA-seq counting, 10x Cell Ranger V(D)J processing,
  TCR repertoire summary and visualization, SeekSoulTools RNA/FAST expression
  workflows, and SeekSoulTools VDJ workflows that should run with Bio-OS WDLs.
disable: false
---

# Bio-OS Single Cell

## Scope
This is the business-layer skill for single-cell sequencing workflows.

- Use this skill when the user has single-cell FASTQ data, 10x Genomics scRNA-seq data, 10x V(D)J FASTQs, Cell Ranger VDJ outputs, SeekOne/SeekSoulTools single-cell RNA data, or SeekSoulTools VDJ data.
- Use this skill for single-cell gene-expression matrix generation, immune-receptor VDJ assembly, TCR/BCR repertoire output collection, and TCR visualization from Cell Ranger VDJ tables.
- Do not use this skill for ordinary bulk RNA-seq quantification or differential expression; route those requests to `bioos_transcriptomics`.
- Do not use this skill for general genome assembly, sequence alignment, or structural variant detection; route those requests to `bioos_genomics`.
- If a new workflow must be authored, hand off to the `bioos_pipeline_developer` skill.
- If a runtime image needs to be rebuilt, hand off to the `bioos_docker_builder` skill.
- Before changing any image reference, consult the `bioos_docker_registry_catalog` skill.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use workflow names below as the user-facing routing units; internal task names are implementation details.
- For WDL `File` inputs, use the `bioos_platform_operator` skill and follow its file-input instructions.
- For 10x workflows, ask the user to confirm whether the species/reference choice should be human (`GRCh38`) or mouse before submitting if it is not already explicit.
- For SeekSoulTools VDJ workflows, ask whether the immune receptor chain is `TCR` or `BCR` when the request does not specify it.

## Included Workflows

### `10x_cellranger_scrna`
**Path**: `scripts/10x_cellranger_scrna.wdl`
**Test Input**: `tests/10x_cellranger_scrna.inputs.json`

Run 10x Genomics Cell Ranger `count` on paired FASTQs to align reads, quantify gene expression, and emit single-cell feature-barcode matrices plus QC outputs.

- Trigger when: the user has 10x single-cell RNA-seq FASTQs and wants Cell Ranger gene-expression matrices, web summary, metrics, and alignment outputs.
- Required parameters: `sample_name`, `fastq1`, `fastq2`, `species`.
- Optional parameters: `memory_gb`, `disk_gb`, `cpu`, `CellrangerCount.expect_cells`, `CellrangerCount.nosecondary`, `CellrangerCount.chemistry`.
- Outputs: `output_result`, `web_summary`, `metrics_summary`, `filtered_feature_bc_matrix_h5`, `filtered_feature_bc_matrix_mex`, `raw_feature_bc_matrix_h5`, `raw_feature_bc_matrix_mex`, `output_bam`, and `output_bam_index`.

### `10x_cellranger_vdj`
**Path**: `scripts/10x_cellranger_vdj.wdl`
**Test Input**: `tests/10x_cellranger_vdj.inputs.json`

Run 10x Genomics Cell Ranger `vdj` on paired immune-repertoire FASTQs to assemble V(D)J contigs, call clonotypes, and generate AIRR-style annotations.

- Trigger when: the user has 10x VDJ, TCR, or BCR FASTQs and wants Cell Ranger VDJ assembly, clonotype tables, contig FASTAs, annotations, or web-summary QC.
- Required parameters: `sample_name`, `fastq1`, `fastq2`, `species`.
- Optional parameters: `memory_gb`, `disk_gb`, `cpu`, `CellrangerVDJ.nosecondary`, `CellrangerVDJ.chemistry`.
- Outputs: `output_result`, `web_summary`, `clonotypes_csv`, `consensus_fasta`, `all_contig_fasta`, `all_contig_annotations_csv`, `filtered_contig_annotations_csv`, `consensus_annotations_csv`, `metrics_summary_csv`, `airr_rearrangement_tsv`, `filtered_contig_fasta`, and `all_contig_annotation_bed`.

### `10x_tcr_single_sample_analysis`
**Path**: `scripts/10x_tcr_single_sample_analysis.wdl`
**Test Input**: `tests/10x_tcr_single_sample_analysis.inputs.json`

Analyze Cell Ranger VDJ TCR outputs for one sample and generate repertoire tables plus visualization files for V gene usage, V-J pairing, CDR3 length, clonotype expansion, and related TCR summaries.

- Trigger when: the user already has Cell Ranger VDJ `filtered_contig_annotations.csv` plus `clonotypes.csv` and wants single-sample TCR repertoire figures and summary tables.
- Required parameters: `contig_annotation_csv`, `clonotypes_csv`, `sample_name`.
- Optional parameters: `output_dir`.
- Outputs: `contig_filtered`, `clonotypes_annotated`, `diversity_metrics`, `imm_tra`, `imm_trb`, `fig1_png` through `fig13c_png`, matching PDF figure outputs, optional `fig8` network outputs, `results_tarball`, `manifest`, and `checksum`.

### `seeksoultools_rna`
**Path**: `scripts/seeksoultools_rna.wdl`
**Test Input**: `tests/seeksoultools_rna.inputs.json`

Run the SeekSoulTools RNA module for SeekOne-style single-cell transcriptome reads, including barcode handling, alignment, quantification, and expression-matrix generation.

- Trigger when: the user has SeekOne or SeekSoulTools-compatible single-cell RNA FASTQs and wants the RNA module output matrices, report, summaries, and step archives.
- Required parameters: `fq1`, `fq2`, `samplename`, `genome_tar`, `genome_name`.
- Optional parameters: `chemistry`, `include_introns`, `core`, `memory_gb`, `disk_gb`.
- Outputs: `result_tar`, `summary_json`, `summary_csv`, `report_html`, `step1_file`, `step2_file`, `step3_file`, `step4_file`, `raw_feature_bc_matrix`, `filtered_feature_bc_matrix`, `stdout_log`, and `stderr_log`.

### `seeksoultools_fast`
**Path**: `scripts/seeksoultools_fast.wdl`
**Test Input**: `tests/seeksoultools_fast.inputs.json`

Run the SeekSoulTools FAST module for SeekOne DD or DD FFPE full-length single-cell transcriptome reads, producing expression matrices, summaries, reports, and staged result archives.

- Trigger when: the user has SeekOne DD/FAST-mode single-cell transcriptome FASTQs and wants the SeekSoulTools FAST module outputs.
- Required parameters: `fq1`, `fq2`, `samplename`, `genome_tar`, `genome_name`.
- Optional parameters: `chemistry`, `include_introns`, `core`, `memory_gb`, `disk_gb`.
- Outputs: `result_tar`, `summary_json`, `summary_csv`, `report_html`, `step1_file`, `step2_file`, `step3_file`, `step4_file`, `raw_feature_bc_matrix`, `filtered_feature_bc_matrix`, `stdout_log`, and `stderr_log`.

### `seeksoultools_vdj`
**Path**: `scripts/seeksoultools_vdj.wdl`
**Test Input**: `tests/seeksoultools_vdj.inputs.json`

Run the SeekSoulTools VDJ module for SeekOne immune-repertoire data and export contig, clonotype, AIRR, consensus, report, and packaged run outputs.

- Trigger when: the user has SeekSoulTools-compatible VDJ FASTQs and wants TCR or BCR assembly, filtering, annotation, clonotypes, AIRR output, or a VDJ report.
- Required parameters: `fq1`, `fq2`, `samplename`, `chain`.
- Optional parameters: `chemistry`, `organism`, `core`, `memory_gb`, `disk_gb`.
- Outputs: `result_tar`, `run_tar`, `outs_tar`, `airr_rearrangement_csv`, `all_contig_annotations_csv`, `clontypes_csv`, `metrics_summary_csv`, `consensus_fasta`, `consensus_annotations_csv`, `all_contig_fasta`, `filtered_contig_igblast`, `filtered_contig_annotations_csv`, `report_html`, `stdout_log`, and `stderr_log`.

## Execution Handoff
- Start from the matching `tests/*.inputs.json` template and use the `bioos_platform_operator` skill for file inputs and workflow submission.
- For 10x Cell Ranger scRNA-seq and VDJ workflows, replace the example FASTQ DRS URIs and confirm the species value before launch.
- For TCR analysis workflows, use Cell Ranger VDJ outputs: `filtered_contig_annotations.csv` as `contig_annotation_csv` and `clonotypes.csv` as `clonotypes_csv`.
- For SeekSoulTools RNA/FAST workflows, confirm `genome_tar`, `genome_name`, chemistry, and whether intronic reads should be included.
- For SeekSoulTools VDJ workflows, set `chain` to `TCR` or `BCR` according to the user's experiment.
