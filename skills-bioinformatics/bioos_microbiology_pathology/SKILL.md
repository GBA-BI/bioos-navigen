---
name: bioos_microbiology_pathology
description: Route microbiology, pathogen genomics, metagenomics, microbial
  genome annotation, AMR/CRISPR analysis, genome relatedness, and
  pathology-adjacent Bio-OS workflows. Use this skill for SARS-CoV-2 S protein
  extraction with pre-provisioned Nextclade datasets, general Nextclade pathogen
  analysis by dataset name, viral lineage labeling, microbial gene prediction,
  Prokka/DFAST annotation, RGI resistance detection, RNAmmer/tRNAscan,
  OrthoANI/Mash comparison, and metagenome assembly or binning workflows that
  should run with Bio-OS WDLs.
disable: false
---

# Bio-OS Microbiology And Pathology

## Scope
This is the business-layer skill for routine pathogen and microbiology workflows that operate on observed sequences or metagenomic reads.

- Use this skill for Nextclade SARS-CoV-2 S protein extraction, general Nextclade pathogen analysis by dataset name, Pangolin lineage assignment, microbial genome annotation, AMR/CRISPR analysis, genome relatedness, and metagenome assembly/binning/QC.
- If the user asks for forecasting, alerting, immune-trajectory modeling, or external GitHub-derived prevention drills, route to the `bioos_early_warning` skill instead.
- If a new workflow must be authored, hand off to the `bioos_pipeline_developer` skill.
- If a runtime image needs to be rebuilt, hand off to the `bioos_docker_builder` skill.
- Before changing any image reference, consult the `bioos_docker_registry_catalog` skill.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use workflow names below as the user-facing routing units; internal task names are implementation details.
- For WDL `File` inputs, use the `bioos_platform_operator` skill and follow its file-input instructions.
- Do not expose Nextclade dataset preparation as a user-facing workflow in this skill. SARS-CoV-2 dataset files are prepared upstream and pinned as internal defaults inside the analysis WDL.

## Included Workflows

### `nextclade_sars_cov2_s_protein`
**Path**: `scripts/nextclade_sars_cov2_s_protein.wdl`
**Test Input**: `tests/nextclade_sars_cov2_s_protein.inputs.json`

Run `nextclade run` on SARS-CoV-2 consensus genomes with pinned dataset files and emit the S protein FASTA plus QC, clade, mutation, and tree-oriented outputs. Dataset files are pinned as internal defaults, so do not ask the user for Nextclade reference, annotation, tree, or pathogen JSON files.

- Trigger when: the user has a SARS-CoV-2 consensus FASTA and wants S protein sequence output, consensus-sequence QC, mutation summaries, clade assignment, or richer Nextclade reports.
- Required parameters: `query_fasta`.
- Optional parameters: internal defaults include `output_prefix`, `include_reference`, `preserve_order`, `docker_image`, `memory_gb`, `disk_space_gb`, and `cpu_threads`.
- Outputs: `spike_protein_fasta`, `aligned_fasta`, `result_jsons`, `result_tables`, `tree_outputs`, and `version_file`.

### `nextclade_general_pathogen_analysis`
**Path**: `scripts/nextclade_general_pathogen_analysis.wdl`
**Test Input**: `tests/nextclade_general_pathogen_analysis.inputs.json`

Run `nextclade run` on a user-selected dataset name. This is the flexible entry point for pathogens other than SARS-CoV-2, or for SARS-CoV-2 analyses that need a different Nextclade dataset. The workflow downloads the requested dataset at runtime with `nextclade dataset get --name`.

- Trigger when: the user knows which Nextclade dataset to use or asks for a non-SARS-CoV-2 Nextclade run.
- Required parameters: `query_fasta`, `dataset_name`.
- Optional parameters: internal defaults include `output_prefix`, `include_reference`, `preserve_order`, `docker_image`, `memory_gb`, `disk_space_gb`, and `cpu_threads`.
- Outputs: `aligned_fasta`, `result_jsons`, `result_tables`, `translations_tar_gz`, `dataset_files_txt`, and `version_file`.

### `pangolin_sars_cov2_lineage_assignment`
**Path**: `scripts/pangolin_sars_cov2_lineage_assignment.wdl`
**Test Input**: `tests/pangolin_sars_cov2_lineage_assignment.inputs.json`

