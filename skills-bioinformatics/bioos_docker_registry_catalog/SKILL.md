---
name: bioos_docker_registry_catalog
description: Reference catalog of Bio-OS workflow container images. Use this
  skill to look up standard linux/amd64 images before changing workflow runtime
  blocks or deciding whether a new image must be built.
disable: false
---

# Bio-OS Docker Registry Catalog

## Scope
This catalog records the default container images referenced by the current Bio-OS business-layer workflows.

## Operating Rules
- Prefer an existing cataloged image before building a new one.
- When a workflow uses multiple task-specific images, consult the WDL runtime blocks and keep the catalog synchronized with the main task chain.
- If an image is replaced or version-bumped, update this file together with the consuming WDL.
- Leave `Installed Software` blank when the preinstalled contents are not confirmed.

## Catalog

| Image | Arch | Installed Software |
| --- | --- | --- |
| `registry-vpc.miracle.ac.cn/broad/gtex-rnaseq:V10` | `linux/amd64` | STAR, RNA-SeQC2, RSEM |
| `registry-vpc.miracle.ac.cn/auto-build/nextclade-dataset-prep:20260313-v1` | `linux/amd64` | Nextclade |
| `registry-vpc.miracle.ac.cn/auto-build/pangolin-sarscov2:20260312-v1` | `linux/amd64` | Pangolin |
| `registry-vpc.miracle.ac.cn/auto-build/petra-cpu-paper2workspace:20260316` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/abaffinity-p2w:20260313-v1` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/gznl/covfit:v1.0` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/freyja-paper2workspace:20260316-2` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/hiriskpredictor-wf:v0.3` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/gznl/population-immunity-wf:latest` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/gznl/proabc-2:latest` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/rleaai:v1.0` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/sars2-rbd-escape-calc:v2` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/sars2-rbd-escape-calc-workflow:p2w-20260312-143817` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/spikepro-sars2-p2w:20260312-wdl-v1` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/auto-build/viruswarn-repro:v0.2` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/nmdc/abundancebin:latest` | `linux/amd64` |  |
| `registry-vpc.miracle.ac.cn/nmdc/assembletool:latest` | `linux/amd64` | BLASR, SPAdes, Ray Meta |
| `registry-vpc.miracle.ac.cn/nmdc/ballgown:new` | `linux/amd64` | Ballgown |
| `registry-vpc.miracle.ac.cn/nmdc/bwa:latest` | `linux/amd64` | BWA |
| `registry-vpc.miracle.ac.cn/nmdc/cap3:latest` | `linux/amd64` | CAP3 |
| `registry-vpc.miracle.ac.cn/nmdc/cdhit:4.7-1` | `linux/amd64` | CD-HIT |
| `registry-vpc.miracle.ac.cn/nmdc/checkm:1.1.3` | `linux/amd64` | CheckM |
| `registry-vpc.miracle.ac.cn/nmdc/deseq2:new` | `linux/amd64` | DESeq2 |
| `registry-vpc.miracle.ac.cn/nmdc/dfast_core:1.2.6` | `linux/amd64` | DFAST |
| `registry-vpc.miracle.ac.cn/nmdc/diamond:latest` | `linux/amd64` | DIAMOND |
| `registry-vpc.miracle.ac.cn/nmdc/dudes:latest` | `linux/amd64` | DUDes |
| `registry-vpc.miracle.ac.cn/nmdc/glimmer3:latest` | `linux/amd64` | Glimmer3 |
| `registry-vpc.miracle.ac.cn/nmdc/kallisto:latest` | `linux/amd64` | Kallisto |
| `registry-vpc.miracle.ac.cn/nmdc/lumpy:latest` | `linux/amd64` | LUMPY |
| `registry-vpc.miracle.ac.cn/nmdc/metabat2:2.15--c1941c7` | `linux/amd64` | MetaBAT2 |
| `registry-vpc.miracle.ac.cn/nmdc/metatools:lite` | `linux/amd64` | BLAT, QUAST, REAPR, FragGeneScan, PILER-CR, Prodigal, Kaiju |
| `registry-vpc.miracle.ac.cn/nmdc/minced:latest` | `linux/amd64` | MinCED |
| `registry-vpc.miracle.ac.cn/nmdc/mrna:latest` | `linux/amd64` | Cuffdiff, Cufflinks, HISAT2, StringTie |
| `registry-vpc.miracle.ac.cn/nmdc/mummer3:v1` | `linux/amd64` | MUMmer3 |
| `registry-vpc.miracle.ac.cn/nmdc/oases:latest` | `linux/amd64` | Oases |
| `registry-vpc.miracle.ac.cn/nmdc/opera:latest` | `linux/amd64` | OPERA |
| `registry-vpc.miracle.ac.cn/nmdc/orthoani:latest` | `linux/amd64` | OrthoANI |
| `registry-vpc.miracle.ac.cn/nmdc/picrust:new` | `linux/amd64` | PICRUSt |
| `registry-vpc.miracle.ac.cn/nmdc/prism:latest` | `linux/amd64` | PRISM |
| `registry-vpc.miracle.ac.cn/nmdc/prokka:latest` | `linux/amd64` | Prokka |
| `registry-vpc.miracle.ac.cn/nmdc/rgi:6.0.3` | `linux/amd64` | RGI |
| `registry-vpc.miracle.ac.cn/nmdc/rnammer:v1.2` | `linux/amd64` | RNAmmer |
| `registry-vpc.miracle.ac.cn/nmdc/sailfish:latest` | `linux/amd64` | Sailfish |
| `registry-vpc.miracle.ac.cn/nmdc/sspace:v1` | `linux/amd64` | SSPACE |
| `registry-vpc.miracle.ac.cn/nmdc/star:latest` | `linux/amd64` | STAR |
| `registry-vpc.miracle.ac.cn/nmdc/strainest:latest` | `linux/amd64` | StrainEst |
| `registry-vpc.miracle.ac.cn/nmdc/trinity:latest` | `linux/amd64` | Trinity |
| `registry-vpc.miracle.ac.cn/nmdc/trnascan_se:latest` | `linux/amd64` | tRNAscan-SE |
| `registry-vpc.miracle.ac.cn/nmdc/xstream:latest` | `linux/amd64` | XSTREAM |
