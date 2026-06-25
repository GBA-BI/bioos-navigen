---
name: bioos_transcriptomics
description: Route transcriptomics Bio-OS workflows. Use this skill for bulk
  RNA-seq quantification, RNA-seq alignment, transcript assembly, transcript
  quantification, and differential expression workflows that should run with
  Bio-OS WDLs.
disable: false
---

# Bio-OS Transcriptomics

## Scope
This is the business-layer skill for transcriptome-focused workflows.

- Use this skill for expression-oriented RNA pipelines, RNA-seq alignment, transcript assembly, transcript quantification, and differential expression analysis.
- Use this skill for bulk RNA-seq quantification with STAR/RNA-SeQC/RSEM in addition to STAR, HISAT2, StringTie, Kallisto, Sailfish, Cufflinks, Cuffdiff, Ballgown, DESeq2, Oases, and Trinity workflows.
- Do not use this skill for single-cell RNA-seq counting, 10x Cell Ranger V(D)J, TCR/BCR repertoire processing, or SeekSoulTools workflows; those should route to `bioos_singlecell`.
- Do not use this skill for variant-centric DNA or RNA calling; those should route to `bioos_genomics`.
- Before changing image references, consult the `bioos_docker_registry_catalog` skill.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use workflow names below as the user-facing routing units; internal task names are implementation details.
- For WDL `File` inputs, use the `bioos_platform_operator` skill and follow its file-input instructions.

## Included Workflows

### `bulk_rnaseq_quantification`
**Path**: `scripts/bulk_rnaseq_quantification.wdl`
**Test Input**: `tests/bulk_rnaseq_quantification.inputs.json`

GTEx-style bulk RNA-seq quantification from FASTQ input using STAR alignment, RNA-SeQC2 metrics, and RSEM quantification.

- Trigger when: the user has bulk mRNA FASTQs and wants aligned BAM plus gene/exon counts and transcript quantification outputs.
- Required parameters: `fastq1`, `genes_gtf`, `sample_id`, `paired_end`.
- Optional parameters: `fastq2`, `star.star_index`, `rnaseqc2.*` runtime knobs, `rsem.rsem_reference`, `star.*` and `rsem.*` task settings.
- Outputs: coordinate-sorted BAM/BAI, transcriptome BAM, chimeric junctions, read-count tables, junction tables, RNA-SeQC TPM/count/metrics files, and RSEM gene/isoform quantification.

### `ballgown`
**Path**: `scripts/ballgown.wdl`
**Test Input**: `tests/ballgown.inputs.json`

Ballgown differential expression analysis workflow for transcriptomic data, supporting statistical analysis at both gene and transcript levels.

- Trigger when: the user asks for `ballgown` or the described workflow capability.
- Required parameters: `Pattern`, `input_ballgown`, `qvalue`, `pheno_data`, `covariate`.
- Optional parameters: none documented.
- Outputs: `transcript_results`, `gene_results`, `diff_transcripts_results`, `diff_genes_results`.

### `cuffdiff`
**Path**: `scripts/cuffdiff.wdl`
**Test Input**: `tests/cuffdiff.inputs.json`

WDL-based Cuffdiff differential expression workflow for RNA-seq data, used to identify genes that are significantly differentially expressed across conditions.

- Trigger when: the user asks for `cuffdiff` or the described workflow capability.
- Required parameters: `sam_2`, `FDR`, `time_series`, `fasta`, `threads`, `library_type`, `multi_read_correct`, `labels`, `sam_1`, `gtf`.
- Optional parameters: none documented.
- Outputs: `cufdiff.files`.

### `cufflinks`
**Path**: `scripts/cufflinks.wdl`
**Test Input**: `tests/cufflinks.inputs.json`

Cufflinks is a bioinformatics tool for RNA-seq transcript assembly and quantification. This workflow uses Cufflinks to perform transcript assembly, expression estimation, and differential expression analysis from RNA-seq data.

- Trigger when: the user asks for `cufflinks` or the described workflow capability.
- Required parameters: `threads`, `bam`, `gtf`.
- Optional parameters: none documented.
- Outputs: `genes_fpkm_tracking`, `skipped_gtf`, `transcripts_gtf`, `isoforms_fpkm_tracking`.

### `deseq2`
**Path**: `scripts/deseq2.wdl`
**Test Input**: `tests/deseq2.inputs.json`

