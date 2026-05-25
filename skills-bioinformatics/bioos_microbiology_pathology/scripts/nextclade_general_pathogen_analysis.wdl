version 1.0

task run_nextclade_general_pathogen_analysis {
    input {
        File query_fasta
        String dataset_name
        String output_prefix
        Boolean include_reference
        Boolean preserve_order

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/nextclade-dataset-prep:20260313-v1"
        Int memory_gb = 16
        Int disk_space_gb = 100
        Int cpu_threads = 4
    }

    command <<<
        set -euo pipefail

        mkdir -p dataset translations
        cp ~{query_fasta} query.fasta

        nextclade dataset get \
          --name "~{dataset_name}" \
          --output-dir dataset

        nextclade run \
          ~{if include_reference then "--include-reference" else ""} \
          ~{if preserve_order then "--in-order" else ""} \
          --jobs ~{cpu_threads} \
          --input-dataset dataset \
          --output-fasta ~{output_prefix}.aligned.fasta \
          --output-json ~{output_prefix}.json \
          --output-ndjson ~{output_prefix}.ndjson \
          --output-csv ~{output_prefix}.csv \
          --output-tsv ~{output_prefix}.tsv \
          --output-translations "translations/{cds}.fasta" \
          query.fasta

        tar -czf ~{output_prefix}.translations.tar.gz translations
        printf '%s\n' "~{dataset_name}" > ~{output_prefix}.dataset_name.txt
        find dataset -maxdepth 1 -type f | sort > ~{output_prefix}.dataset_files.txt
        nextclade --version > ~{output_prefix}.versions.txt
    >>>

    output {
        File aligned_fasta = "~{output_prefix}.aligned.fasta"
        File results_json = "~{output_prefix}.json"
        File results_ndjson = "~{output_prefix}.ndjson"
        File results_csv = "~{output_prefix}.csv"
        File results_tsv = "~{output_prefix}.tsv"
        File translations_tar_gz = "~{output_prefix}.translations.tar.gz"
        File dataset_name_txt = "~{output_prefix}.dataset_name.txt"
        File dataset_files_txt = "~{output_prefix}.dataset_files.txt"
        File versions_txt = "~{output_prefix}.versions.txt"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow nextclade_general_pathogen_analysis {
    input {
        File query_fasta
        String dataset_name
    }

    String output_prefix = "nextclade_general"
    Boolean include_reference = false
    Boolean preserve_order = true
    String docker_image = "registry-vpc.miracle.ac.cn/auto-build/nextclade-dataset-prep:20260313-v1"
    Int memory_gb = 16
    Int disk_space_gb = 100
    Int cpu_threads = 4

    call run_nextclade_general_pathogen_analysis {
        input:
            query_fasta = query_fasta,
            dataset_name = dataset_name,
            output_prefix = output_prefix,
            include_reference = include_reference,
            preserve_order = preserve_order,
            docker_image = docker_image,
            memory_gb = memory_gb,
            disk_space_gb = disk_space_gb,
            cpu_threads = cpu_threads
    }

    output {
        File aligned_fasta = run_nextclade_general_pathogen_analysis.aligned_fasta
        File results_json = run_nextclade_general_pathogen_analysis.results_json
        File results_ndjson = run_nextclade_general_pathogen_analysis.results_ndjson
        File results_csv = run_nextclade_general_pathogen_analysis.results_csv
        File results_tsv = run_nextclade_general_pathogen_analysis.results_tsv
        File translations_tar_gz = run_nextclade_general_pathogen_analysis.translations_tar_gz
        File dataset_name_txt = run_nextclade_general_pathogen_analysis.dataset_name_txt
        File dataset_files_txt = run_nextclade_general_pathogen_analysis.dataset_files_txt
        File versions_txt = run_nextclade_general_pathogen_analysis.versions_txt
    }
}
