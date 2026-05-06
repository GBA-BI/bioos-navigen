---
name: bioos_early_warning
description: Route prevention, preparedness, and early-warning Bio-OS workflows collected from external GitHub or reproduction repositories. Use this skill for pathogen risk forecasting, lineage deconvolution, immune-trajectory modeling, viral alerting, escape estimation, fitness scoring, and antibody interaction or affinity prediction that should run as Bio-OS WDL workflows.
---

# Bio-OS Early Warning

## Scope
This is the business-layer skill for prevention and early-warning workflows collected from external GitHub repositories, paper-reproduction packages, or other reusable model exports.

- Use this skill when the user is asking for preparedness drills, mutation forecasting, fitness prediction, immune-trajectory analysis, mixed-sample lineage decomposition, or antibody interaction scoring.
- Use this skill for model-style analytical workflows that support pathogen early warning rather than routine sequencing QC, consensus lineage assignment, or standard DNA/RNA variant calling.
- If the request is about observed-sequence QC, Nextclade, Pangolin, viral SNV detection, or metagenomic reconstruction, route to `../bioos_microbiology_pathology/SKILL.md` instead.
- If a new workflow must be authored or a packaged WDL needs major repair, explicitly load the `skills-cli` builder stack rather than editing this business skill first.
- Before changing any runtime image, consult `../bioos_docker_registry_catalog/SKILL.md`.

## Operating Rules
- Keep runnable workflows in `scripts/`.
- Keep packaged input templates in `tests/`.
- Treat this skill as the description and routing layer. Internal task names are implementation details and should not be exposed as user-facing tools.
- Prefer DRS URIs for user-uploaded biological inputs. Workspace object paths are acceptable in chained smoke-test templates exported from Bio-OS workspaces.

## Included Workflows

### 1. `petra_sars_cov2_mutation_prediction`
**Path**: `scripts/petra_sars_cov2_mutation_prediction.wdl`  
**Test Input**: `tests/petra_sars_cov2_mutation_prediction.inputs.json`  
**Query Template**: `tests/petra_query_template.example.json`

Predict likely future SARS-CoV-2 mutations from a structured PETra query JSON.

- Trigger when: the user asks for mutation early warning, future mutation ranking, or candidate mutation prioritization under a specified lineage, location, date, or gene constraint.
- Do not use when: the user wants clade assignment or QC on observed sequences; route to Nextclade or Pangolin in `bioos_microbiology_pathology`.

```yaml
name: petra_sars_cov2_mutation_prediction
description: Run PETra inference for SARS-CoV-2 mutation prediction from a structured query JSON.
required_parameters:
  - query_json
optional_parameters:
  - docker_image
  - memory_gb
  - disk_space_gb
  - cpu_threads
outputs:
  - predictions_json
  - predictions_tsv
```

### 2. `freyja_sars_cov2_lineage_deconvolution`
**Path**: `scripts/freyja_sars_cov2_lineage_deconvolution.wdl`  
**Test Input**: `tests/freyja_sars_cov2_lineage_deconvolution.inputs.json`

Deconvolute mixed SARS-CoV-2 lineage composition from an aligned BAM.

- Trigger when: the user has wastewater or mixed-sample aligned reads and wants lineage proportions rather than a single consensus lineage label.
- Do not use when: the user only has consensus FASTA and needs a single lineage call; route to Pangolin instead.

```yaml
name: freyja_sars_cov2_lineage_deconvolution
description: Estimate mixed lineage composition from SARS-CoV-2 BAM input and summarize demixing results.
required_parameters:
  - bam
  - bam_index
  - reference_fasta
optional_parameters:
  - sample_name
  - reference_name
  - variant_threshold
  - min_base_quality
  - eps
  - coverage_cutoff
  - confirmed_only
  - pathogen
  - barcode_file
  - lineage_meta_file
  - top_n
outputs:
  - variants_tsv
  - depth_tsv
  - demix_tsv
  - barcode_version_txt
  - summary_json
  - summary_tsv
```

### 3. `hiriskpredictor_performance_surveillance`
**Path**: `scripts/hiriskpredictor_performance_surveillance.wdl`  
**Test Input**: `tests/hiriskpredictor_performance_surveillance.inputs.json`

Run the HiRiskPredictor surveillance pipeline to compute features, generate model predictions, and evaluate performance across a time window.

- Trigger when: the user wants surveillance-model reproduction, classifier scoring, or time-window performance tracking for variant risk monitoring.
- Do not use when: the user wants a single-sample lineage or mutation analysis workflow.

```yaml
name: hiriskpredictor_performance_surveillance
description: Reproduce a surveillance-oriented HiRiskPredictor workflow including feature generation, model inference, and performance evaluation.
required_parameters:
  - samples
  - alias_file
  - who_labels
  - selected_feature_ml_file
  - start_date
  - end_date
  - output_dir
optional_parameters:
  - interval_days
  - nprocesses
  - nrows
  - new_system
  - docker_image
  - performance_start_date
outputs:
  - features_log
  - y_scores
  - y_preds
  - classifiers
  - roc_pdfs
  - performance_metrics
```

