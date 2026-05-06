---
name: bioos_genomics
description: Route genomics sequence alignment, genome assembly, assembly QC, structural variant, sequence clustering, and repeat-analysis Bio-OS workflows. Use this skill for BWA/BLASR/BLAT alignment, CAP3/SPAdes assembly, SSPACE/OPERA scaffolding, QUAST/REAPR assessment, CD-HIT clustering, MUMmer comparison, PRISM insert-size analysis, XSTREAM repeat analysis, and LUMPY-style SV workflows that should run with Bio-OS WDLs.
---

# Bio-OS Genomics

## Scope
This is the business-layer skill for genomics sequence-analysis workflows.

- Use this skill when the user wants sequence alignment, genome assembly/scaffolding, assembly QC, insert-size analysis, sequence clustering, genome comparison, repeat analysis, or structural variant detection.
- Keep RNA expression, single-cell counting, Iso-Seq, and small RNA workflows in `bioos_transcriptomics`.
- Before changing any image reference, consult `../bioos_docker_registry_catalog/SKILL.md`.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use the workflow names below as the user-facing routing units; internal `task` blocks are implementation details.
- Prefer the provided `tests/*.inputs.json` as starting templates, then replace workspace-specific file paths for the actual run.

## Included Workflows

## Imported Genomics Atomic Tools
These atomic workflows were imported from the source RO-Crate workspace. Each entry keeps the original RO-Crate metadata, source WDL path, paired exported input JSON, and cataloged runtime image references.

### `blasr`
**Path**: `scripts/blasr.wdl`  
**Test Input**: `tests/blasr.inputs.json`  
**Source Workspace**: `Tool_BLASR` (`Tool_BLASR`)  
**Source WDL**: `workflow/tool_blasr-copy/default/Tool_BLASR_v1.0.wdl`  
**Source Input**: `submission/tool_blasr-copy-history-2025-09-05-09-39-06/default/input.json`
**Original Metadata**: dataset `td3rp60lo4spjhk11ko9g`, author `liuyuanbin`, published `2025-10-21T14:04:40Z`

BLASR (Basic Local Alignment with Successive Refinement) is a tool for aligning long reads, such as PacBio or Oxford Nanopore reads, to a reference genome. This workflow wraps BLASR with flexible alignment parameter settings for bioinformatics tasks such as genome assembly, variant detection, and sequence analysis.

- Inputs: `input_ref`, `outformat`, `minreads_len`, `clipping`, `minmatch`, `nproc`, `maxscore`, `subreads_len`, `input_query`.
- Outputs: `BLASR.result`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/assembletool:latest`.

### `blat`
**Path**: `scripts/blat.wdl`  
**Test Input**: `tests/blat.inputs.json`  
**Source Workspace**: `Tool_Blat` (`Tool_Blat`)  
**Source WDL**: `workflow/Tool_Blat/default/Tool_Blat.wdl`  
**Source Input**: `submission/Tool_Blat-history-2025-09-15-14-23-31/default/input.json`
**Original Metadata**: dataset `td3rrioto4spjhk11lpmg`, author `liuyuanbin`, published `2025-10-21T16:48:25Z`

WDL-based BLAT sequence alignment workflow for rapidly aligning query sequences against a reference database.

- Inputs: `db_fasta`, `query_fasta`, `prefix`.
- Outputs: `blat.blat_result`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metatools:lite`.

### `bwa_aln`
**Path**: `scripts/bwa_aln.wdl`  
**Test Input**: `tests/bwa_aln.inputs.json`  
**Source Workspace**: `BWA_ALN_Workspace` (`BWA_ALN_Workspace`)  
**Source WDL**: `workflow/BWA_ALN_Analysis_v1/default/Tool_BWA_ALN_v1.0.wdl`  
**Source Input**: `submission/BWA_ALN_Analysis_v1-history-2025-09-01-16-43-44/default/input.json`
**Original Metadata**: dataset `td3rl5catjvcf7ennnbbg`, author `liuyuanbin`, published `2025-10-21T09:30:10Z`

The BWA ALN workflow is an analysis tool for paired-end sequencing alignment. It uses the BWA algorithm to align paired-end sequencing data and generate SAM-format alignment result files.