Uses the R package DESeq2 to perform differential expression analysis on a count matrix and generate result tables and visualization plots (MA plot, PCA plot, and heatmap).

- Trigger when: the user asks for `deseq2` or the described workflow capability.
- Required parameters: `count`, `tn`, `cn`.
- Optional parameters: none documented.
- Outputs: `DESeq2.files`.

### `hisat2`
**Path**: `scripts/hisat2.wdl`
**Test Input**: `tests/hisat2.inputs.json`

Aligns paired-end RNA-seq reads with HISAT2. It first builds an index from the provided reference genome, then performs alignment and outputs a SAM file. It also supports an optional known splice-site file to improve alignment accuracy.

- Trigger when: the user asks for `hisat2` or the described workflow capability.
- Required parameters: `fasta`, `cpu`, `fq2`, `splicesite`, `fq1`.
- Optional parameters: none documented.
- Outputs: `sam`.

### `kallisto`
**Path**: `scripts/kallisto.wdl`
**Test Input**: `tests/kallisto.inputs.json`

Uses Kallisto for pseudoalignment and quantification of paired-end RNA-seq reads, producing transcript abundance files and run information. The workflow includes kallisto index and kallisto quant steps and outputs transcript quantification results plus run metadata.

- Trigger when: the user asks for `kallisto` or the described workflow capability.
- Required parameters: `kallisto_db_fa`, `input_read1`, `input_read2`.
- Optional parameters: none documented.
- Outputs: `run_info_json`, `transcripts_index`, `abundance_tsv`, `abundance_h5`.

### `oases`
**Path**: `scripts/oases.wdl`
**Test Input**: `tests/oases.inputs.json`

This workflow uses Velvet/oases for transcriptome assembly. It first runs velveth to build hashes and read directories, then velvetg for graph construction and optimization, and finally oases to generate transcript sequences and ordering information.

- Trigger when: the user asks for `oases` or the described workflow capability.
- Required parameters: `cov_cutoff`, `reads_format`, `min_trans_lgth`, `reads_type`, `seq1`, `ins_length`, `kmer`, `seq2`, `edgeFractionCutoff`, `min_pair_count`.
- Optional parameters: none documented.
- Outputs: `oases.files`.

### `sailfish`
**Path**: `scripts/sailfish.wdl`
**Test Input**: `tests/sailfish.inputs.json`

Sailfish-based rapid transcript quantification tool that supports paired-end RNA-seq reads as input and includes index construction and quantification phases.

- Trigger when: the user asks for `sailfish` or the described workflow capability.
- Required parameters: `threads`, `seq2`, `lib_type`, `kmer`, `seq1`, `transcripts`.
- Optional parameters: none documented.
- Outputs: `sailfish.files`.

### `star`
**Path**: `scripts/star.wdl`
**Test Input**: `tests/star.inputs.json`

Uses STAR to build a genome index and align paired-end sequencing reads.

- Trigger when: the user asks for `star` or the described workflow capability.
- Required parameters: `outSAMtype`, `sjdbOverhang`, `fq1`, `ref`, `fq2`, `gtf`.
- Optional parameters: none documented.
- Outputs: `star_outputs`.

### `stringtie`
**Path**: `scripts/stringtie.wdl`
**Test Input**: `tests/stringtie.inputs.json`

Uses StringTie to assemble and quantify input alignment results (BAM), generating transcript assembly files, gene abundance tables, coverage information, and packaged Ballgown input files.

- Trigger when: the user asks for `stringtie` or the described workflow capability.
- Required parameters: `m`, `gtf`, `M`, `A`, `bam`, `B`, `f`, `label`, `C`.
- Optional parameters: none documented.
- Outputs: `outputs`.

### `trinity`
**Path**: `scripts/trinity.wdl`
**Test Input**: `tests/trinity.inputs.json`

Trinity de novo transcriptome assembly workflow for assembling paired-end RNA-seq reads without a reference, producing transcript assembly results and an archive of the complete run directory.

- Trigger when: the user asks for `trinity` or the described workflow capability.
- Required parameters: `cpu`, `seqtype`, `fq2`, `jaccard_clip`, `max_memory`, `fq1`.
- Optional parameters: none documented.
- Outputs: `trinity_out_dir_tar`.

## Execution Handoff
- Start from the matching `tests/*.inputs.json` template and use the `bioos_platform_operator` skill for file inputs and workflow submission.
- Use `bulk_rnaseq_quantification` for ordinary bulk mRNA expression quantification from FASTQ input.
