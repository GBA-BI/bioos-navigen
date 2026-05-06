version 1.0

task petra_predict {
    input {
        File query_json

        String docker_image
        Int memory_gb
        Int disk_space_gb
        Int cpu_threads
    }

    command <<<
        set -euo pipefail

        python3 /app/src/petra_cpu_runner.py \
            --query-json ~{query_json} \
            --output-json petra_predictions.json \
            --output-tsv petra_predictions.tsv \
            --assets-dir /app/assets \
            --model-path /app/assets/model_20250212.safetensors \
            --threads ~{cpu_threads}
    >>>

    output {
        File predictions_json = "petra_predictions.json"
        File predictions_tsv = "petra_predictions.tsv"
    }

    runtime {
        docker: docker_image
        memory: "~{memory_gb}GB"
        disks: "local-disk ~{disk_space_gb} SSD"
        cpu: cpu_threads
    }
}

workflow petra_sars_cov2_mutation_prediction {
    input {
        File query_json

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/petra-cpu-paper2workspace:20260316"
        Int memory_gb = 32
        Int disk_space_gb = 50
        Int cpu_threads = 8
    }

    call petra_predict {
        input:
            query_json = query_json,
            docker_image = docker_image,
            memory_gb = memory_gb,
            disk_space_gb = disk_space_gb,
            cpu_threads = cpu_threads
    }

    output {
        File predictions_json = petra_predict.predictions_json
        File predictions_tsv = petra_predict.predictions_tsv
    }
}
