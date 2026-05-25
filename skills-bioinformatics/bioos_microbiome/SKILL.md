---
name: bioos_microbiome
description: >
  Route microbiome biomarker discovery, taxon-level group comparison, taxonomic
  profiling, community abundance processing, functional potential prediction,
  and LEfSe-style effect-size analysis workflows on Bio-OS. Trigger when user
  mentions LEfSe, microbiome differential analysis, microbial biomarker, group
  comparison, taxonomic profiling, abundance binning, PICRUSt, Kaiju, DUDes,
  StrainEst, differential abundance, microbial biomarkers, species-level
  differential analysis, or LEfSe analysis.
disable: true
---

# Bio-OS Microbiome

## Scope
This is the business-layer skill for microbiome and microbial community analysis workflows.

- Use this skill when the user wants microbiome biomarker discovery, taxon-level group comparison, community taxonomic profiling, abundance binning, functional-potential prediction, or LEfSe-style effect-size analysis.
- Use this skill for abundance tables or feature matrices derived from microbiome studies rather than raw pathogen consensus-sequence QC, lineage assignment, or viral SNV calling.
- If the request is about Nextclade, Pangolin, viral SNV detection, or HiFi MAG reconstruction, route to the `bioos_microbiology_pathology` skill instead.
- If a new workflow must be authored, hand off to the `bioos_pipeline_developer` skill.
- If a runtime image needs to be rebuilt, hand off to the `bioos_docker_builder` skill.
- Before changing any image reference, consult the `bioos_docker_registry_catalog` skill.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Expose one user-facing workflow per scientific capability; internal task names are implementation details.
- For WDL `File` inputs, follow the `bioos_platform_operator` skill's file path instructions. `inputs.json` may use `drs://...`, workspace `s3://...`, or an existing local absolute path.

## Included Workflows

### 1. `lefse_microbiome_biomarker_analysis`
**Path**: `scripts/lefse_microbiome_biomarker_analysis.wdl`
**Test Input**: `tests/lefse_microbiome_biomarker_analysis.inputs.json`

Run LEfSe on a formatted microbiome abundance table to identify class-associated biomarkers and generate effect-size visualizations.

- Trigger when: the user wants LEfSe biomarker discovery, class-vs-subclass microbial community comparison, or publication-style bar/cladogram outputs from a microbiome feature table.
- Do not use when: the user only has raw FASTQ or assembled pathogen genomes and needs upstream taxonomic profiling or consensus-sequence analysis first.

```yaml
name: lefse_microbiome_biomarker_analysis
description: Run LEfSe on a formatted microbiome abundance table and emit the formatted input, LEfSe result matrix, bar plot, cladogram, and feature-level plots.
required_parameters:
  - input_file
optional_parameters:
  - whether_features_1_override
  - row_subject_1_override
  - row_subclass_1_override
  - row_class_1_override
  - normalization_value_1_override
  - stratege_muti_class_2_override
  - one_against_one_2_override
  - Wilcoxon_test_2_override
  - threshold_absolute_value_2_override
  - same_name_2_override
  - Anova_test_2_override
  - bar_subclades_3_override
  - dpi_3_override
  - clade_sep_4
  - point_edge_width_4
  - labeled_start_lev_4
  - abrv_stop_lev_4
  - abrv_start_lev_4
  - labeled_stop_lev_4
  - how_many_features_5_override
  - feature_name_5
  - feature_num_5
outputs:
  - formatted_input
  - lefse_result
  - bar_plot
  - cladogram_plot
  - feature_files
```

<!-- IMPORTED_ATOMIC_TOOLS_START -->
## Imported Microbiome Atomic Tools
These atomic workflows were imported from the source RO-Crate workspace. Each entry keeps the original RO-Crate metadata, source WDL path, paired exported input JSON, and cataloged runtime image references.

### `abundancebin`
**Path**: `scripts/abundancebin.wdl`  
**Test Input**: `tests/abundancebin.inputs.json`  
**Source Workspace**: `TOOL_ABUNDANCEBIN` (`TOOL_ABUNDANCEBIN`)  
**Source WDL**: `workflow/tool_abundancebin-copy/default/Tool_AbundanceBin.wdl`  
**Source Input**: `submission/tool_abundancebin-copy-history-2025-08-29-10-48-06/default/input.json`
**Original Metadata**: dataset `td3rletdo4spjhk11j1r0`, author `liuyuanbin`, published `2025-10-21T09:50:35Z`

Tool workspace for abundance binning analysis. It classifies and bins input biological data files by abundance, helping researchers classify microbiome data and analyze abundance profiles.

