---
name: bioos_early_warning
description: Route prevention, preparedness, and early-warning Bio-OS workflows
  collected from external GitHub or reproduction repositories. Use this skill
  for pathogen risk forecasting, lineage deconvolution, immune-trajectory
  modeling, viral alerting, escape estimation, fitness scoring, and antibody
  interaction or affinity prediction that should run as Bio-OS WDL workflows.
disable: false
---

# Bio-OS Early Warning

## Scope
This is the business-layer skill for prevention and early-warning workflows collected from external GitHub repositories, paper-reproduction packages, or other reusable model exports.

- Use this skill when the user is asking for preparedness drills, mutation forecasting, fitness prediction, immune-trajectory analysis, mixed-sample lineage decomposition, or antibody interaction scoring.
- Use this skill for model-style analytical workflows that support pathogen early warning rather than routine sequencing QC, consensus lineage assignment, or standard DNA/RNA variant calling.
- If the request is about observed-sequence QC, Nextclade, Pangolin, viral SNV detection, or metagenomic reconstruction, route to the `bioos_microbiology_pathology` skill instead.
- If a new workflow must be authored, hand off to the `bioos_pipeline_developer` skill rather than editing this business skill first.
- If a packaged WDL needs major repair, hand off to the `bioos_wdl_scripter` skill rather than editing this business skill first.
- Before changing any runtime image, consult the `bioos_docker_registry_catalog` skill.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Use workflow names below as the user-facing routing units; internal task names are implementation details.
- For WDL `File` inputs, use the `bioos_platform_operator` skill and follow its file-input instructions.

## Included Workflows

### `petra_sars_cov2_mutation_prediction`
**Path**: `scripts/petra_sars_cov2_mutation_prediction.wdl`
**Test Input**: `tests/petra_sars_cov2_mutation_prediction.inputs.json`

Predict likely future SARS-CoV-2 mutations from a structured PETra query JSON.

- Trigger when: the user asks for mutation early warning, future mutation ranking, or candidate mutation prioritization under a specified lineage, location, date, or gene constraint.
- Required parameters: `query_json`.
- Optional parameters: `docker_image`, `memory_gb`, `disk_space_gb`, `cpu_threads`.
- Outputs: `predictions_json` and `predictions_tsv`.

### `freyja_sars_cov2_lineage_deconvolution`
**Path**: `scripts/freyja_sars_cov2_lineage_deconvolution.wdl`
**Test Input**: `tests/freyja_sars_cov2_lineage_deconvolution.inputs.json`

Deconvolute mixed SARS-CoV-2 lineage composition from an aligned BAM.

- Trigger when: the user has wastewater or mixed-sample aligned reads and wants lineage proportions rather than a single consensus lineage label.
- Required parameters: `bam`, `bam_index`, `reference_fasta`.
- Optional parameters: `sample_name`, `reference_name`, `variant_threshold`, `min_base_quality`, `eps`, `coverage_cutoff`, `confirmed_only`, `pathogen`, `barcode_file`, `lineage_meta_file`, `top_n`.
- Outputs: `variants_tsv`, `depth_tsv`, `demix_tsv`, `barcode_version_txt`, `summary_json`, and `summary_tsv`.

### `hiriskpredictor_performance_surveillance`
**Path**: `scripts/hiriskpredictor_performance_surveillance.wdl`
**Test Input**: `tests/hiriskpredictor_performance_surveillance.inputs.json`

Run the HiRiskPredictor surveillance pipeline to compute features, generate model predictions, and evaluate performance across a time window.

- Trigger when: the user wants surveillance-model reproduction, classifier scoring, or time-window performance tracking for variant risk monitoring.
- Required parameters: `samples`, `alias_file`, `who_labels`, `selected_feature_ml_file`, `start_date`, `end_date`, `output_dir`.
- Optional parameters: `interval_days`, `nprocesses`, `nrows`, `new_system`, `docker_image`, `performance_start_date`.
- Outputs: `features_log`, `y_scores`, `y_preds`, `classifiers`, `roc_pdfs`, and `performance_metrics`.

### `population_immunity_sars_cov2_analysis`
**Path**: `scripts/population_immunity_sars_cov2_analysis.wdl`
**Test Input**: `tests/population_immunity_sars_cov2_analysis.inputs.json`

Reproduce a packaged SARS-CoV-2 population immunity analysis and emit immune-trajectory artifacts plus figures.

- Trigger when: the user wants immune escape or population-immunity trajectory reproduction rather than per-sample sequence analysis.
- Required parameters: none.
- Optional parameters: `docker_image`.
- Outputs: `data_immune_trajectories`, `selection_potentials`, `selection_potentials_average`, `R_average`, `R_average_may`, `Update_gamma_inf`, `Average_Frequencies`, and `figures`.

### `viruswarn_sars_cov2_alerting`
**Path**: `scripts/viruswarn_sars_cov2_alerting.wdl`
**Test Input**: `tests/viruswarn_sars_cov2_alerting.inputs.json`

Run the VirusWarn SARS-CoV-2 alerting workflow to generate report-style warning outputs.

- Trigger when: the user wants SARS-CoV-2 alert reports, warning-style summaries, or rehearsal runs of the VirusWarn SC2 pipeline.
- Required parameters: none.
- Optional parameters: `input_fasta`, `metadata_file`, `docker_image`, `memory_gb`, `cpu_threads`, `disk_space_gb`.
- Outputs: `report_html`, `report_csvs`, and `nextflow_log`.

### `viruswarn_flu_alerting`
**Path**: `scripts/viruswarn_flu_alerting.wdl`
**Test Input**: `tests/viruswarn_flu_alerting.inputs.json`

