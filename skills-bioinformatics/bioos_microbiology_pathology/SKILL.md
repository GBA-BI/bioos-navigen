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
disable: true
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
- For WDL `File` inputs, follow the `bioos_platform_operator` skill's file path instructions. `inputs.json` may use `drs://...`, workspace `s3://...`, or an existing local absolute path. Do not convert local user files to DRS just because packaged examples use DRS.
- Expose one workflow per user-facing scientific capability; internal tasks are implementation details.
- Do not expose Nextclade dataset preparation as a user-facing workflow in this skill. SARS-CoV-2 dataset files are prepared upstream and pinned as internal defaults inside the analysis WDL.

## Included Workflows

### 1. `nextclade_sars_cov2_s_protein`
**Path**: `scripts/nextclade_sars_cov2_s_protein.wdl`
**Test Input**: `tests/nextclade_sars_cov2_s_protein.inputs.json`

Run `nextclade run` on SARS-CoV-2 consensus genomes with pinned dataset files and emit the S protein FASTA plus QC, clade, mutation, and tree-oriented outputs.

- Trigger when: the user has a SARS-CoV-2 consensus FASTA and wants S protein sequence output, consensus-sequence QC, mutation summaries, clade assignment, or richer Nextclade reports.
- Do not use when: the input is raw FASTQ or the user only wants a single PANGO lineage label.
- Dataset handling: do not ask the user for Nextclade reference, annotation, tree, or pathogen JSON files. The WDL pins these as internal defaults produced by upstream dataset preparation.

```yaml
name: nextclade_sars_cov2_s_protein
description: Run Nextclade on a SARS-CoV-2 query FASTA using pre-provisioned dataset files and return S protein FASTA plus QC outputs.
required_parameters:
  - query_fasta
internal_defaults:
  - output_prefix
  - include_reference
  - preserve_order
  - docker_image
  - memory_gb
  - disk_space_gb
  - cpu_threads
outputs:
  - spike_protein_fasta
  - aligned_fasta
  - result_jsons
  - result_tables
  - tree_outputs
  - version_file
```

### 2. `nextclade_general_pathogen_analysis`
**Path**: `scripts/nextclade_general_pathogen_analysis.wdl`
**Test Input**: `tests/nextclade_general_pathogen_analysis.inputs.json`

Run `nextclade run` on a user-selected dataset name. This is the flexible entry point for pathogens other than SARS-CoV-2, or for SARS-CoV-2 analyses that need a different Nextclade dataset.

- Trigger when: the user knows which Nextclade dataset to use or asks for a non-SARS-CoV-2 Nextclade run.
- Do not use when: the user simply wants SARS-CoV-2 S protein FASTA; use `nextclade_sars_cov2_s_protein` instead.
- Dataset handling: this workflow downloads the requested dataset at runtime with `nextclade dataset get --name`; use pinned pre-provisioned datasets in a pathogen-specific workflow when strict reproducibility is required.

```yaml
name: nextclade_general_pathogen_analysis
description: Run Nextclade on query genomes using a caller-provided Nextclade dataset name and return QC tables plus all translated CDS FASTA files as a tarball.
required_parameters:
  - query_fasta
  - dataset_name
internal_defaults:
  - output_prefix
  - include_reference
  - preserve_order
  - docker_image
  - memory_gb
  - disk_space_gb
  - cpu_threads
outputs:
  - aligned_fasta
  - result_jsons
  - result_tables
  - translations_tar_gz
  - dataset_files_txt
  - version_file
```

### 3. `pangolin_sars_cov2_lineage_assignment`
**Path**: `scripts/pangolin_sars_cov2_lineage_assignment.wdl`  
**Test Input**: `tests/pangolin_sars_cov2_lineage_assignment.inputs.json`

Assign SARS-CoV-2 PANGO lineages from consensus FASTA.

- Trigger when: the user specifically wants PANGO lineage assignment for assembled SARS-CoV-2 genomes.
- Do not use when: the user wants broader QC and mutation context, or wants future mutation prediction.

```yaml
name: pangolin_sars_cov2_lineage_assignment
description: Run Pangolin on SARS-CoV-2 consensus FASTA input and return lineage assignments plus version metadata.
required_parameters:
  - query_fasta
optional_parameters:
  - output_prefix
  - analysis_mode
  - skip_scorpio
  - max_ambig
  - min_length
  - docker_image
  - memory_gb
  - disk_space_gb
  - cpu_threads
outputs:
  - lineage_report_csv
  - versions_txt
```

