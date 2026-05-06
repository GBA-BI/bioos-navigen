version 1.0

task download_nextclade_dataset {
    input {
        String dataset_name
        String output_prefix

        String docker_image
        Int memory_gb
        Int disk_space_gb
        Int cpu_threads
    }

    command <<<
        set -euo pipefail

        mkdir -p dataset

        nextclade dataset get \
          --name ~{dataset_name} \
          --output-dir dataset

        cp dataset/reference.fasta ~{output_prefix}_reference.fasta
        cp dataset/genome_annotation.gff3 ~{output_prefix}_genome_annotation.gff3
        cp dataset/tree.json ~{output_prefix}_tree.json
        cp dataset/pathogen.json ~{output_prefix}_pathogen.json
        cp dataset/sequences.fasta ~{output_prefix}_sequences.fasta
        cp dataset/README.md ~{output_prefix}_README.md
        cp dataset/CHANGELOG.md ~{output_prefix}_CHANGELOG.md

        nextclade --version > ~{output_prefix}_versions.txt
        find dataset -maxdepth 1 -type f | sort > ~{output_prefix}_dataset_files.txt
    >>>

    output {
        File reference_fasta = "~{output_prefix}_reference.fasta"
        File genome_annotation_gff3 = "~{output_prefix}_genome_annotation.gff3"
        File tree_json = "~{output_prefix}_tree.json"
        File pathogen_json = "~{output_prefix}_pathogen.json"
        File example_sequences_fasta = "~{output_prefix}_sequences.fasta"
        File readme_md = "~{output_prefix}_README.md"
        File changelog_md = "~{output_prefix}_CHANGELOG.md"
        File versions_txt = "~{output_prefix}_versions.txt"
        File dataset_files_txt = "~{output_prefix}_dataset_files.txt"
    }

    runtime {
        docker: docker_image
        memory: "~{memory_gb}GB"
        disks: "local-disk ~{disk_space_gb} SSD"
        cpu: cpu_threads
    }
}

workflow nextclade_dataset_prepare {
    input {
        String dataset_name = "nextstrain/sars-cov-2/wuhan-hu-1/orfs"
        String output_prefix = "nextclade_dataset"

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/nextclade-dataset-prep:20260313-v1"
        Int memory_gb = 8
        Int disk_space_gb = 50
        Int cpu_threads = 2
    }

    call download_nextclade_dataset {
        input:
            dataset_name = dataset_name,
            output_prefix = output_prefix,
            docker_image = docker_image,
            memory_gb = memory_gb,
            disk_space_gb = disk_space_gb,
            cpu_threads = cpu_threads
    }

    output {
        File reference_fasta = download_nextclade_dataset.reference_fasta
        File genome_annotation_gff3 = download_nextclade_dataset.genome_annotation_gff3
        File tree_json = download_nextclade_dataset.tree_json
        File pathogen_json = download_nextclade_dataset.pathogen_json
        File example_sequences_fasta = download_nextclade_dataset.example_sequences_fasta
        File readme_md = download_nextclade_dataset.readme_md
        File changelog_md = download_nextclade_dataset.changelog_md
        File versions_txt = download_nextclade_dataset.versions_txt
        File dataset_files_txt = download_nextclade_dataset.dataset_files_txt
    }
}
