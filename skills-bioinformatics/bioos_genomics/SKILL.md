---
name: bioos_genomics
description: Route genomics sequence alignment, genome assembly, assembly QC,
  structural variant, sequence clustering, and repeat-analysis Bio-OS workflows.
  Use this skill for BWA/BLASR/BLAT alignment, CAP3/SPAdes assembly,
  SSPACE/OPERA scaffolding, QUAST/REAPR assessment, CD-HIT clustering, MUMmer
  comparison, PRISM insert-size analysis, XSTREAM repeat analysis, and
  LUMPY-style SV workflows that should run with Bio-OS WDLs.
disable: false
---

# Bio-OS Genomics

## Scope
This is the business-layer skill for genomics sequence-analysis workflows.

- Use this skill when the user wants sequence alignment, genome assembly/scaffolding, assembly QC, insert-size analysis, sequence clustering, genome comparison, repeat analysis, or structural variant detection.
- Keep RNA expression, Iso-Seq, and small RNA workflows in `bioos_transcriptomics`; route single-cell counting and V(D)J workflows to `bioos_singlecell`.
- Before changing any image reference, consult the `bioos_docker_registry_catalog` skill.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use workflow names below as the user-facing routing units; internal task names are implementation details.
- For WDL `File` inputs, use the `bioos_platform_operator` skill and follow its file-input instructions.

## Included Workflows

### `blasr`
**Path**: `scripts/blasr.wdl`
**Test Input**: `tests/blasr.inputs.json`

BLASR (Basic Local Alignment with Successive Refinement) is a tool for aligning long reads, such as PacBio or Oxford Nanopore reads, to a reference genome. This workflow wraps BLASR with flexible alignment parameter settings for bioinformatics tasks such as genome assembly, variant detection, and sequence analysis.

- Trigger when: the user asks for `blasr` or the described workflow capability.
- Required parameters: `input_ref`, `outformat`, `minreads_len`, `clipping`, `minmatch`, `nproc`, `maxscore`, `subreads_len`, `input_query`.
- Optional parameters: none documented.
- Outputs: `BLASR.result`.

### `blat`
**Path**: `scripts/blat.wdl`
**Test Input**: `tests/blat.inputs.json`

WDL-based BLAT sequence alignment workflow for rapidly aligning query sequences against a reference database.

- Trigger when: the user asks for `blat` or the described workflow capability.
- Required parameters: `db_fasta`, `query_fasta`, `prefix`.
- Optional parameters: none documented.
- Outputs: `blat.blat_result`.

### `bwa_aln`
**Path**: `scripts/bwa_aln.wdl`
**Test Input**: `tests/bwa_aln.inputs.json`

The BWA ALN workflow is an analysis tool for paired-end sequencing alignment. It uses the BWA algorithm to align paired-end sequencing data and generate SAM-format alignment result files.

- Trigger when: the user asks for `bwa_aln` or the described workflow capability.
- Required parameters: `ref`, `fq1`, `fq2`, `threads`.
- Optional parameters: none documented.
- Outputs: `output_sam`.

### `bwa_mem`
**Path**: `scripts/bwa_mem.wdl`
**Test Input**: `tests/bwa_mem.inputs.json`

BWA MEM (Burrows-Wheeler Aligner Maximal Exact Matches) is a bioinformatics tool for aligning paired-end sequencing data to a reference genome. This workflow implements the full BWA MEM alignment process, including reference genome index construction and sequence alignment.

- Trigger when: the user asks for `bwa_mem` or the described workflow capability.
- Required parameters: `other_para`, `fq2`, `fq1`, `threads`, `ref`.
- Optional parameters: none documented.
- Outputs: `bwa_mem.sam_output`.

### `bwa_sw`
**Path**: `scripts/bwa_sw.wdl`
**Test Input**: `tests/bwa_sw.inputs.json`

The BWA SW (Smith-Waterman) workflow is a bioinformatics tool for long-read sequence alignment. It is based on the Smith-Waterman algorithm in BWA (Burrows-Wheeler Aligner) and is designed for long-read sequencing data such as PacBio or Oxford Nanopore data.

- Trigger when: the user asks for `bwa_sw` or the described workflow capability.
- Required parameters: `fq2`, `threads`, `fq1`, `ref`.
- Optional parameters: none documented.
- Outputs: `bwa_sw.sam_output`.

### `cap3`
**Path**: `scripts/cap3.wdl`
**Test Input**: `tests/cap3.inputs.json`

CAP3 DNA sequence assembly workflow. It uses the CAP3 algorithm to assemble FASTA-format DNA sequences and generate assembly results such as contigs and singlets.

- Trigger when: the user asks for `cap3` or the described workflow capability.
- Required parameters: `fasta`.
- Optional parameters: none documented.
- Outputs: `cap3.result`.

### `cd_hit`
**Path**: `scripts/cd_hit.wdl`
**Test Input**: `tests/cd_hit.inputs.json`

CD-HIT (Cluster Database at High Identity with Tolerance) is a tool for clustering protein or nucleotide sequences. It removes redundant sequences based on a sequence similarity threshold and generates a nonredundant sequence set.

- Trigger when: the user asks for `cd_hit` or the described workflow capability.
- Required parameters: `threads`, `word_length`, `identity`, `fasta`.
- Optional parameters: none documented.
- Outputs: `output_tgz`.