## Imported Microbiology And Pathology Atomic Tools
These atomic workflows were imported from the source RO-Crate workspace. Each entry keeps the original RO-Crate metadata, source WDL path, paired exported input JSON, and cataloged runtime image references.

### `checkm`
**Path**: `scripts/checkm.wdl`  
**Test Input**: `tests/checkm.inputs.json`  
**Source Workspace**: `Tool_Checkm` (`Tool_Checkm`)  
**Source WDL**: `workflow/CheckM_Workflow/default/Tool_Checkm.wdl`  
**Source Input**: `submission/CheckM_Workflow-history-2025-09-05-18-10-00/default/input.json`
**Original Metadata**: dataset `td3rq7datjvcf7ennoom0`, author `liuyuanbin`, published `2025-10-21T15:15:55Z`

Tool_Checkm is a WDL-based workflow for running the CheckM genome quality assessment tool. It evaluates input genome files and generates detailed statistics and result reports. CheckM assesses genome quality by analyzing the completeness of single-copy genes.

- Inputs: `thread`, `extension`, `inputfasta`.
- Outputs: `genome_statistics`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/checkm:1.1.3`.

### `dfast`
**Path**: `scripts/dfast.wdl`  
**Test Input**: `tests/dfast.inputs.json`  
**Source Workspace**: `Tool_DFAST` (`Tool_DFAST`)  
**Source WDL**: `workflow/Tool_DFAST02/default/Tool_DFAST02.wdl`  
**Source Input**: `submission/Tool_DFAST02-history-2025-09-05-17-43-17/default/input.json`
**Original Metadata**: dataset `td3rpb1to4spjhk11kr00`, author `liuyuanbin`, published `2025-10-21T14:15:25Z`

DFAST genome functional annotation workspace. It supports functional annotation of input genome FASTA files and includes options such as complete-genome mode, sequence sorting, and isolate tags.

- Inputs: `fasta`, `cpu`, `complete`, `sort_sequence`, `other_para`, `use_tags`.
- Outputs: `dfast.out_dir`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/dfast_core:1.2.6`.

### `fraggenescan`
**Path**: `scripts/fraggenescan.wdl`  
**Test Input**: `tests/fraggenescan.inputs.json`  
**Source Workspace**: `Tool_FragGeneScan` (`Tool_FragGeneScan`)  
**Source WDL**: `workflow/FragGeneScan/default/Tool_FragGeneScan.wdl`  
**Source Input**: `submission/FragGeneScan-history-2025-09-03-16-14-17/default/input.json`
**Original Metadata**: dataset `td3rn5tdo4spjhk11jrb0`, author `liuyuanbin`, published `2025-10-21T11:47:55Z`

The Tool_FragGeneScan workflow performs gene prediction on genomic or metagenomic sequences and wraps FragGeneScan 1.30. It uses FragGeneScan to predict open reading frames (ORFs) and protein-coding genes.

- Inputs: `train_model`, `complete`, `input_fasta`.
- Outputs: `result_files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metatools:lite`.

### `glimmer`
**Path**: `scripts/glimmer.wdl`  
**Test Input**: `tests/glimmer.inputs.json`  
**Source Workspace**: `Tool_Glimmer` (`Tool_Glimmer`)  
**Source WDL**: `workflow/glimmer-gene-prediction/default/Tool_Glimmer_v1.wdl`  
**Source Input**: `submission/glimmer-gene-prediction-history-2025-09-03-11-36-00/default/input.json`
**Original Metadata**: dataset `td3rmgsto4spjhk11jfrg`, author `liuyuanbin`, published `2025-10-21T11:03:05Z`

Workspace for using Glimmer3 to predict genes in genomic sequences.

- Inputs: `args_threads`, `args_gene_len`, `args_max_olap`, `input_fasta`.
- Outputs: `run_files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/glimmer3:latest`.

### `metabat2`
**Path**: `scripts/metabat2.wdl`  
**Test Input**: `tests/metabat2.inputs.json`  
**Source Workspace**: `Tool_MetaBAT2` (`Tool_MetaBAT2`)  
**Source WDL**: `workflow/MetaBAT2/default/Tool_MetaBAT2.wdl`  
**Source Input**: `submission/MetaBAT2-history-2025-09-17-17-48-33/default/input.json`
**Original Metadata**: dataset `td3rl07do4spjhk11ip5g`, author `liuyuanbin`, published `2025-10-21T09:19:15Z`

The MetaBAT2 workflow bins contigs from a reference genome using depth information from sequencing alignments and generates candidate draft genomes.