### 4. `population_immunity_sars_cov2_analysis`
**Path**: `scripts/population_immunity_sars_cov2_analysis.wdl`  
**Test Input**: `tests/population_immunity_sars_cov2_analysis.inputs.json`

Reproduce a packaged SARS-CoV-2 population immunity analysis and emit immune-trajectory artifacts plus figures.

- Trigger when: the user wants immune escape or population-immunity trajectory reproduction rather than per-sample sequence analysis.
- Do not use when: the user expects FASTA, BAM, or VCF-driven per-sample processing.

```yaml
name: population_immunity_sars_cov2_analysis
description: Run the packaged population-immunity analysis workflow and emit derived trajectories, selection tables, and figures.
required_parameters: []
optional_parameters:
  - docker_image
outputs:
  - data_immune_trajectories
  - selection_potentials
  - selection_potentials_average
  - R_average
  - R_average_may
  - Update_gamma_inf
  - Average_Frequencies
  - figures
```

### 5. `viruswarn_sars_cov2_alerting`
**Path**: `scripts/viruswarn_sars_cov2_alerting.wdl`  
**Test Input**: `tests/viruswarn_sars_cov2_alerting.inputs.json`

Run the VirusWarn SARS-CoV-2 alerting workflow to generate report-style warning outputs.

- Trigger when: the user wants SARS-CoV-2 alert reports, warning-style summaries, or rehearsal runs of the VirusWarn SC2 pipeline.
- Do not use when: the user wants strict lineage calling or Nextclade-style QC outputs.

```yaml
name: viruswarn_sars_cov2_alerting
description: Run the VirusWarn SARS-CoV-2 pipeline and emit report-oriented alerting outputs.
required_parameters: []
optional_parameters:
  - input_fasta
  - metadata_file
  - docker_image
  - memory_gb
  - cpu_threads
  - disk_space_gb
outputs:
  - report_html
  - report_csvs
  - nextflow_log
```

### 6. `viruswarn_flu_alerting`
**Path**: `scripts/viruswarn_flu_alerting.wdl`  
**Test Input**: `tests/viruswarn_flu_alerting.inputs.json`

Run the VirusWarn influenza alerting workflow to generate report-style warning outputs.

- Trigger when: the user wants influenza preparedness or early-warning reporting based on Flu FASTA and optional metadata.
- Do not use when: the user wants generic metagenomic analysis or a standard influenza variant-calling pipeline.

```yaml
name: viruswarn_flu_alerting
description: Run the VirusWarn influenza pipeline and emit alerting reports plus derived CSV outputs.
required_parameters: []
optional_parameters:
  - input_fasta
  - metadata_file
  - docker_image
  - memory_gb
  - cpu_threads
  - disk_space_gb
outputs:
  - report_html
  - all_htmls
  - report_csvs
  - nextflow_log
```

### 7. `spikepro_sars_cov2_fitness_prediction`
**Path**: `scripts/spikepro_sars_cov2_fitness_prediction.wdl`  
**Test Input**: `tests/spikepro_sars_cov2_fitness_prediction.inputs.json`

Predict SARS-CoV-2 spike fitness characteristics from FASTA input.

- Trigger when: the user wants sequence-based SARS-CoV-2 fitness scoring or a packaged SpikePro reproduction run.
- Do not use when: the user wants structure prediction or antibody binding-site modeling instead of viral fitness estimation.

```yaml
name: spikepro_sars_cov2_fitness_prediction
description: Run SpikePro on SARS-CoV-2 FASTA input and emit a text report summarizing predicted fitness-related results.
required_parameters:
  - query_fasta
optional_parameters:
  - sample_name
outputs:
  - report_txt
```

### 8. `covfit_sars_cov2_fitness_prediction`
**Path**: `scripts/covfit_sars_cov2_fitness_prediction.wdl`  
**Test Input**: `tests/covfit_sars_cov2_fitness_prediction.inputs.json`

Run CoVFit to predict SARS-CoV-2 spike fitness and optionally DMS-style outputs from FASTA input.

- Trigger when: the user wants an alternative fitness-prediction model with configurable fold, batch size, and optional DMS output.
- Do not use when: the request is for lineage assignment, waste-water deconvolution, or raw sequencing analysis.

```yaml
name: covfit_sars_cov2_fitness_prediction
description: Run CoVFit on SARS-CoV-2 FASTA input and emit predicted fitness tables plus optional DMS output.
required_parameters:
  - input_fasta
  - sample_name
optional_parameters:
  - fold_number
  - run_dms
  - batch_size
  - use_gpu
  - docker_image
  - memory_gb
  - disk_space_gb
  - cpu_threads
outputs:
  - predictions_tsv
  - dms_results_tsv
  - summary_stats
```

### 9. `sars2_rbd_escape_inference`
**Path**: `scripts/sars2_rbd_escape_inference.wdl`  
**Test Input**: `tests/sars2_rbd_escape_inference.inputs.json`

Run the lightweight RBD escape inference workflow from a structured query JSON.

