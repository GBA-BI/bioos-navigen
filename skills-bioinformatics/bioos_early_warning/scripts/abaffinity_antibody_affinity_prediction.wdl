version 1.0

task abaffinity_predict {
    input {
        File antibody_input_csv
        String output_prefix = "abaffinity"
        Int batch_size = 4

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/abaffinity-p2w:20260313-v1"
        Int memory_gb = 32
        Int disk_space_gb = 120
        Int cpu_threads = 4
    }

    command <<<
        set -e
        python3 /app/workflow/run_abaffinity_batch.py \
            --input-csv ~{antibody_input_csv} \
            --predictions-csv ~{output_prefix}_predictions.csv \
            --summary-json ~{output_prefix}_summary.json \
            --normalized-csv ~{output_prefix}_normalized_input.csv \
            --weights /app/hf_model/abaffinity/abaffinity_weights.pth \
            --batch-size ~{batch_size}
    >>>

    output {
        File predictions_csv = "~{output_prefix}_predictions.csv"
        File summary_json = "~{output_prefix}_summary.json"
        File normalized_input_csv = "~{output_prefix}_normalized_input.csv"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow abaffinity_antibody_affinity_prediction {
    input {
        File antibody_input_csv
        String output_prefix = "abaffinity"
        Int batch_size = 4
    }

    call abaffinity_predict {
        input:
            antibody_input_csv = antibody_input_csv,
            output_prefix = output_prefix,
            batch_size = batch_size
    }

    output {
        File predictions_csv = abaffinity_predict.predictions_csv
        File summary_json = abaffinity_predict.summary_json
        File normalized_input_csv = abaffinity_predict.normalized_input_csv
    }
}
