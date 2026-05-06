version 1.0

task run_nextclade_analysis {
    input {
        File query_fasta
        File reference_fasta
        File genome_annotation_gff3
        File tree_json
        File pathogen_json
        String output_prefix
        Boolean include_reference
        Boolean preserve_order

        String docker_image
        Int memory_gb
        Int disk_space_gb
        Int cpu_threads
    }

    command <<<
        set -euo pipefail

        cp ~{query_fasta} query.fasta
        cp ~{reference_fasta} reference.fasta
        cp ~{genome_annotation_gff3} genome_annotation.gff3
        cp ~{tree_json} tree.json
        cp ~{pathogen_json} pathogen.json

        nextclade run \
          ~{if include_reference then "--include-reference" else ""} \
          ~{if preserve_order then "--in-order" else ""} \
          --jobs ~{cpu_threads} \
          --input-ref reference.fasta \
          --input-annotation genome_annotation.gff3 \
          --input-tree tree.json \
          --input-pathogen-json pathogen.json \
          --output-fasta ~{output_prefix}.aligned.fasta \
          --output-json ~{output_prefix}.json \
          --output-ndjson ~{output_prefix}.ndjson \
          --output-csv ~{output_prefix}.csv \
          --output-tsv ~{output_prefix}.tsv \
          --output-tree ~{output_prefix}.auspice.json \
          --output-tree-nwk ~{output_prefix}.tree.nwk \
          query.fasta

        nextclade --version > ~{output_prefix}.versions.txt
    >>>

    output {
        File aligned_fasta = "~{output_prefix}.aligned.fasta"
        File results_json = "~{output_prefix}.json"
        File results_ndjson = "~{output_prefix}.ndjson"
        File results_csv = "~{output_prefix}.csv"
        File results_tsv = "~{output_prefix}.tsv"
        File output_tree_json = "~{output_prefix}.auspice.json"
        File output_tree_nwk = "~{output_prefix}.tree.nwk"
        File versions_txt = "~{output_prefix}.versions.txt"
    }

    runtime {
        docker: docker_image
        memory: "~{memory_gb}GB"
        disks: "local-disk ~{disk_space_gb} SSD"
        cpu: cpu_threads
    }
}

workflow nextclade_pathogen_genome_analysis {
    input {
        File query_fasta
        File reference_fasta
        File genome_annotation_gff3
        File tree_json
        File pathogen_json
        String output_prefix = "nextclade_run"
        Boolean include_reference = false
        Boolean preserve_order = true

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/nextclade-dataset-prep:20260313-v1"
        Int memory_gb = 16
        Int disk_space_gb = 100
        Int cpu_threads = 4
    }

    call run_nextclade_analysis {
        input:
            query_fasta = query_fasta,
            reference_fasta = reference_fasta,
            genome_annotation_gff3 = genome_annotation_gff3,
            tree_json = tree_json,
            pathogen_json = pathogen_json,
            output_prefix = output_prefix,
            include_reference = include_reference,
            preserve_order = preserve_order,
            docker_image = docker_image,
            memory_gb = memory_gb,
            disk_space_gb = disk_space_gb,
            cpu_threads = cpu_threads
    }

    output {
        File aligned_fasta = run_nextclade_analysis.aligned_fasta
        File results_json = run_nextclade_analysis.results_json
        File results_ndjson = run_nextclade_analysis.results_ndjson
        File results_csv = run_nextclade_analysis.results_csv
        File results_tsv = run_nextclade_analysis.results_tsv
        File output_tree_json = run_nextclade_analysis.output_tree_json
        File output_tree_nwk = run_nextclade_analysis.output_tree_nwk
        File versions_txt = run_nextclade_analysis.versions_txt
    }
}
