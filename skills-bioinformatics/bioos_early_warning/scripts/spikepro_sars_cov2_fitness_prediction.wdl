version 1.0

task spikepro_predict {
    input {
        File query_fasta
        String sample_name = "sample"

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/spikepro-sars2-p2w:20260312-wdl-v1"
        Int memory_gb = 8
        Int disk_space_gb = 50
        Int cpu_threads = 2
    }

    command <<<
        set -e
        cp /app/SpikeProSARS-CoV-2/P0DTC2.fasta ./P0DTC2.fasta
        cp /app/SpikeProSARS-CoV-2/PIO_8.csv ./PIO_8.csv
        cp ~{query_fasta} input.fasta
        /usr/local/bin/SpikePro input.fasta go > ~{sample_name}_spikepro_report.txt
    >>>

    output {
        File report_txt = "~{sample_name}_spikepro_report.txt"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow spikepro_sars_cov2_fitness_prediction {
    input {
        File query_fasta
        String sample_name = "sample"
    }

    call spikepro_predict {
        input:
            query_fasta = query_fasta,
            sample_name = sample_name
    }

    output {
        File report_txt = spikepro_predict.report_txt
    }
}
