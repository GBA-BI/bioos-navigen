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
disable: false
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
- Use workflow names below as the user-facing routing units; internal task names are implementation details.
- For WDL `File` inputs, use the `bioos_platform_operator` skill and follow its file-input instructions.

## Included Workflows

### `lefse_microbiome_biomarker_analysis`
**Path**: `scripts/lefse_microbiome_biomarker_analysis.wdl`
**Test Input**: `tests/lefse_microbiome_biomarker_analysis.inputs.json`

Run LEfSe on a formatted microbiome abundance table to identify class-associated biomarkers and generate effect-size visualizations.

- Trigger when: the user wants LEfSe biomarker discovery, class-vs-subclass microbial community comparison, or publication-style bar/cladogram outputs from a microbiome feature table.
- Required parameters: `input_file`.
- Optional parameters: `whether_features_1_override`, `row_subject_1_override`, `row_subclass_1_override`, `row_class_1_override`, `normalization_value_1_override`, `stratege_muti_class_2_override`, `one_against_one_2_override`, `Wilcoxon_test_2_override`, `threshold_absolute_value_2_override`, `same_name_2_override`, `Anova_test_2_override`, `bar_subclades_3_override`, `dpi_3_override`, `clade_sep_4`, `point_edge_width_4`, `labeled_start_lev_4`, `abrv_stop_lev_4`, `abrv_start_lev_4`, `labeled_stop_lev_4`, `how_many_features_5_override`, `feature_name_5`, `feature_num_5`.
- Outputs: `formatted_input`, `lefse_result`, `bar_plot`, `cladogram_plot`, and `feature_files`.

### `abundancebin`
**Path**: `scripts/abundancebin.wdl`
**Test Input**: `tests/abundancebin.inputs.json`

Tool workspace for abundance binning analysis. It classifies and bins input biological data files by abundance, helping researchers classify microbiome data and analyze abundance profiles.

- Trigger when: the user asks for `abundancebin` or the described workflow capability.
- Required parameters: `input_file`, `bin_num`, `abundancebin.output_dir`, `exclude_count`, `exclude_max`, `recursive_classification`.
- Optional parameters: none documented.
- Outputs: `output_dir`.

### `dudes`
**Path**: `scripts/dudes.wdl`
**Test Input**: `tests/dudes.inputs.json`

The DUDes workflow runs DUDes.py on input sequencing alignment files and collects the generated result files as workflow outputs. It supports BAM/SAM input and uses the DUDes database for microbial taxonomic annotation.

- Trigger when: the user asks for `dudes` or the described workflow capability.
- Required parameters: `sam`, `database`, `threads`.
- Optional parameters: none documented.
- Outputs: `DUDes.dudes_outputs`.

### `kaiju`
**Path**: `scripts/kaiju.wdl`
**Test Input**: `tests/kaiju.inputs.json`

The Tool_Kaiju workflow performs metagenomic sequence taxonomic classification with Kaiju. It accepts FASTQ/FASTA input (single-end or paired-end), runs Kaiju for alignment and classification, and exports result files.

- Trigger when: the user asks for `kaiju` or the described workflow capability.
- Required parameters: `fmi`, `threads`, `minimum_match_score_in_greedy`, `number_of_greedy_mismatches`, `dmp`, `minimum_evalue`, `mode`, `seq2`, `minimum_match_length`, `seq1`, `protein_seq`.
- Optional parameters: none documented.
- Outputs: `kaiju.kaiju_output`.

### `picrust`
**Path**: `scripts/picrust.wdl`
**Test Input**: `tests/picrust.inputs.json`

PICRUSt (Phylogenetic Investigation of Communities by Reconstruction of Unobserved States) predicts metagenomic functional composition. Based on 16S rRNA gene sequencing data, it uses phylogenetic information to predict the functional potential of microbial communities, including copy-number correction, functional prediction, functional categorization, and contribution analysis.

- Trigger when: the user asks for `picrust` or the described workflow capability.
- Required parameters: `type`, `biom`, `level`, `category`, `limit`.
- Optional parameters: none documented.
- Outputs: `ko_predictions`, `metagenome_contributions`, `categorize_by_function`, `report`.

### `strainest`
**Path**: `scripts/strainest.wdl`
**Test Input**: `tests/strainest.inputs.json`

A workflow collection for estimating strain abundance from the provided alignment results (BAM).

- Trigger when: the user asks for `strainest` or the described workflow capability.
- Required parameters: `bam`, `database`.
- Optional parameters: none documented.
- Outputs: `strainest_output`.

## Execution Handoff
- Start from the matching `tests/*.inputs.json` template and use the `bioos_platform_operator` skill for file inputs and workflow submission.
- For LEfSe, use `tests/lefse_microbiome_biomarker_analysis.inputs.json` and replace `input_file` with the current workspace abundance table.
- Confirm that the input table already matches LEfSe's expected format, including class/subclass/subject row configuration; if not, the user may need an upstream formatting step before running this workflow.
- If the user asks for upstream microbiome preprocessing, taxonomy profiling, or raw-read analysis, do not force-fit it into this workflow.