Run the VirusWarn influenza alerting workflow to generate report-style warning outputs.

- Trigger when: the user wants influenza preparedness or early-warning reporting based on Flu FASTA and optional metadata.
- Required parameters: none.
- Optional parameters: `input_fasta`, `metadata_file`, `docker_image`, `memory_gb`, `cpu_threads`, `disk_space_gb`.
- Outputs: `report_html`, `all_htmls`, `report_csvs`, and `nextflow_log`.

### `spikepro_sars_cov2_fitness_prediction`
**Path**: `scripts/spikepro_sars_cov2_fitness_prediction.wdl`
**Test Input**: `tests/spikepro_sars_cov2_fitness_prediction.inputs.json`

Predict SARS-CoV-2 spike fitness characteristics from FASTA input.

- Trigger when: the user wants sequence-based SARS-CoV-2 fitness scoring or a packaged SpikePro reproduction run.
- Required parameters: `query_fasta`.
- Optional parameters: `sample_name`.
- Outputs: `report_txt`.

### `covfit_sars_cov2_fitness_prediction`
**Path**: `scripts/covfit_sars_cov2_fitness_prediction.wdl`
**Test Input**: `tests/covfit_sars_cov2_fitness_prediction.inputs.json`

Run CoVFit to predict SARS-CoV-2 spike fitness and optionally DMS-style outputs from FASTA input.

- Trigger when: the user wants an alternative fitness-prediction model with configurable fold, batch size, and optional DMS output.
- Required parameters: `input_fasta`, `sample_name`.
- Optional parameters: `fold_number`, `run_dms`, `batch_size`, `use_gpu`, `docker_image`, `memory_gb`, `disk_space_gb`, `cpu_threads`.
- Outputs: `predictions_tsv`, `dms_results_tsv`, and `summary_stats`.

### `sars2_rbd_escape_inference`
**Path**: `scripts/sars2_rbd_escape_inference.wdl`
**Test Input**: `tests/sars2_rbd_escape_inference.inputs.json`

Run the lightweight RBD escape inference workflow from a structured query JSON.

- Trigger when: the user already has a mutation/query JSON and wants resolved mutation output plus escape summaries.
- Required parameters: `query_json`.
- Optional parameters: none documented.
- Outputs: `escape_summary`, `escape_per_site`, and `resolved_mutations`.

### `sars2_rbd_escape_complete_analysis`
**Path**: `scripts/sars2_rbd_escape_complete_analysis.wdl`
**Test Input**: `tests/sars2_rbd_escape_complete_analysis.inputs.json`

Run the packaged complete RBD escape analysis workflow from a file of queries or mutations.

- Trigger when: the user wants a fuller escape-analysis batch workflow with auto-detected input format and richer tabular outputs.
- Required parameters: `input_data`.
- Optional parameters: `input_format`.
- Outputs: `escape_summary_csv`, `escape_summary_json`, `escape_per_site_csv`, and `resolved_queries_json`.

### `abaffinity_antibody_affinity_prediction`
**Path**: `scripts/abaffinity_antibody_affinity_prediction.wdl`
**Test Input**: `tests/abaffinity_antibody_affinity_prediction.inputs.json`

Predict antibody affinity-related scores from a normalized antibody input CSV.

- Trigger when: the user wants antibody scoring on a batch CSV prepared for the AbAffinity model.
- Required parameters: `antibody_input_csv`.
- Optional parameters: `output_prefix`, `batch_size`.
- Outputs: `predictions_csv`, `summary_json`, and `normalized_input_csv`.

### `proabc2_antibody_contact_prediction`
**Path**: `scripts/proabc2_antibody_contact_prediction.wdl`
**Test Input**: `tests/proabc2_antibody_contact_prediction.inputs.json`

Predict antibody contact propensities from heavy- and light-chain FASTA input.

- Trigger when: the user wants antibody contact-site prediction from paired heavy/light chain sequences.
- Required parameters: `heavy_fasta`, `light_fasta`.
- Optional parameters: `output_prefix`.
- Outputs: `heavy_prediction_csv`, `light_prediction_csv`, `stdout_log`, and `stderr_log`.

### `rleaai_antibody_antigen_interaction_prediction`
**Path**: `scripts/rleaai_antibody_antigen_interaction_prediction.wdl`
**Test Input**: `tests/rleaai_antibody_antigen_interaction_prediction.inputs.json`

Run the RLEAAI model to score antibody-antigen interaction probability.

- Trigger when: the user wants an antibody-antigen interaction model and can provide antibody and antigen FASTA sequences, or wants to reproduce the packaged demo.
- Required parameters: none.
- Optional parameters: `antibody_fasta`, `antigen_fasta`, `virus`, `docker_image`, `memory_gb`, `cpu_threads`, `disk_space_gb`.
- Outputs: `predictions` and `output_logs`.

## Execution Handoff
- Start from the matching `tests/*.inputs.json` template and use the `bioos_platform_operator` skill for file inputs and workflow submission.
- For PETra, use `tests/petra_query_template.example.json` to author the query payload, then update `query_json` in `tests/petra_sars_cov2_mutation_prediction.inputs.json`.
- For `viruswarn_*`, `population_immunity_sars_cov2_analysis`, and `rleaai_antibody_antigen_interaction_prediction`, the packaged templates may run with bundled demo data. For production use, replace the optional defaults with uploaded workspace inputs whenever available.
- If the user is unsure between early-warning models and routine pathogen workflows, prefer this skill for forecasting, alerting, immune modeling, or antibody-model tasks, and prefer `bioos_microbiology_pathology` for observed-sequence QC, lineage assignment, viral SNV calling, or MAG reconstruction.
