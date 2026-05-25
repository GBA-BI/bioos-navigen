---
name: bioos_transcriptomics
description: Route transcriptomics Bio-OS workflows. Use this skill for bulk
  RNA-seq quantification, RNA-seq alignment, transcript assembly, transcript
  quantification, and differential expression workflows that should run with
  Bio-OS WDLs.
disable: true
---

# Bio-OS Transcriptomics

## Scope
This is the business-layer skill for transcriptome-focused workflows.

- Use this skill for expression-oriented RNA pipelines, RNA-seq alignment, transcript assembly, transcript quantification, and differential expression analysis.
- Use this skill for bulk RNA-seq quantification with STAR/RNA-SeQC/RSEM in addition to imported STAR, HISAT2, StringTie, Kallisto, Sailfish, Cufflinks, Cuffdiff, Ballgown, DESeq2, Oases, and Trinity workflows.
- Do not use this skill for variant-centric DNA or RNA calling; those should route to `bioos_genomics`.
- Before changing image references, consult the `bioos_docker_registry_catalog` skill.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Prefer the workflow names below as the routing units exposed to the LLM.
- For WDL `File` inputs, follow the `bioos_platform_operator` skill's file path instructions.
- Start from the packaged test input and swap in the run-specific files according to `bioos_platform_operator`.

## Included Workflows

### 1. `bulk_rnaseq_quantification`
**Path**: `scripts/bulk_rnaseq_quantification.wdl`  
**Test Input**: `tests/bulk_rnaseq_quantification.inputs.json`

GTEx-style bulk RNA-seq quantification from FASTQ input using STAR alignment, RNA-SeQC2 metrics, and RSEM quantification.

- Trigger when: the user has bulk mRNA FASTQs and wants aligned BAM plus gene/exon counts and transcript quantification outputs.
- Required parameters: `fastq1`, `genes_gtf`, `sample_id`, `paired_end`.
- Optional parameters: `fastq2`, `star.star_index`, `rnaseqc2.*` runtime knobs, `rsem.rsem_reference`, `star.*` and `rsem.*` task settings.
- Outputs: coordinate-sorted BAM/BAI, transcriptome BAM, chimeric junctions, read-count tables, junction tables, RNA-SeQC TPM/count/metrics files, and RSEM gene/isoform quantification.

## Imported Transcriptomics Atomic Tools
These atomic workflows were imported from the source RO-Crate workspace. Each entry keeps the original RO-Crate metadata, source WDL path, paired exported input JSON, and cataloged runtime image references.

### `ballgown`
**Path**: `scripts/ballgown.wdl`  
**Test Input**: `tests/ballgown.inputs.json`  
**Source Workspace**: `Tool_Ballgown` (`Tool_Ballgown`)  
**Source WDL**: `workflow/tool_ballgown-copy/default/Tool_Ballgown_v1.0.wdl`  
**Source Input**: `submission/tool_ballgown-copy-history-2025-08-29-10-58-56/default/input.json`
**Original Metadata**: dataset `td3rld8qtjvcf7ennndt0`, author `liuyuanbin`, published `2025-10-21T09:47:05Z`

Ballgown differential expression analysis workflow for transcriptomic data, supporting statistical analysis at both gene and transcript levels.