- Inputs: `ref`, `fq1`, `fq2`, `threads`.
- Outputs: `output_sam`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/bwa:latest`.

### `bwa_mem`
**Path**: `scripts/bwa_mem.wdl`  
**Test Input**: `tests/bwa_mem.inputs.json`  
**Source Workspace**: `Tool_BWA_MEM` (`Tool_BWA_MEM`)  
**Source WDL**: `workflow/BWA_MEM_Workflow/default/Tool_BWA_MEM.wdl`  
**Source Input**: `submission/BWA_MEM_Workflow-history-2025-09-02-21-37-49/default/input.json`
**Original Metadata**: dataset `td3rl855o4spjhk11itq0`, author `liuyuanbin`, published `2025-10-21T09:36:05Z`

BWA MEM (Burrows-Wheeler Aligner Maximal Exact Matches) is a bioinformatics tool for aligning paired-end sequencing data to a reference genome. This workflow implements the full BWA MEM alignment process, including reference genome index construction and sequence alignment.

- Inputs: `other_para`, `fq2`, `fq1`, `threads`, `ref`.
- Outputs: `bwa_mem.sam_output`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/bwa:latest`.

### `bwa_sw`
**Path**: `scripts/bwa_sw.wdl`  
**Test Input**: `tests/bwa_sw.inputs.json`  
**Source Workspace**: `Tool_BWA_SW` (`Tool_BWA_SW`)  
**Source WDL**: `workflow/BWA_SW_Workflow/default/Tool_BWA_SW.wdl`  
**Source Input**: `submission/BWA_SW_Workflow-history-2025-09-02-22-08-15/default/input.json`
**Original Metadata**: dataset `td3rla9qtjvcf7ennnd90`, author `liuyuanbin`, published `2025-10-21T09:40:40Z`

The BWA SW (Smith-Waterman) workflow is a bioinformatics tool for long-read sequence alignment. It is based on the Smith-Waterman algorithm in BWA (Burrows-Wheeler Aligner) and is designed for long-read sequencing data such as PacBio or Oxford Nanopore data.

- Inputs: `fq2`, `threads`, `fq1`, `ref`.
- Outputs: `bwa_sw.sam_output`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/bwa:latest`.

### `cap3`
**Path**: `scripts/cap3.wdl`  
**Test Input**: `tests/cap3.inputs.json`  
**Source Workspace**: `Tool_CAP3` (`Tool_CAP3`)  
**Source WDL**: `workflow/CAP3_Workflow/default/Tool_CAP3_v1.0_update.wdl`  
**Source Input**: `submission/CAP3_Workflow-history-2025-09-05-10-47-01/default/input.json`
**Original Metadata**: dataset `td3rp79qtjvcf7ennof20`, author `liuyuanbin`, published `2025-10-21T14:07:25Z`

CAP3 DNA sequence assembly workflow. It uses the CAP3 algorithm to assemble FASTA-format DNA sequences and generate assembly results such as contigs and singlets.

- Inputs: `fasta`.
- Outputs: `cap3.result`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/cap3:latest`.

### `cd_hit`
**Path**: `scripts/cd_hit.wdl`  
**Test Input**: `tests/cd_hit.inputs.json`  
**Source Workspace**: `Tool_CD_HIT` (`Tool_CD_HIT`)  
**Source WDL**: `workflow/CD_HIT_Workflow/default/Tool_CD_HIT_v1.0.wdl`  
**Source Input**: `submission/CD_HIT_Workflow-history-2025-08-29-01-33-16/default/input.json`
**Original Metadata**: dataset `td3rl1mqtjvcf7ennn9h0`, author `liuyuanbin`, published `2025-10-21T09:22:25Z`

CD-HIT (Cluster Database at High Identity with Tolerance) is a tool for clustering protein or nucleotide sequences. It removes redundant sequences based on a sequence similarity threshold and generates a nonredundant sequence set.