Assign SARS-CoV-2 PANGO lineages from consensus FASTA.

- Trigger when: the user specifically wants PANGO lineage assignment for assembled SARS-CoV-2 genomes.
- Required parameters: `query_fasta`.
- Optional parameters: `output_prefix`, `analysis_mode`, `skip_scorpio`, `max_ambig`, `min_length`, `docker_image`, `memory_gb`, `disk_space_gb`, `cpu_threads`.
- Outputs: `lineage_report_csv` and `versions_txt`.

### `checkm`
**Path**: `scripts/checkm.wdl`
**Test Input**: `tests/checkm.inputs.json`

Tool_Checkm is a WDL-based workflow for running the CheckM genome quality assessment tool. It evaluates input genome files and generates detailed statistics and result reports. CheckM assesses genome quality by analyzing the completeness of single-copy genes.

- Trigger when: the user asks for `checkm` or the described workflow capability.
- Required parameters: `thread`, `extension`, `inputfasta`.
- Optional parameters: none documented.
- Outputs: `genome_statistics`.

### `dfast`
**Path**: `scripts/dfast.wdl`
**Test Input**: `tests/dfast.inputs.json`

DFAST genome functional annotation workspace. It supports functional annotation of input genome FASTA files and includes options such as complete-genome mode, sequence sorting, and isolate tags.

- Trigger when: the user asks for `dfast` or the described workflow capability.
- Required parameters: `fasta`, `cpu`, `complete`, `sort_sequence`, `other_para`, `use_tags`.
- Optional parameters: none documented.
- Outputs: `dfast.out_dir`.

### `fraggenescan`
**Path**: `scripts/fraggenescan.wdl`
**Test Input**: `tests/fraggenescan.inputs.json`

The Tool_FragGeneScan workflow performs gene prediction on genomic or metagenomic sequences and wraps FragGeneScan 1.30. It uses FragGeneScan to predict open reading frames (ORFs) and protein-coding genes.

- Trigger when: the user asks for `fraggenescan` or the described workflow capability.
- Required parameters: `train_model`, `complete`, `input_fasta`.
- Optional parameters: none documented.
- Outputs: `result_files`.

### `glimmer`
**Path**: `scripts/glimmer.wdl`
**Test Input**: `tests/glimmer.inputs.json`

Workspace for using Glimmer3 to predict genes in genomic sequences.

- Trigger when: the user asks for `glimmer` or the described workflow capability.
- Required parameters: `args_threads`, `args_gene_len`, `args_max_olap`, `input_fasta`.
- Optional parameters: none documented.
- Outputs: `run_files`.

### `metabat2`
**Path**: `scripts/metabat2.wdl`
**Test Input**: `tests/metabat2.inputs.json`

The MetaBAT2 workflow bins contigs from a reference genome using depth information from sequencing alignments and generates candidate draft genomes.

- Trigger when: the user asks for `metabat2` or the described workflow capability.
- Required parameters: `input_genome_fa`, `input_dir`.
- Optional parameters: none documented.
- Outputs: `metabat2.bins`, `metabat2.depth`.

### `minced`
**Path**: `scripts/minced.wdl`
**Test Input**: `tests/minced.inputs.json`

The MinCED workflow identifies CRISPR arrays in genomic sequences and outputs text and GFF annotation results. It supports common threshold parameter settings.

- Trigger when: the user asks for `minced` or the described workflow capability.
- Required parameters: `minRL`, `genome`, `maxRL`, `maxSL`, `minNR`, `minSL`.
- Optional parameters: none documented.
- Outputs: `result_gff`, `result_txt`.

### `orthoani`
**Path**: `scripts/orthoani.wdl`
**Test Input**: `tests/orthoani.inputs.json`

This workspace contains the OrthoANI tool for calculating average nucleotide identity (ANI) and digital DNA-DNA hybridization (GGDC) metrics between two genome sequences, then generating a comprehensive report.

- Trigger when: the user asks for `orthoani` or the described workflow capability.
- Required parameters: `threads`, `fasta1`, `fasta2`.
- Optional parameters: none documented.
- Outputs: `report_txt`, `ggdc_txt`, `ani_txt`.

### `piler_cr`
**Path**: `scripts/piler_cr.wdl`
**Test Input**: `tests/piler_cr.inputs.json`