- Inputs: `input_file`, `bin_num`, `abundancebin.output_dir`, `exclude_count`, `exclude_max`, `recursive_classification`.
- Outputs: `output_dir`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/abundancebin:latest`.

### `dudes`
**Path**: `scripts/dudes.wdl`  
**Test Input**: `tests/dudes.inputs.json`  
**Source Workspace**: `Tool_DUDes` (`Tool_DUDes`)  
**Source WDL**: `workflow/DUDes_Workflow/default/Tool_DUDes.wdl`  
**Source Input**: `submission/DUDes_Workflow-history-2025-09-15-11-21-29/default/input.json`
**Original Metadata**: dataset `td3riikto4spjhk11ho1g`, author `liuyuanbin`, published `2025-10-21T06:33:45Z`

The DUDes workflow runs DUDes.py on input sequencing alignment files and collects the generated result files as workflow outputs. It supports BAM/SAM input and uses the DUDes database for microbial taxonomic annotation.

- Inputs: `sam`, `database`, `threads`.
- Outputs: `DUDes.dudes_outputs`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/dudes:latest`.

### `kaiju`
**Path**: `scripts/kaiju.wdl`  
**Test Input**: `tests/kaiju.inputs.json`  
**Source Workspace**: `Tool_Kaiju` (`Tool_Kaiju`)  
**Source WDL**: `workflow/kaiju/default/Tool_Kaiju.wdl`  
**Source Input**: `submission/kaiju-history-2025-09-05-18-18-56/default/input.json`
**Original Metadata**: dataset `td3vhkmne7hu3grr2guog`, author `liuyuanbin`, published `2025-10-27T07:05:00Z`

The Tool_Kaiju workflow performs metagenomic sequence taxonomic classification with Kaiju. It accepts FASTQ/FASTA input (single-end or paired-end), runs Kaiju for alignment and classification, and exports result files.

- Inputs: `fmi`, `threads`, `minimum_match_score_in_greedy`, `number_of_greedy_mismatches`, `dmp`, `minimum_evalue`, `mode`, `seq2`, `minimum_match_length`, `seq1`, `protein_seq`.
- Outputs: `kaiju.kaiju_output`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/metatools:lite`.

### `picrust`
**Path**: `scripts/picrust.wdl`  
**Test Input**: `tests/picrust.inputs.json`  
**Source Workspace**: `Tool_PICRUSt` (`Tool_PICRUSt`)  
**Source WDL**: `workflow/Tool_PICRUSt-copy/default/Tool_PICRUSt_v1.0.wdl`  
**Source Input**: `submission/Tool_PICRUSt-copy-history-2025-11-20-13-05-01/default/input.json`
**Original Metadata**: dataset `td4fa6kkillb3o00gtrk0`, author `liuyuanbin`, published `2025-11-20T05:11:10Z`

PICRUSt (Phylogenetic Investigation of Communities by Reconstruction of Unobserved States) predicts metagenomic functional composition. Based on 16S rRNA gene sequencing data, it uses phylogenetic information to predict the functional potential of microbial communities, including copy-number correction, functional prediction, functional categorization, and contribution analysis.

- Inputs: `type`, `biom`, `level`, `category`, `limit`.
- Outputs: `ko_predictions`, `metagenome_contributions`, `categorize_by_function`, `report`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/picrust:new`.

### `strainest`
**Path**: `scripts/strainest.wdl`  
**Test Input**: `tests/strainest.inputs.json`  
**Source Workspace**: `Tool_StrainEst` (`Tool_StrainEst`)  
**Source WDL**: `workflow/StrainEst/default/Tool_StrainEst.wdl`  
**Source Input**: `submission/StrainEst-history-2025-09-09-15-49-31/default/input.json`
**Original Metadata**: dataset `td3rq3ldo4spjhk11l610`, author `liuyuanbin`, published `2025-10-21T15:07:50Z`

A workflow collection for estimating strain abundance from the provided alignment results (BAM).

- Inputs: `bam`, `database`.
- Outputs: `strainest_output`.
- Docker images: `registry-vpc.miracle.ac.cn/nmdc/strainest:latest`.

<!-- IMPORTED_ATOMIC_TOOLS_END -->

## Execution Handoff
- Start from `tests/lefse_microbiome_biomarker_analysis.inputs.json` and replace `input_file` with the current workspace abundance table.
- Confirm that the input table already matches LEfSe's expected format, including class/subclass/subject row configuration; if not, the user may need an upstream formatting step before running this workflow.
- If the user asks for upstream microbiome preprocessing, taxonomy profiling, or raw-read analysis, do not force-fit it into this workflow.
