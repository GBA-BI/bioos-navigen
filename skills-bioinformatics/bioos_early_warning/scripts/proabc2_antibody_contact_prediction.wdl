version 1.0

task proabc2_predict {
    input {
        File heavy_fasta
        File light_fasta
        String output_prefix = "proabc2_result"

        String docker_image = "registry-vpc.miracle.ac.cn/gznl/proabc-2:latest"
        Int memory_gb = 8
        Int disk_space_gb = 50
        Int cpu_threads = 2
    }

    command <<<
        set -euo pipefail

        mkdir -p input_dir
        cp ~{heavy_fasta} input_dir/heavy.fasta
        cp ~{light_fasta} input_dir/light.fasta

        proabc2 input_dir/ heavy.fasta light.fasta > ~{output_prefix}.stdout.log 2> ~{output_prefix}.stderr.log

        cp input_dir/heavy-pred.csv ~{output_prefix}_heavy-pred.csv
        cp input_dir/light-pred.csv ~{output_prefix}_light-pred.csv
    >>>

    output {
        File heavy_prediction_csv = "~{output_prefix}_heavy-pred.csv"
        File light_prediction_csv = "~{output_prefix}_light-pred.csv"
        File stdout_log = "~{output_prefix}.stdout.log"
        File stderr_log = "~{output_prefix}.stderr.log"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow proabc2_antibody_contact_prediction {
    input {
        File heavy_fasta
        File light_fasta
        String output_prefix = "proabc2_result"
    }

    call proabc2_predict {
        input:
            heavy_fasta = heavy_fasta,
            light_fasta = light_fasta,
            output_prefix = output_prefix
    }

    output {
        File heavy_prediction_csv = proabc2_predict.heavy_prediction_csv
        File light_prediction_csv = proabc2_predict.light_prediction_csv
        File stdout_log = proabc2_predict.stdout_log
        File stderr_log = proabc2_predict.stderr_log
    }
}