- Inputs: `input_genome_fa`, `input_dir`.
- Outputs: `metabat2.bins`, `metabat2.depth`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metabat2:2.15--c1941c7`.

### `minced`
**Path**: `scripts/minced.wdl`  
**Test Input**: `tests/minced.inputs.json`  
**Source Workspace**: `Tool_minced` (`Tool_minced`)  
**Source WDL**: `workflow/minced_workflow/default/Tool_minced.wdl`  
**Source Input**: `submission/minced_workflow-history-2025-09-03-15-32-03/default/input.json`
**Original Metadata**: dataset `td3rmolitjvcf7ennnnrg`, author `liuyuanbin`, published `2025-10-21T11:19:40Z`

The MinCED workflow identifies CRISPR arrays in genomic sequences and outputs text and GFF annotation results. It supports common threshold parameter settings.

- Inputs: `minRL`, `genome`, `maxRL`, `maxSL`, `minNR`, `minSL`.
- Outputs: `result_gff`, `result_txt`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/minced:latest`.

### `orthoani`
**Path**: `scripts/orthoani.wdl`  
**Test Input**: `tests/orthoani.inputs.json`  
**Source Workspace**: `Tool_OrthoANI` (`Tool_OrthoANI`)  
**Source WDL**: `workflow/orthoani_workflow/default/Tool_OrthoANI_copy.wdl`  
**Source Input**: `submission/orthoani_workflow-history-2025-09-04-11-26-30/default/input.json`
**Original Metadata**: dataset `td3rp1fitjvcf7ennoa00`, author `liuyuanbin`, published `2025-10-21T13:55:00Z`

This workspace contains the OrthoANI tool for calculating average nucleotide identity (ANI) and digital DNA-DNA hybridization (GGDC) metrics between two genome sequences, then generating a comprehensive report.

- Inputs: `threads`, `fasta1`, `fasta2`.
- Outputs: `report_txt`, `ggdc_txt`, `ani_txt`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/orthoani:latest`.

### `piler_cr`
**Path**: `scripts/piler_cr.wdl`  
**Test Input**: `tests/piler_cr.inputs.json`  
**Source Workspace**: `Tool_PILER_CR` (`Tool_PILER_CR`)  
**Source WDL**: `workflow/Tool_PILER_CR_Workflow/default/Tool_PILER_CR_v1.0update.wdl`  
**Source Input**: `submission/Tool_PILER_CR_Workflow-history-2025-09-03-22-07-42/default/input.json`
**Original Metadata**: dataset `td3rnffitjvcf7ennnvug`, author `liuyuanbin`, published `2025-10-21T12:08:20Z`

PILER-CR (PILER for Clustered Regularly Interspaced Short Palindromic Repeats) is a tool for identifying CRISPR repeats in bacterial and archaeal genomes. This workflow uses the PILER-CR algorithm to analyze input FASTA sequence files and output CRISPR repeat information.

- Inputs: `fasta`.
- Outputs: `pilercr_result`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metatools:lite`.

### `prodigal`
**Path**: `scripts/prodigal.wdl`  
**Test Input**: `tests/prodigal.inputs.json`  
**Source Workspace**: `Tool_Prodigal` (`Tool_Prodigal`)  
**Source WDL**: `workflow/prodigal_workflow/default/Tool_prodigal.wdl`  
**Source Input**: `submission/prodigal_workflow-history-2025-09-03-16-22-23/default/input.json`
**Original Metadata**: dataset `td3rnad5o4spjhk11ju4g`, author `liuyuanbin`, published `2025-10-21T11:57:30Z`

Prodigal-based prokaryotic gene prediction workspace that provides fast and accurate bacterial and archaeal gene prediction.

- Inputs: `inputFile`.
- Outputs: `fnaFile`, `faaFile`, `gffFile`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metatools:lite`.

### `prokka`
**Path**: `scripts/prokka.wdl`  
**Test Input**: `tests/prokka.inputs.json`  
**Source Workspace**: `Tool_Prokka` (`Tool_Prokka`)  
**Source WDL**: `workflow/ProkkaAnnotation/default/Tool_Prokka.wdl`  
**Source Input**: `submission/ProkkaAnnotation-history-2025-09-03-16-19-00/default/input.json`
**Original Metadata**: dataset `td3rn7glo4spjhk11jsbg`, author `liuyuanbin`, published `2025-10-21T11:51:20Z`

Prokka is a fast tool for prokaryotic genome annotation. It also supports viral genome annotation and generates annotation files in multiple standard formats.

- Inputs: `prefix`, `input_fasta`, `kingdom`.
- Outputs: `prokka_annotation.out`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/prokka:latest`.

