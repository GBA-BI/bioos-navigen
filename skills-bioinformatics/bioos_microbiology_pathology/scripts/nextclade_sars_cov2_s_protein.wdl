version 1.0

task run_nextclade_sars_cov2_s_protein {
    input {
        File query_fasta
        File reference_fasta
        File genome_annotation_gff3
        File tree_json
        File pathogen_json
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

        mkdir -p sars2_dataset translations
        cp ~{query_fasta} query.fasta
        cp ~{reference_fasta} sars2_dataset/reference.fasta
        cp ~{genome_annotation_gff3} sars2_dataset/genome_annotation.gff3
        cp ~{tree_json} sars2_dataset/tree.json
        cp ~{pathogen_json} sars2_dataset/pathogen.json

        nextclade run \
          ~{if include_reference then "--include-reference" else ""} \
          ~{if preserve_order then "--in-order" else ""} \
          --jobs ~{cpu_threads} \
          --input-dataset sars2_dataset \
          --output-fasta ~{output_prefix}.aligned.fasta \
          --output-json ~{output_prefix}.json \
          --output-ndjson ~{output_prefix}.ndjson \
          --output-csv ~{output_prefix}.csv \
          --output-tsv ~{output_prefix}.tsv \
          --output-tree ~{output_prefix}.auspice.json \
          --output-tree-nwk ~{output_prefix}.tree.nwk \
          --output-translations "translations/{cds}.fasta" \
          query.fasta

        test -s translations/S.fasta
        nextclade --version > ~{output_prefix}.versions.txt
    >>>

    output {
        File spike_protein_fasta = "translations/S.fasta"
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
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow nextclade_sars_cov2_s_protein {
    input {
        File query_fasta
    }

    File reference_fasta = "drs://imc-drs.miracle.ac.cn/ed7it0ibrqu01uble9fjg"
    File genome_annotation_gff3 = "drs://imc-drs.miracle.ac.cn/ed7it0ibrqu01uble9fe0"
    File tree_json = "drs://imc-drs.miracle.ac.cn/ed7it0ibrqu01uble9fj0"
    File pathogen_json = "drs://imc-drs.miracle.ac.cn/ed7it0ibrqu01uble9ff0"
    String output_prefix = "nextclade_sars_cov2"
    Boolean include_reference = false
    Boolean preserve_order = true
    String docker_image = "registry-vpc.miracle.ac.cn/auto-build/nextclade-dataset-prep:20260313-v1"
    Int memory_gb = 16
    Int disk_space_gb = 100
    Int cpu_threads = 4

    call run_nextclade_sars_cov2_s_protein {
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
        File spike_protein_fasta = run_nextclade_sars_cov2_s_protein.spike_protein_fasta
        File aligned_fasta = run_nextclade_sars_cov2_s_protein.aligned_fasta
        File results_json = run_nextclade_sars_cov2_s_protein.results_json
        File results_ndjson = run_nextclade_sars_cov2_s_protein.results_ndjson
        File results_csv = run_nextclade_sars_cov2_s_protein.results_csv
        File results_tsv = run_nextclade_sars_cov2_s_protein.results_tsv
        File output_tree_json = run_nextclade_sars_cov2_s_protein.output_tree_json
        File output_tree_nwk = run_nextclade_sars_cov2_s_protein.output_tree_nwk
        File versions_txt = run_nextclade_sars_cov2_s_protein.versions_txt
    }
}