- Inputs: `Pattern`, `input_ballgown`, `qvalue`, `pheno_data`, `covariate`.
- Outputs: `transcript_results`, `gene_results`, `diff_transcripts_results`, `diff_genes_results`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/ballgown:new`.

### `cuffdiff`
**Path**: `scripts/cuffdiff.wdl`  
**Test Input**: `tests/cuffdiff.inputs.json`  
**Source Workspace**: `Tool_Cuffdiff` (`Tool_Cuffdiff`)  
**Source WDL**: `workflow/Cuffdiff_analysis/default/Tool_Cuffdiff_v1.0.wdl`  
**Source Input**: `submission/Cuffdiff_analysis-history-2025-09-15-15-32-52/default/input.json`
**Original Metadata**: dataset `td3oq1gqtjvcf7enmukg0`, author `liuyuanbin`, published `2025-10-17T01:49:35Z`

WDL-based Cuffdiff differential expression workflow for RNA-seq data, used to identify genes that are significantly differentially expressed across conditions.

- Inputs: `sam_2`, `FDR`, `time_series`, `fasta`, `threads`, `library_type`, `multi_read_correct`, `labels`, `sam_1`, `gtf`.
- Outputs: `cufdiff.files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/mrna:latest`.

### `cufflinks`
**Path**: `scripts/cufflinks.wdl`  
**Test Input**: `tests/cufflinks.inputs.json`  
**Source Workspace**: `Tool_Cufflinks` (`Tool_Cufflinks`)  
**Source WDL**: `workflow/Cufflinks_Workflow/default/Tool_Cufflinks.wdl`  
**Source Input**: `submission/Cufflinks_Workflow-history-2025-09-03-14-50-51/default/input.json`
**Original Metadata**: dataset `td3rmj2qtjvcf7ennnmc0`, author `liuyuanbin`, published `2025-10-21T11:07:45Z`

Cufflinks is a bioinformatics tool for RNA-seq transcript assembly and quantification. This workflow uses Cufflinks to perform transcript assembly, expression estimation, and differential expression analysis from RNA-seq data.

- Inputs: `threads`, `bam`, `gtf`.
- Outputs: `genes_fpkm_tracking`, `skipped_gtf`, `transcripts_gtf`, `isoforms_fpkm_tracking`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/mrna:latest`.

### `deseq2`
**Path**: `scripts/deseq2.wdl`  
**Test Input**: `tests/deseq2.inputs.json`  
**Source Workspace**: `Tool_DESeq2` (`Tool_DESeq2`)  
**Source WDL**: `workflow/DESeq2_differential_expression_analysis/default/Tool_DESeq2_copy.wdl`  
**Source Input**: `submission/DESeq2_differential_expression_analysis-history-2025-09-05-16-02-22/default/input.json`
**Original Metadata**: dataset `td3rp8hqtjvcf7ennofo0`, author `liuyuanbin`, published `2025-10-21T14:10:05Z`

Uses the R package DESeq2 to perform differential expression analysis on a count matrix and generate result tables and visualization plots (MA plot, PCA plot, and heatmap).

- Inputs: `count`, `tn`, `cn`.
- Outputs: `DESeq2.files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/deseq2:new`.

### `hisat2`
**Path**: `scripts/hisat2.wdl`  
**Test Input**: `tests/hisat2.inputs.json`  
**Source Workspace**: `Tool_Hisat2` (`Tool_Hisat2`)  
**Source WDL**: `workflow/Tool_Hisat2-copy/default/Tool_Hisat2.wdl`  
**Source Input**: `submission/Tool_Hisat2-copy-history-2025-11-20-12-48-54/default/input.json`
**Original Metadata**: dataset `td4fceqkillb3o00gtsg0`, author `liuyuanbin`, published `2025-11-20T07:45:50Z`

Aligns paired-end RNA-seq reads with HISAT2. It first builds an index from the provided reference genome, then performs alignment and outputs a SAM file. It also supports an optional known splice-site file to improve alignment accuracy.

- Inputs: `fasta`, `cpu`, `fq2`, `splicesite`, `fq1`.
- Outputs: `sam`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/mrna:latest`.

### `kallisto`
**Path**: `scripts/kallisto.wdl`  
**Test Input**: `tests/kallisto.inputs.json`  
**Source Workspace**: `Tool_Kallisto` (`Tool_Kallisto`)  
**Source WDL**: `workflow/Tool_Kallisto-copy/default/Tool_Kallisto.wdl`  
**Source Input**: `submission/Tool_Kallisto-copy-history-2025-11-20-12-40-59/default/input.json`
**Original Metadata**: dataset `td4fcg55lvfb7gppq7840`, author `liuyuanbin`, published `2025-11-20T07:49:10Z`

Uses Kallisto for pseudoalignment and quantification of paired-end RNA-seq reads, producing transcript abundance files and run information. The workflow includes kallisto index and kallisto quant steps and outputs transcript quantification results plus run metadata.

- Inputs: `kallisto_db_fa`, `input_read1`, `input_read2`.
- Outputs: `run_info_json`, `transcripts_index`, `abundance_tsv`, `abundance_h5`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/kallisto:latest`.

### `oases`
**Path**: `scripts/oases.wdl`  
**Test Input**: `tests/oases.inputs.json`  
**Source Workspace**: `Tool_Oases` (`Tool_Oases`)  
**Source WDL**: `workflow/oases/default/Tool_oases.wdl`  
**Source Input**: `submission/oases-history-2025-09-09-11-55-42/default/input.json`
**Original Metadata**: dataset `td3vhec7e7hu3grr2gsgg`, author `liuyuanbin`, published `2025-10-27T06:54:20Z`