### `lumpy`
**Path**: `scripts/lumpy.wdl`
**Test Input**: `tests/lumpy.inputs.json`

LUMPY structural variant detection workflow for identifying genomic structural variants, including insertions, deletions, inversions, and translocations.

- Trigger when: the user asks for `lumpy` or the described workflow capability.
- Required parameters: `fq2`, `fasta`, `fq1`.
- Optional parameters: none documented.
- Outputs: `vcf`.

### `mummer`
**Path**: `scripts/mummer.wdl`
**Test Input**: `tests/mummer.inputs.json`

Nucmer from MUMmer3 is a tool for evaluating and processing sequence alignments.

- Trigger when: the user asks for `mummer` or the described workflow capability.
- Required parameters: `out_prefix`, `fa`, `ref`.
- Optional parameters: none documented.
- Outputs: `result_files`.

### `opera`
**Path**: `scripts/opera.wdl`
**Test Input**: `tests/opera.inputs.json`

OPERA-LG long-read-assisted scaffolding workflow. It accepts contigs, Illumina paired-end short reads, and long reads, then runs OPERA-long-read to build scaffolds and output the results.

- Trigger when: the user asks for `opera` or the described workflow capability.
- Required parameters: `kmer`, `num_of_processors`, `fq2`, `fq1`, `long_read_file`, `contig_file`.
- Optional parameters: none documented.
- Outputs: `opera_result_tar`.

### `prism`
**Path**: `scripts/prism.wdl`
**Test Input**: `tests/prism.inputs.json`

PRISM (Paired-end Reads for Insert Size Measurement) is a tool for analyzing paired-end sequencing data, primarily to calculate insert size and standard deviation. It can process SAM-format alignment files and FASTA-format reference genome files and outputs insert-size statistics.

- Trigger when: the user asks for `prism` or the described workflow capability.
- Required parameters: `insert_size`, `fa`, `standard_deviation_insert_size`, `sam`.
- Optional parameters: none documented.
- Outputs: `prism1.files`.

### `quast`
**Path**: `scripts/quast.wdl`
**Test Input**: `tests/quast.inputs.json`

QUAST (Quality Assessment Tool for Genome Assemblies) performs quality assessment and benchmarking of genome assembly results. It supports optional inputs such as a reference genome, gene annotations, and operons, and outputs comprehensive assessment reports and statistics.

- Trigger when: the user asks for `quast` or the described workflow capability.
- Required parameters: `contigs`, `eukaryote`, `scaffolds`, `features`, `ref`, `min_contig`, `operons`.
- Optional parameters: none documented.
- Outputs: `quast_results_tgz`.

### `reapr`
**Path**: `scripts/reapr.wdl`
**Test Input**: `tests/reapr.inputs.json`

Uses REAPR to evaluate genome assemblies and detect errors. The process includes aligning sequencing reads to the assembly, running the REAPR pipeline, and packaging the outputs.

- Trigger when: the user asks for `reapr` or the described workflow capability.
- Required parameters: `fq1`, `fq2`, `assembly_fa`.
- Optional parameters: none documented.
- Outputs: `output_tgz`.

### `spades`
**Path**: `scripts/spades.wdl`
**Test Input**: `tests/spades.inputs.json`

Workflow for assembling paired-end sequencing data with SPAdes. It supports common parameters such as k-mer values and thread count, with configurable switches for careful mode and single-cell mode. It is suitable for assembling small genomes or metagenomic subsets.

- Trigger when: the user asks for `spades` or the described workflow capability.
- Required parameters: `spades.spades_bin`, `fq2`, `fq1`, `outFolder`, `prefix`, `threads`, `spades.single_cell`, `spades.disable_gzip_output`, `spades.careful`, `kmer`.
- Optional parameters: none documented.
- Outputs: `graph`, `contigs`, `params`, `log`, `out_dir`, `scaffolds`.

### `sspace`
**Path**: `scripts/sspace.wdl`
**Test Input**: `tests/sspace.inputs.json`

SSPACE assembly scaffolding workflow that uses paired sequencing reads to scaffold assembled contigs.

- Trigger when: the user asks for `sspace` or the described workflow capability.
- Required parameters: `fq1`, `fa`, `expected_inserted_size`, `fq2`, `minimum_allowed_error`.
- Optional parameters: none documented.
- Outputs: `SSPACE.result_files`, `SSPACE.libraries`.

### `xstream`
**Path**: `scripts/xstream.wdl`
**Test Input**: `tests/xstream.inputs.json`

XSTREAM rapidly identifies and models basic tandem repeat (TR) structures in protein sequences. Given the broad prevalence of TRs, it can also process many DNA-containing sequences.

- Trigger when: the user asks for `xstream` or the described workflow capability.
- Required parameters: `g`, `D`, `x`, `t`, `m`, `i`, `I`, `fasta`, `e`.
- Optional parameters: none documented.
- Outputs: `log`, `html_reports`.

## Execution Handoff
- Start from the matching `tests/*.inputs.json` template and use the `bioos_platform_operator` skill for file inputs and workflow submission.
- If the user needs a new image, hand off to the `bioos_docker_builder` skill; for major WDL rewrites, hand off to the `bioos_wdl_scripter` skill instead of modifying this business skill first.