- Inputs: `threads`, `word_length`, `identity`, `fasta`.
- Outputs: `output_tgz`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/cdhit:4.7-1`.

### `lumpy`
**Path**: `scripts/lumpy.wdl`  
**Test Input**: `tests/lumpy.inputs.json`  
**Source Workspace**: `LUMPY Workspace` (`LUMPY Workspace`)  
**Source WDL**: `workflow/LUMPY/default/Tool_LUMPY_copy.wdl`  
**Source Input**: `submission/LUMPY-history-2025-09-04-13-13-48/default/input.json`
**Original Metadata**: dataset `td3rp30do4spjhk11kln0`, author `liuyuanbin`, published `2025-10-21T13:58:15Z`

LUMPY structural variant detection workflow for identifying genomic structural variants, including insertions, deletions, inversions, and translocations.

- Inputs: `fq2`, `fasta`, `fq1`.
- Outputs: `vcf`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/lumpy:latest`.

### `mummer`
**Path**: `scripts/mummer.wdl`  
**Test Input**: `tests/mummer.inputs.json`  
**Source Workspace**: `Tool_MUMmer` (`Tool_MUMmer`)  
**Source WDL**: `workflow/MUMmer_nucmer/default/Tool_MUMmer.wdl`  
**Source Input**: `submission/MUMmer_nucmer-history-2025-09-03-15-43-31/default/input.json`
**Original Metadata**: dataset `td3rn3r5o4spjhk11jpt0`, author `liuyuanbin`, published `2025-10-21T11:43:30Z`

Nucmer from MUMmer3 is a tool for evaluating and processing sequence alignments.

- Inputs: `out_prefix`, `fa`, `ref`.
- Outputs: `result_files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/mummer3:v1`.

### `opera`
**Path**: `scripts/opera.wdl`  
**Test Input**: `tests/opera.inputs.json`  
**Source Workspace**: `Tool_OPERA` (`Tool_OPERA`)  
**Source WDL**: `workflow/OPERA-LG/default/Tool_OPERA.wdl`  
**Source Input**: `submission/OPERA-LG-history-2025-09-03-14-55-31/default/input.json`
**Original Metadata**: dataset `td3rn1jqtjvcf7ennnqa0`, author `liuyuanbin`, published `2025-10-21T11:38:35Z`

OPERA-LG long-read-assisted scaffolding workflow. It accepts contigs, Illumina paired-end short reads, and long reads, then runs OPERA-long-read to build scaffolds and output the results.

- Inputs: `kmer`, `num_of_processors`, `fq2`, `fq1`, `long_read_file`, `contig_file`.
- Outputs: `opera_result_tar`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/opera:latest`.

### `prism`
**Path**: `scripts/prism.wdl`  
**Test Input**: `tests/prism.inputs.json`  
**Source Workspace**: `Tool_PRISM` (`Tool_PRISM`)  
**Source WDL**: `workflow/PRISM_Workflow/default/Tool_PRISM_v1.0_copy.wdl`  
**Source Input**: `submission/PRISM_Workflow-history-2025-09-04-09-57-39/default/input.json`
**Original Metadata**: dataset `td3rndc5o4spjhk11jvig`, author `liuyuanbin`, published `2025-10-21T12:03:45Z`

PRISM (Paired-end Reads for Insert Size Measurement) is a tool for analyzing paired-end sequencing data, primarily to calculate insert size and standard deviation. It can process SAM-format alignment files and FASTA-format reference genome files and outputs insert-size statistics.

- Inputs: `insert_size`, `fa`, `standard_deviation_insert_size`, `sam`.
- Outputs: `prism1.files`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/prism:latest`.

### `quast`
**Path**: `scripts/quast.wdl`  
**Test Input**: `tests/quast.inputs.json`  
**Source Workspace**: `Tool_QUAST` (`Tool_QUAST`)  
**Source WDL**: `workflow/Tool_QUAST-copy/default/Tool_QUAST.wdl`  
**Source Input**: `submission/Tool_QUAST-copy-history-2025-11-20-12-47-23/default/input.json`
**Original Metadata**: dataset `td4fcj45lvfb7gppq7an0`, author `liuyuanbin`, published `2025-11-20T07:55:40Z`

QUAST (Quality Assessment Tool for Genome Assemblies) performs quality assessment and benchmarking of genome assembly results. It supports optional inputs such as a reference genome, gene annotations, and operons, and outputs comprehensive assessment reports and statistics.

