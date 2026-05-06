version 1.0

task freyja_variants {
    input {
        File bam
        File bam_index
        File reference_fasta
        String sample_name
        String reference_name = ""
        Int min_base_quality = 20
        Float variant_threshold = 0.0

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/freyja-paper2workspace:20260316-2"
        Int memory_gb = 16
        Int disk_space_gb = 100
        Int cpu_threads = 4
    }

    command <<<
        set -euo pipefail

        cp ~{bam} ~{sample_name}.bam
        cp ~{bam_index} ~{sample_name}.bam.bai
        cp ~{reference_fasta} reference.fasta
        samtools faidx reference.fasta

        REFNAME_ARG=""
        if [ "~{reference_name}" != "" ]; then
            REFNAME_ARG="--refname ~{reference_name}"
        fi

        freyja variants \
            ~{sample_name}.bam \
            --variants ~{sample_name} \
            --depths ~{sample_name}.depth \
            --ref reference.fasta \
            --minq ~{min_base_quality} \
            --varthresh ~{variant_threshold} \
            ${REFNAME_ARG}
    >>>

    output {
        File variants_tsv = "~{sample_name}.tsv"
        File depths_tsv = "~{sample_name}.depth"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

task freyja_demix {
    input {
        File variants_tsv
        File depths_tsv
        String sample_name
        Float eps = 0.001
        Int coverage_cutoff = 10
        Boolean confirmed_only = true
        String pathogen = "SARS-CoV-2"
        File? barcode_file
        File? lineage_meta_file

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/freyja-paper2workspace:20260316-2"
        Int memory_gb = 16
        Int disk_space_gb = 100
        Int cpu_threads = 4
    }

    command <<<
        set -euo pipefail

        freyja demix --version --pathogen ~{pathogen} > ~{sample_name}.barcode_version.txt

        freyja demix \
            ~{variants_tsv} \
            ~{depths_tsv} \
            --output ~{sample_name}.demix.tsv \
            --eps ~{eps} \
            --covcut ~{coverage_cutoff} \
            --pathogen ~{pathogen} \
            ~{if confirmed_only then "--confirmedonly" else ""} \
            ~{if defined(barcode_file) then "--barcodes " + barcode_file else ""} \
            ~{if defined(lineage_meta_file) then "--meta " + lineage_meta_file else ""}
    >>>

    output {
        File demix_tsv = "~{sample_name}.demix.tsv"
        File barcode_version_txt = "~{sample_name}.barcode_version.txt"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

task summarize_demix {
    input {
        File demix_tsv
        String sample_name
        Int top_n = 5

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/freyja-paper2workspace:20260316-2"
        Int memory_gb = 4
        Int disk_space_gb = 20
        Int cpu_threads = 1
    }

    command <<<
        set -euo pipefail

        python /opt/freyja-tools/summarize_demix.py \
            --input ~{demix_tsv} \
            --output-json ~{sample_name}.summary.json \
            --output-tsv ~{sample_name}.summary.tsv \
            --top-n ~{top_n}
    >>>

    output {
        File summary_json = "~{sample_name}.summary.json"
        File summary_tsv = "~{sample_name}.summary.tsv"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow freyja_sars_cov2_lineage_deconvolution {
    input {
        File bam
        File bam_index
        File reference_fasta
        String sample_name = "sample"
        String reference_name = ""
        Float variant_threshold = 0.0
        Int min_base_quality = 20
        Float eps = 0.001
        Int coverage_cutoff = 10
        Boolean confirmed_only = true
        String pathogen = "SARS-CoV-2"
        File? barcode_file
        File? lineage_meta_file
        Int top_n = 5
    }

    call freyja_variants {
        input:
            bam = bam,
            bam_index = bam_index,
            reference_fasta = reference_fasta,
            sample_name = sample_name,
            reference_name = reference_name,
            min_base_quality = min_base_quality,
            variant_threshold = variant_threshold
    }

    call freyja_demix {
        input:
            variants_tsv = freyja_variants.variants_tsv,
            depths_tsv = freyja_variants.depths_tsv,
            sample_name = sample_name,
            eps = eps,
            coverage_cutoff = coverage_cutoff,
            confirmed_only = confirmed_only,
            pathogen = pathogen,
            barcode_file = barcode_file,
            lineage_meta_file = lineage_meta_file
    }

    call summarize_demix {
        input:
            demix_tsv = freyja_demix.demix_tsv,
            sample_name = sample_name,
            top_n = top_n
    }

    output {
        File variants_tsv = freyja_variants.variants_tsv
        File depth_tsv = freyja_variants.depths_tsv
        File demix_tsv = freyja_demix.demix_tsv
        File barcode_version_txt = freyja_demix.barcode_version_txt
        File summary_json = summarize_demix.summary_json
        File summary_tsv = summarize_demix.summary_tsv
    }
}