### `raymeta`
**Path**: `scripts/raymeta.wdl`  
**Test Input**: `tests/raymeta.inputs.json`  
**Source Workspace**: `Tool_RayMeta` (`Tool_RayMeta`)  
**Source WDL**: `workflow/Tool_RayMeta-copy/default/Tool_RayMeta.wdl`  
**Source Input**: `submission/Tool_RayMeta-copy-history-2025-11-20-12-43-41/default/input.json`
**Original Metadata**: dataset `td4fa554illb3o00gtrj0`, author `liuyuanbin`, published `2025-11-20T05:09:10Z`

Uses Ray to perform parallel assembly of paired-end sequencing data (FASTQ R1/R2) and produce Ray's standard output directory. The workflow runs Ray with OpenMPI using the requested number of cores and outputs the full file collection containing the assembly results.

- Inputs: `fq2`, `kmer`, `fq1`, `cpu`.
- Outputs: `ray_outputs`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/assembletool:latest`.

### `rgi`
**Path**: `scripts/rgi.wdl`  
**Test Input**: `tests/rgi.inputs.json`  
**Source Workspace**: `RGI_Workspace` (`RGI_Workspace`)  
**Source WDL**: `workflow/RGIWorkflow/default/rgi_workflow.wdl`  
**Source Input**: `submission/RGIWorkflow-history-2025-08-29-08-57-07/default/input.json`
**Original Metadata**: dataset `td3rip6to4spjhk11hr1g`, author `liuyuanbin`, published `2025-10-21T06:47:45Z`

The RGI (Resistance Gene Identifier) workflow identifies and analyzes antibiotic resistance genes. It uses the CARD database and the DIAMOND algorithm for protein sequence alignment to identify potential antibiotic resistance genes.

- Inputs: `faa`, `sampleName`.
- Outputs: `rgi_result`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/rgi:6.0.3`.

### `rnammer`
**Path**: `scripts/rnammer.wdl`  
**Test Input**: `tests/rnammer.inputs.json`  
**Source Workspace**: `Tools_RNAmmer` (`Tools_RNAmmer`)  
**Source WDL**: `workflow/Tools_RNAmmer/default/Tools_RNAmmer.wdl`  
**Source Input**: `submission/Tools_RNAmmer-history-2025-08-28-21-53-32/default/input.json`
**Original Metadata**: dataset `td3risc2tjvcf7ennmpt0`, author `liuyuanbin`, published `2025-10-21T06:54:30Z`

RNAmmer predicts rRNA genes in genomic sequences and outputs rRNA sequences, annotations, and report files. This workflow wraps the RNAmmer command line with standardized inputs and outputs for WDL/Cromwell execution and integration.

- Inputs: `genome`, `species`, `m`.
- Outputs: `rRNA_xml`, `rRNA_fasta`, `rRNA_gff2`, `rRNA_hmmreport`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/rnammer:v1.2`.

### `trnascan`
**Path**: `scripts/trnascan.wdl`  
**Test Input**: `tests/trnascan.inputs.json`  
**Source Workspace**: `Tool_tRNAscan` (`Tool_tRNAscan`)  
**Source WDL**: `workflow/Tool_tRNAscanSEV1/default/Tool_tRNAscanSEV1.wdl`  
**Source Input**: `submission/Tool_tRNAscanSEV1-history-2025-08-28-22-41-40/default/input.json`
**Original Metadata**: dataset `td3rir0atjvcf7ennmpk0`, author `liuyuanbin`, published `2025-10-21T06:51:35Z`

tRNAscan-SE tool workflow for tRNA gene prediction.

- Inputs: `genome`, `other_para`.
- Outputs: `tRNA_out`, `tRNA_stats`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/trnascan_se:latest`.

## Execution Handoff
- If the user wants SARS-CoV-2 S protein extraction, start from `tests/nextclade_sars_cov2_s_protein.inputs.json` and replace only `query_fasta` according to the `bioos_platform_operator` skill's file path instructions.
- If the user wants a general Nextclade run for another pathogen, start from `tests/nextclade_general_pathogen_analysis.inputs.json` and replace `query_fasta` plus `dataset_name`.
- If the user wants Pangolin lineage assignment, start from `tests/pangolin_sars_cov2_lineage_assignment.inputs.json` and replace the packaged FASTA with the current consensus genome.
- If the request is about mutation forecasting, alerting, immune modeling, or antibody-model workflows, switch to `bioos_early_warning` instead of extending this skill.
