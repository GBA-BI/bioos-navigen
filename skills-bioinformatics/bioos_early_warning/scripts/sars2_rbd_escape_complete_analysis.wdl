version 1.0

task sars2_rbd_escape_complete {
    input {
        File input_data
        String input_format = "auto"

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/sars2-rbd-escape-calc:v2"
        Int memory_gb = 8
        Int disk_space_gb = 100
        Int cpu_threads = 2
    }

    command <<<
        python /app/workflow/run_escape_complete.py \
            --input-file ~{input_data} \
            --input-format ~{input_format} \
            --summary-csv escape_summary.csv \
            --summary-json escape_summary.json \
            --per-site-csv escape_per_site.csv \
            --resolved-json resolved_queries.json \
            --repo-dir /app/repo
    >>>

    output {
        File escape_summary_csv = "escape_summary.csv"
        File escape_summary_json = "escape_summary.json"
        File escape_per_site_csv = "escape_per_site.csv"
        File resolved_queries_json = "resolved_queries.json"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow sars2_rbd_escape_complete_analysis {
    input {
        File input_data
        String input_format = "auto"
    }

    call sars2_rbd_escape_complete {
        input:
            input_data = input_data,
            input_format = input_format
    }

    output {
        File escape_summary_csv = sars2_rbd_escape_complete.escape_summary_csv
        File escape_summary_json = sars2_rbd_escape_complete.escape_summary_json
        File escape_per_site_csv = sars2_rbd_escape_complete.escape_per_site_csv
        File resolved_queries_json = sars2_rbd_escape_complete.resolved_queries_json
    }
}