- Inputs: `contigs`, `eukaryote`, `scaffolds`, `features`, `ref`, `min_contig`, `operons`.
- Outputs: `quast_results_tgz`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metatools:lite`.

### `reapr`
**Path**: `scripts/reapr.wdl`  
**Test Input**: `tests/reapr.inputs.json`  
**Source Workspace**: `Tool_REAPR` (`Tool_REAPR`)  
**Source WDL**: `workflow/REAPR_Workflow/default/Tool_REAPR.wdl`  
**Source Input**: `submission/REAPR_Workflow-history-2025-09-01-17-05-57/default/input.json`
**Original Metadata**: dataset `td3rl355o4spjhk11iqrg`, author `liuyuanbin`, published `2025-10-21T09:25:30Z`

Uses REAPR to evaluate genome assemblies and detect errors. The process includes aligning sequencing reads to the assembly, running the REAPR pipeline, and packaging the outputs.

- Inputs: `fq1`, `fq2`, `assembly_fa`.
- Outputs: `output_tgz`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metatools:lite`.

### `spades`
**Path**: `scripts/spades.wdl`  
**Test Input**: `tests/spades.inputs.json`  
**Source Workspace**: `Tool_SPAdes` (`Tool_SPAdes`)  
**Source WDL**: `workflow/spades_workflow/default/spades_copy.wdl`  
**Source Input**: `submission/spades_workflow-history-2025-09-09-16-19-05/default/input.json`
**Original Metadata**: dataset `td3rq6e5o4spjhk11l7fg`, author `liuyuanbin`, published `2025-10-21T15:13:40Z`

Workflow for assembling paired-end sequencing data with SPAdes. It supports common parameters such as k-mer values and thread count, with configurable switches for careful mode and single-cell mode. It is suitable for assembling small genomes or metagenomic subsets.

- Inputs: `spades.spades_bin`, `fq2`, `fq1`, `outFolder`, `prefix`, `threads`, `spades.single_cell`, `spades.disable_gzip_output`, `spades.careful`, `kmer`.
- Outputs: `graph`, `contigs`, `params`, `log`, `out_dir`, `scaffolds`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/assembletool:latest`.

### `sspace`
**Path**: `scripts/sspace.wdl`  
**Test Input**: `tests/sspace.inputs.json`  
**Source Workspace**: `Tool_SSPACE` (`Tool_SSPACE`)  
**Source WDL**: `workflow/SSPACE-Scaffolding/default/Tool_SSPACE.wdl`  
**Source Input**: `submission/SSPACE-Scaffolding-history-2025-09-09-16-01-02/default/input.json`
**Original Metadata**: dataset `td3rq1fatjvcf7ennoltg`, author `liuyuanbin`, published `2025-10-21T15:03:10Z`

SSPACE assembly scaffolding workflow that uses paired sequencing reads to scaffold assembled contigs.

- Inputs: `fq1`, `fa`, `expected_inserted_size`, `fq2`, `minimum_allowed_error`.
- Outputs: `SSPACE.result_files`, `SSPACE.libraries`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/sspace:v1`.

### `xstream`
**Path**: `scripts/xstream.wdl`  
**Test Input**: `tests/xstream.inputs.json`  
**Source Workspace**: `Tool_XSTREAM` (`Tool_XSTREAM`)  
**Source WDL**: `workflow/XSTREAM_Tool/default/Tool_XSTREAM.wdl`  
**Source Input**: `submission/XSTREAM_Tool-history-2025-08-28-22-23-26/default/input.json`
**Original Metadata**: dataset `td3or15do4spjhk10l0pg`, author `liuyuanbin`, published `2025-10-17T02:57:15Z`

XSTREAM rapidly identifies and models basic tandem repeat (TR) structures in protein sequences. Given the broad prevalence of TRs, it can also process many DNA-containing sequences.

- Inputs: `g`, `D`, `x`, `t`, `m`, `i`, `I`, `fasta`, `e`.
- Outputs: `log`, `html_reports`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/xstream:latest`.

<!-- IMPORTED_ATOMIC_TOOLS_END -->

## Execution Handoff
- Start from the paired `tests/*.inputs.json` template for the selected workflow and replace placeholder paths with the current workspace resources.
- If the user needs a new image or major WDL rewrite, hand off to the `skills-cli` builder stack instead of modifying this business skill first.