PILER-CR (PILER for Clustered Regularly Interspaced Short Palindromic Repeats) is a tool for identifying CRISPR repeats in bacterial and archaeal genomes. This workflow uses the PILER-CR algorithm to analyze input FASTA sequence files and output CRISPR repeat information.

- Trigger when: the user asks for `piler_cr` or the described workflow capability.
- Required parameters: `fasta`.
- Optional parameters: none documented.
- Outputs: `pilercr_result`.

### `prodigal`
**Path**: `scripts/prodigal.wdl`
**Test Input**: `tests/prodigal.inputs.json`

Prodigal-based prokaryotic gene prediction workspace that provides fast and accurate bacterial and archaeal gene prediction.

- Trigger when: the user asks for `prodigal` or the described workflow capability.
- Required parameters: `inputFile`.
- Optional parameters: none documented.
- Outputs: `fnaFile`, `faaFile`, `gffFile`.

### `prokka`
**Path**: `scripts/prokka.wdl`
**Test Input**: `tests/prokka.inputs.json`

Prokka is a fast tool for prokaryotic genome annotation. It also supports viral genome annotation and generates annotation files in multiple standard formats.

- Trigger when: the user asks for `prokka` or the described workflow capability.
- Required parameters: `prefix`, `input_fasta`, `kingdom`.
- Optional parameters: none documented.
- Outputs: `prokka_annotation.out`.

### `raymeta`
**Path**: `scripts/raymeta.wdl`
**Test Input**: `tests/raymeta.inputs.json`

Uses Ray to perform parallel assembly of paired-end sequencing data (FASTQ R1/R2) and produce Ray's standard output directory. The workflow runs Ray with OpenMPI using the requested number of cores and outputs the full file collection containing the assembly results.

- Trigger when: the user asks for `raymeta` or the described workflow capability.
- Required parameters: `fq2`, `kmer`, `fq1`, `cpu`.
- Optional parameters: none documented.
- Outputs: `ray_outputs`.

### `rgi`
**Path**: `scripts/rgi.wdl`
**Test Input**: `tests/rgi.inputs.json`

The RGI (Resistance Gene Identifier) workflow identifies and analyzes antibiotic resistance genes. It uses the CARD database and the DIAMOND algorithm for protein sequence alignment to identify potential antibiotic resistance genes.

- Trigger when: the user asks for `rgi` or the described workflow capability.
- Required parameters: `faa`, `sampleName`.
- Optional parameters: none documented.
- Outputs: `rgi_result`.

### `rnammer`
**Path**: `scripts/rnammer.wdl`
**Test Input**: `tests/rnammer.inputs.json`

RNAmmer predicts rRNA genes in genomic sequences and outputs rRNA sequences, annotations, and report files. This workflow wraps the RNAmmer command line with standardized inputs and outputs for WDL/Cromwell execution and integration.

- Trigger when: the user asks for `rnammer` or the described workflow capability.
- Required parameters: `genome`, `species`, `m`.
- Optional parameters: none documented.
- Outputs: `rRNA_xml`, `rRNA_fasta`, `rRNA_gff2`, `rRNA_hmmreport`.

### `trnascan`
**Path**: `scripts/trnascan.wdl`
**Test Input**: `tests/trnascan.inputs.json`

tRNAscan-SE tool workflow for tRNA gene prediction.

- Trigger when: the user asks for `trnascan` or the described workflow capability.
- Required parameters: `genome`, `other_para`.
- Optional parameters: none documented.
- Outputs: `tRNA_out`, `tRNA_stats`.

## Execution Handoff
- Start from the matching `tests/*.inputs.json` template and use the `bioos_platform_operator` skill for file inputs and workflow submission.
- If the user wants SARS-CoV-2 S protein extraction, start from `tests/nextclade_sars_cov2_s_protein.inputs.json` and use the `bioos_platform_operator` skill to replace only `query_fasta` before submission.
- If the user wants a general Nextclade run for another pathogen, start from `tests/nextclade_general_pathogen_analysis.inputs.json` and replace `query_fasta` plus `dataset_name`.
- If the user wants Pangolin lineage assignment, start from `tests/pangolin_sars_cov2_lineage_assignment.inputs.json` and replace the packaged FASTA with the current consensus genome.
- If the request is about mutation forecasting, alerting, immune modeling, or antibody-model workflows, switch to `bioos_early_warning` instead of extending this skill.
