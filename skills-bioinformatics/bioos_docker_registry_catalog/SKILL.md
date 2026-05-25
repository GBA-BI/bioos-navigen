---
name: bioos_docker_registry_catalog
description: Reference catalog of Bio-OS workflow container images. Use this
  skill to look up standard linux/amd64 images before changing workflow runtime
  blocks or deciding whether a new image must be built.
disable: true
---

# Bio-OS Docker Registry Catalog

## Scope
This catalog records the default container images referenced by the current Bio-OS business-layer workflows.

## Operating Rules
- Prefer an existing cataloged image before building a new one.
- When a workflow uses multiple task-specific images, consult the WDL runtime blocks and keep the catalog synchronized with the main task chain.
- If an image is replaced or version-bumped, update this file together with the consuming WDL.

## Catalog

| Image | Arch | Referenced By | Purpose |
| --- | --- | --- | --- |
| `registry-vpc.miracle.ac.cn/broad/gtex-rnaseq:V10` | `linux/amd64` | `bulk_rnaseq_quantification.wdl` | GTEx-style bulk RNA-seq alignment, RNA-SeQC2 metrics, and RSEM quantification. |
| `registry-vpc.miracle.ac.cn/auto-build/nextclade-dataset-prep:20260313-v1` | `linux/amd64` | `nextclade_sars_cov2_s_protein.wdl`, `nextclade_general_pathogen_analysis.wdl` | Nextclade SARS-CoV-2 S protein extraction and general pathogen analysis. |
| `registry-vpc.miracle.ac.cn/auto-build/pangolin-sarscov2:20260312-v1` | `linux/amd64` | `pangolin_sars_cov2_lineage_assignment.wdl` | Pangolin lineage assignment for SARS-CoV-2 consensus genomes. |
| `registry-vpc.miracle.ac.cn/auto-build/petra-cpu-paper2workspace:20260316` | `linux/amd64` | `petra_sars_cov2_mutation_prediction.wdl` | PETra CPU inference for SARS-CoV-2 mutation early warning. |
| `registry-vpc.miracle.ac.cn/auto-build/abaffinity-p2w:20260313-v1` | `linux/amd64` | `abaffinity_antibody_affinity_prediction.wdl` | AbAffinity batch antibody-affinity prediction from CSV input. |
| `registry-vpc.miracle.ac.cn/gznl/covfit:v1.0` | `linux/amd64` | `covfit_sars_cov2_fitness_prediction.wdl` | CoVFit SARS-CoV-2 fitness prediction and optional DMS-style scoring. |
| `registry-vpc.miracle.ac.cn/auto-build/freyja-paper2workspace:20260316-2` | `linux/amd64` | `freyja_sars_cov2_lineage_deconvolution.wdl` | Freyja lineage deconvolution from mixed SARS-CoV-2 BAM input. |
| `registry-vpc.miracle.ac.cn/auto-build/hiriskpredictor-wf:v0.3` | `linux/amd64` | `hiriskpredictor_performance_surveillance.wdl` | HiRiskPredictor surveillance feature generation, model inference, and performance evaluation. |
| `registry-vpc.miracle.ac.cn/gznl/population-immunity-wf:latest` | `linux/amd64` | `population_immunity_sars_cov2_analysis.wdl` | Packaged SARS-CoV-2 population-immunity trajectory analysis. |
| `registry-vpc.miracle.ac.cn/gznl/proabc-2:latest` | `linux/amd64` | `proabc2_antibody_contact_prediction.wdl` | ProABC-2 antibody contact prediction from heavy/light chain FASTA input. |
| `registry-vpc.miracle.ac.cn/auto-build/rleaai:v1.0` | `linux/amd64` | `rleaai_antibody_antigen_interaction_prediction.wdl` | RLEAAI antibody-antigen interaction prediction. |
| `registry-vpc.miracle.ac.cn/auto-build/sars2-rbd-escape-calc:v2` | `linux/amd64` | `sars2_rbd_escape_complete_analysis.wdl` | Complete SARS-CoV-2 RBD escape analysis workflow. |
| `registry-vpc.miracle.ac.cn/auto-build/sars2-rbd-escape-calc-workflow:p2w-20260312-143817` | `linux/amd64` | `sars2_rbd_escape_inference.wdl` | Lightweight SARS-CoV-2 RBD escape inference from structured query JSON. |
| `registry-vpc.miracle.ac.cn/auto-build/spikepro-sars2-p2w:20260312-wdl-v1` | `linux/amd64` | `spikepro_sars_cov2_fitness_prediction.wdl` | SpikePro SARS-CoV-2 spike fitness prediction. |
| `registry-vpc.miracle.ac.cn/auto-build/viruswarn-repro:v0.2` | `linux/amd64` | `viruswarn_sars_cov2_alerting.wdl`, `viruswarn_flu_alerting.wdl` | VirusWarn report-style early-warning workflows for SARS-CoV-2 and influenza. |
| `registry-vpc.miracle.ac.cn/nmdc/abundancebin:latest` | `linux/amd64` | `bioos_microbiome/scripts/abundancebin.wdl` | Imported atomic workflows: `abundancebin`. |
| `registry-vpc.miracle.ac.cn/nmdc/assembletool:latest` | `linux/amd64` | `bioos_genomics/scripts/blasr.wdl`, `bioos_genomics/scripts/spades.wdl`, `bioos_microbiology_pathology/scripts/raymeta.wdl` | Imported atomic workflows: `blasr`, `spades`, `raymeta`. |
| `registry-vpc.miracle.ac.cn/nmdc/ballgown:new` | `linux/amd64` | `bioos_transcriptomics/scripts/ballgown.wdl` | Imported atomic workflows: `ballgown`. |
| `registry-vpc.miracle.ac.cn/nmdc/bwa:latest` | `linux/amd64` | `bioos_genomics/scripts/bwa_aln.wdl`, `bioos_genomics/scripts/bwa_mem.wdl`, `bioos_genomics/scripts/bwa_sw.wdl` | Imported atomic workflows: `bwa_aln`, `bwa_mem`, `bwa_sw`. |
| `registry-vpc.miracle.ac.cn/nmdc/cap3:latest` | `linux/amd64` | `bioos_genomics/scripts/cap3.wdl` | Imported atomic workflows: `cap3`. |
| `registry-vpc.miracle.ac.cn/nmdc/cdhit:4.7-1` | `linux/amd64` | `bioos_genomics/scripts/cd_hit.wdl` | Imported atomic workflows: `cd_hit`. |
| `registry-vpc.miracle.ac.cn/nmdc/checkm:1.1.3` | `linux/amd64` | `bioos_microbiology_pathology/scripts/checkm.wdl` | Imported atomic workflows: `checkm`. |
| `registry-vpc.miracle.ac.cn/nmdc/deseq2:new` | `linux/amd64` | `bioos_transcriptomics/scripts/deseq2.wdl` | Imported atomic workflows: `deseq2`. |
| `registry-vpc.miracle.ac.cn/nmdc/dfast_core:1.2.6` | `linux/amd64` | `bioos_microbiology_pathology/scripts/dfast.wdl` | Imported atomic workflows: `dfast`. |
| `registry-vpc.miracle.ac.cn/nmdc/diamond:latest` | `linux/amd64` | `bioos_proteomics/scripts/diamond.wdl` | Imported atomic workflows: `diamond`. |
| `registry-vpc.miracle.ac.cn/nmdc/dudes:latest` | `linux/amd64` | `bioos_microbiome/scripts/dudes.wdl` | Imported atomic workflows: `dudes`. |
| `registry-vpc.miracle.ac.cn/nmdc/glimmer3:latest` | `linux/amd64` | `bioos_microbiology_pathology/scripts/glimmer.wdl` | Imported atomic workflows: `glimmer`. |
| `registry-vpc.miracle.ac.cn/nmdc/kallisto:latest` | `linux/amd64` | `bioos_transcriptomics/scripts/kallisto.wdl` | Imported atomic workflows: `kallisto`. |
| `registry-vpc.miracle.ac.cn/nmdc/lumpy:latest` | `linux/amd64` | `bioos_genomics/scripts/lumpy.wdl` | Imported atomic workflows: `lumpy`. |
| `registry-vpc.miracle.ac.cn/nmdc/metabat2:2.15--c1941c7` | `linux/amd64` | `bioos_microbiology_pathology/scripts/metabat2.wdl` | Imported atomic workflows: `metabat2`. |
| `registry-vpc.miracle.ac.cn/nmdc/metatools:lite` | `linux/amd64` | `bioos_genomics/scripts/blat.wdl`, `bioos_genomics/scripts/quast.wdl`, `bioos_genomics/scripts/reapr.wdl`, `bioos_microbiology_pathology/scripts/fraggenescan.wdl`, `bioos_microbiology_pathology/scripts/piler_cr.wdl`, `bioos_microbiology_pathology/scripts/prodigal.wdl`, `bioos_microbiome/scripts/kaiju.wdl` | Imported atomic workflows: `blat`, `quast`, `reapr`, `fraggenescan`, `piler_cr`, `prodigal`, `kaiju`. |
| `registry-vpc.miracle.ac.cn/nmdc/minced:latest` | `linux/amd64` | `bioos_microbiology_pathology/scripts/minced.wdl` | Imported atomic workflows: `minced`. |
| `registry-vpc.miracle.ac.cn/nmdc/mrna:latest` | `linux/amd64` | `bioos_transcriptomics/scripts/cuffdiff.wdl`, `bioos_transcriptomics/scripts/cufflinks.wdl`, `bioos_transcriptomics/scripts/hisat2.wdl`, `bioos_transcriptomics/scripts/stringtie.wdl` | Imported atomic workflows: `cuffdiff`, `cufflinks`, `hisat2`, `stringtie`. |
| `registry-vpc.miracle.ac.cn/nmdc/mummer3:v1` | `linux/amd64` | `bioos_genomics/scripts/mummer.wdl` | Imported atomic workflows: `mummer`. |
| `registry-vpc.miracle.ac.cn/nmdc/oases:latest` | `linux/amd64` | `bioos_transcriptomics/scripts/oases.wdl` | Imported atomic workflows: `oases`. |
| `registry-vpc.miracle.ac.cn/nmdc/opera:latest` | `linux/amd64` | `bioos_genomics/scripts/opera.wdl` | Imported atomic workflows: `opera`. |
| `registry-vpc.miracle.ac.cn/nmdc/orthoani:latest` | `linux/amd64` | `bioos_microbiology_pathology/scripts/orthoani.wdl` | Imported atomic workflows: `orthoani`. |
| `registry-vpc.miracle.ac.cn/nmdc/picrust:new` | `linux/amd64` | `bioos_microbiome/scripts/picrust.wdl` | Imported atomic workflows: `picrust`. |
| `registry-vpc.miracle.ac.cn/nmdc/prism:latest` | `linux/amd64` | `bioos_genomics/scripts/prism.wdl` | Imported atomic workflows: `prism`. |
| `registry-vpc.miracle.ac.cn/nmdc/prokka:latest` | `linux/amd64` | `bioos_microbiology_pathology/scripts/prokka.wdl` | Imported atomic workflows: `prokka`. |
| `registry-vpc.miracle.ac.cn/nmdc/rgi:6.0.3` | `linux/amd64` | `bioos_microbiology_pathology/scripts/rgi.wdl` | Imported atomic workflows: `rgi`. |
| `registry-vpc.miracle.ac.cn/nmdc/rnammer:v1.2` | `linux/amd64` | `bioos_microbiology_pathology/scripts/rnammer.wdl` | Imported atomic workflows: `rnammer`. |
| `registry-vpc.miracle.ac.cn/nmdc/sailfish:latest` | `linux/amd64` | `bioos_transcriptomics/scripts/sailfish.wdl` | Imported atomic workflows: `sailfish`. |
| `registry-vpc.miracle.ac.cn/nmdc/sspace:v1` | `linux/amd64` | `bioos_genomics/scripts/sspace.wdl` | Imported atomic workflows: `sspace`. |
| `registry-vpc.miracle.ac.cn/nmdc/star:latest` | `linux/amd64` | `bioos_transcriptomics/scripts/star.wdl` | Imported atomic workflows: `star`. |
| `registry-vpc.miracle.ac.cn/nmdc/strainest:latest` | `linux/amd64` | `bioos_microbiome/scripts/strainest.wdl` | Imported atomic workflows: `strainest`. |
| `registry-vpc.miracle.ac.cn/nmdc/trinity:latest` | `linux/amd64` | `bioos_transcriptomics/scripts/trinity.wdl` | Imported atomic workflows: `trinity`. |
| `registry-vpc.miracle.ac.cn/nmdc/trnascan_se:latest` | `linux/amd64` | `bioos_microbiology_pathology/scripts/trnascan.wdl` | Imported atomic workflows: `trnascan`. |
| `registry-vpc.miracle.ac.cn/nmdc/xstream:latest` | `linux/amd64` | `bioos_genomics/scripts/xstream.wdl` | Imported atomic workflows: `xstream`. |