This workflow uses Velvet/oases for transcriptome assembly. It first runs velveth to build hashes and read directories, then velvetg for graph construction and optimization, and finally oases to generate transcript sequences and ordering information.

- Inputs: `cov_cutoff`, `reads_format`, `min_trans_lgth`, `reads_type`, `seq1`, `ins_length`, `kmer`, `seq2`, `edgeFractionCutoff`, `min_pair_count`.
- Outputs: `oases.files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/oases:latest`.

### `sailfish`
**Path**: `scripts/sailfish.wdl`  
**Test Input**: `tests/sailfish.inputs.json`  
**Source Workspace**: `Tool_sailfish` (`Tool_sailfish`)  
**Source WDL**: `workflow/sailfish-quantification/default/Tool_sailfish.wdl`  
**Source Input**: `submission/sailfish-quantification-history-2025-09-10-09-16-26/default/input.json`
**Original Metadata**: dataset `td3rrkido4spjhk11lqpg`, author `liuyuanbin`, published `2025-10-21T16:52:15Z`

Sailfish-based rapid transcript quantification tool that supports paired-end RNA-seq reads as input and includes index construction and quantification phases.

- Inputs: `threads`, `seq2`, `lib_type`, `kmer`, `seq1`, `transcripts`.
- Outputs: `sailfish.files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/sailfish:latest`.

### `star`
**Path**: `scripts/star.wdl`  
**Test Input**: `tests/star.inputs.json`  
**Source Workspace**: `Tool_STAR` (`Tool_STAR`)  
**Source WDL**: `workflow/STAR_Workflow/default/Tool_STAR.wdl`  
**Source Input**: `submission/STAR_Workflow-history-2025-08-28-23-36-54/default/input.json`
**Original Metadata**: dataset `td3rl6o5o4spjhk11ispg`, author `liuyuanbin`, published `2025-10-21T09:33:10Z`

Uses STAR to build a genome index and align paired-end sequencing reads.

- Inputs: `outSAMtype`, `sjdbOverhang`, `fq1`, `ref`, `fq2`, `gtf`.
- Outputs: `star_outputs`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/star:latest`.

### `stringtie`
**Path**: `scripts/stringtie.wdl`  
**Test Input**: `tests/stringtie.inputs.json`  
**Source Workspace**: `Tool_StringTie` (`Tool_StringTie`)  
**Source WDL**: `workflow/stringtie/default/Tool_StringTie.wdl`  
**Source Input**: `submission/stringtie-history-2025-09-09-15-38-06/default/input.json`
**Original Metadata**: dataset `td3vhno5iveb89860s500`, author `liuyuanbin`, published `2025-10-27T07:14:20Z`

Uses StringTie to assemble and quantify input alignment results (BAM), generating transcript assembly files, gene abundance tables, coverage information, and packaged Ballgown input files.

- Inputs: `m`, `gtf`, `M`, `A`, `bam`, `B`, `f`, `label`, `C`.
- Outputs: `outputs`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/mrna:latest`.

### `trinity`
**Path**: `scripts/trinity.wdl`  
**Test Input**: `tests/trinity.inputs.json`  
**Source Workspace**: `Tool_Trinity` (`Tool_Trinity`)  
**Source WDL**: `workflow/Tool_Trinity/default/Tool_Trinity.wdl`  
**Source Input**: `submission/Tool_Trinity-history-2025-09-17-16-32-57/default/input.json`
**Original Metadata**: dataset `td3riu6qtjvcf7ennmqe0`, author `liuyuanbin`, published `2025-10-21T06:58:20Z`

Trinity de novo transcriptome assembly workflow for assembling paired-end RNA-seq reads without a reference, producing transcript assembly results and an archive of the complete run directory.

- Inputs: `cpu`, `seqtype`, `fq2`, `jaccard_clip`, `max_memory`, `fq1`.
- Outputs: `trinity_out_dir_tar`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/trinity:latest`.

<!-- IMPORTED_ATOMIC_TOOLS_END -->

## Execution Handoff
- Use `bulk_rnaseq_quantification` for ordinary bulk mRNA expression quantification from FASTQ input.
