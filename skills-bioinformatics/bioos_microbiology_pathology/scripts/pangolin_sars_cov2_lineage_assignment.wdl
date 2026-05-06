version 1.0

task pangolin_assign_lineage {
    input {
        File query_fasta
        String output_prefix
        String analysis_mode
        Boolean skip_scorpio
        Float max_ambig
        Int min_length

        String docker_image
        Int memory_gb
        Int disk_space_gb
        Int cpu_threads
    }

    command <<<
        set -euo pipefail

        cp ~{query_fasta} input.fasta

        pangolin \
            input.fasta \
            --outdir . \
            --outfile lineage_report.csv \
            --analysis-mode ~{analysis_mode} \
            --threads ~{cpu_threads} \
            ~{if skip_scorpio then "--skip-scorpio" else ""} \
            --max-ambig ~{max_ambig} \
            --min-length ~{min_length}

        pangolin --all-versions > ~{output_prefix}_versions.txt
        cp lineage_report.csv ~{output_prefix}_lineage_report.csv
    >>>

    output {
        File lineage_report_csv = "~{output_prefix}_lineage_report.csv"
        File versions_txt = "~{output_prefix}_versions.txt"
    }

    runtime {
        docker: docker_image
        memory: "~{memory_gb}GB"
        disks: "local-disk ~{disk_space_gb} SSD"
        cpu: cpu_threads
    }
}

workflow pangolin_sars_cov2_lineage_assignment {
    input {
        File query_fasta
        String output_prefix = "pangolin"
        String analysis_mode = "accurate"
        Boolean skip_scorpio = false
        Float max_ambig = 0.3
        Int min_length = 25000

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/pangolin-sarscov2:20260312-v1"
        Int memory_gb = 16
        Int disk_space_gb = 100
        Int cpu_threads = 4
    }

    call pangolin_assign_lineage {
        input:
            query_fasta = query_fasta,
            output_prefix = output_prefix,
            analysis_mode = analysis_mode,
            skip_scorpio = skip_scorpio,
            max_ambig = max_ambig,
            min_length = min_length,
            docker_image = docker_image,
            memory_gb = memory_gb,
            disk_space_gb = disk_space_gb,
            cpu_threads = cpu_threads
    }

    output {
        File lineage_report_csv = pangolin_assign_lineage.lineage_report_csv
        File versions_txt = pangolin_assign_lineage.versions_txt
    }
}
