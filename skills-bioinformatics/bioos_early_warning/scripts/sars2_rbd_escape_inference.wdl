version 1.0

task run_sars2_rbd_escape_inference {
    input {
        File query_json

        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/sars2-rbd-escape-calc-workflow:p2w-20260312-143817"
        Int memory_gb = 8
        Int disk_space_gb = 100
        Int cpu_threads = 2
    }

    command <<<
        python /app/workflow/run_escape_inference.py \
            --query-json ~{query_json} \
            --output-json escape_summary.json \
            --site-csv escape_per_site.csv \
            --mutations-json resolved_mutations.json \
            --repo-dir /app/repo
    >>>

    output {
        File escape_summary = "escape_summary.json"
        File escape_per_site = "escape_per_site.csv"
        File resolved_mutations = "resolved_mutations.json"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}

workflow sars2_rbd_escape_inference {
    input {
        File query_json
    }

    call run_sars2_rbd_escape_inference {
        input:
            query_json = query_json
    }

    output {
        File escape_summary = run_sars2_rbd_escape_inference.escape_summary
        File escape_per_site = run_sars2_rbd_escape_inference.escape_per_site
        File resolved_mutations = run_sars2_rbd_escape_inference.resolved_mutations
    }
}