- Trigger when: the user already has a mutation/query JSON and wants resolved mutation output plus escape summaries.
- Do not use when: the user has a bulk tabular input file and wants the more complete packaged escape-analysis workflow.

```yaml
name: sars2_rbd_escape_inference
description: Run SARS-CoV-2 RBD escape inference from a structured query JSON and emit summary plus per-site outputs.
required_parameters:
  - query_json
outputs:
  - escape_summary
  - escape_per_site
  - resolved_mutations
```

### 10. `sars2_rbd_escape_complete_analysis`
**Path**: `scripts/sars2_rbd_escape_complete_analysis.wdl`  
**Test Input**: `tests/sars2_rbd_escape_complete_analysis.inputs.json`

Run the packaged complete RBD escape analysis workflow from a file of queries or mutations.

- Trigger when: the user wants a fuller escape-analysis batch workflow with auto-detected input format and richer tabular outputs.
- Do not use when: the user only needs single-query JSON inference; use `sars2_rbd_escape_inference`.

```yaml
name: sars2_rbd_escape_complete_analysis
description: Run the complete SARS-CoV-2 RBD escape workflow and emit summary, per-site, and resolved-query outputs.
required_parameters:
  - input_data
optional_parameters:
  - input_format
outputs:
  - escape_summary_csv
  - escape_summary_json
  - escape_per_site_csv
  - resolved_queries_json
```

### 11. `abaffinity_antibody_affinity_prediction`
**Path**: `scripts/abaffinity_antibody_affinity_prediction.wdl`  
**Test Input**: `tests/abaffinity_antibody_affinity_prediction.inputs.json`

Predict antibody affinity-related scores from a normalized antibody input CSV.

- Trigger when: the user wants antibody scoring on a batch CSV prepared for the AbAffinity model.
- Do not use when: the user wants protein 3D structure prediction or a general-purpose antibody-antigen interaction model.

```yaml
name: abaffinity_antibody_affinity_prediction
description: Run AbAffinity on an antibody input table and emit prediction and summary outputs.
required_parameters:
  - antibody_input_csv
optional_parameters:
  - output_prefix
  - batch_size
outputs:
  - predictions_csv
  - summary_json
  - normalized_input_csv
```

### 12. `proabc2_antibody_contact_prediction`
**Path**: `scripts/proabc2_antibody_contact_prediction.wdl`  
**Test Input**: `tests/proabc2_antibody_contact_prediction.inputs.json`

Predict antibody contact propensities from heavy- and light-chain FASTA input.

- Trigger when: the user wants antibody contact-site prediction from paired heavy/light chain sequences.
- Do not use when: the user wants antigen interaction probability, not residue-level contact prediction.

```yaml
name: proabc2_antibody_contact_prediction
description: Run ProABC-2 on paired antibody chain FASTA inputs and emit heavy/light contact prediction tables.
required_parameters:
  - heavy_fasta
  - light_fasta
optional_parameters:
  - output_prefix
outputs:
  - heavy_prediction_csv
  - light_prediction_csv
  - stdout_log
  - stderr_log
```

### 13. `rleaai_antibody_antigen_interaction_prediction`
**Path**: `scripts/rleaai_antibody_antigen_interaction_prediction.wdl`  
**Test Input**: `tests/rleaai_antibody_antigen_interaction_prediction.inputs.json`

Run the RLEAAI model to score antibody-antigen interaction probability.

- Trigger when: the user wants an antibody-antigen interaction model and can provide antibody and antigen FASTA sequences, or wants to reproduce the packaged demo.
- Do not use when: the user needs residue contact maps or affinity-scoring from a CSV batch format.

```yaml
name: rleaai_antibody_antigen_interaction_prediction
description: Run RLEAAI for antibody-antigen interaction prediction and emit prediction artifacts and logs.
required_parameters: []
optional_parameters:
  - antibody_fasta
  - antigen_fasta
  - virus
  - docker_image
  - memory_gb
  - cpu_threads
  - disk_space_gb
outputs:
  - predictions
  - output_logs
```

<!-- IMPORTED_ATOMIC_TOOLS_START -->
## Imported Early-Warning Atomic Tools
These atomic workflows were imported from the source RO-Crate workspace. Each entry keeps the original RO-Crate metadata, source WDL path, paired exported input JSON, and cataloged runtime image references.

<!-- IMPORTED_ATOMIC_TOOLS_END -->

## Execution Handoff
- Start from the matching file under `tests/` and replace packaged demo inputs with the current workspace files before submission.
- For PETra, use `tests/petra_query_template.example.json` to author the query payload, then update `query_json` in `tests/petra_sars_cov2_mutation_prediction.inputs.json`.
- For `viruswarn_*`, `population_immunity_sars_cov2_analysis`, and `rleaai_antibody_antigen_interaction_prediction`, the packaged templates may run with bundled demo data. For production use, replace the optional defaults with uploaded workspace inputs whenever available.
- If the user is unsure between early-warning models and routine pathogen workflows, prefer this skill for forecasting, alerting, immune modeling, or antibody-model tasks, and prefer `bioos_microbiology_pathology` for observed-sequence QC, lineage assignment, viral SNV calling, or MAG reconstruction.
