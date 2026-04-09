version 1.0

workflow DownloadSRA {
    input {
        String srr_id
        Int cpus = 8
        Int disk_gb = 100
        Int mem_gb = 16
        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/sra-toolkit:v1"
    }

    call DownloadTask {
        input:
            srr_id = srr_id,
            cpus = cpus,
            disk_gb = disk_gb,
            mem_gb = mem_gb,
            docker_image = docker_image
    }

    output {
        Array[File] fastq_files = DownloadTask.fastq_files
    }
}

task DownloadTask {
    input {
        String srr_id
        Int cpus
        Int disk_gb
        Int mem_gb
        String docker_image
    }

    command <<<
        set -euo pipefail

        echo "Initializing vdb-config..."
        # Required to avoid default global caching in vdb-config
        mkdir -p ~/.ncbi
        echo '/repository/user/main/public/root = "."' > ~/.ncbi/user-settings.mkfg
        # Tell vdb-config to allow connections over HTTPS if needed, etc.
        vdb-config --accept-pwd-dep > /dev/null || true

        echo "Prefetching ~{srr_id}..."
        # Step 1: Download to SRA
        prefetch ~{srr_id} -O ./sra_cache/ --max-size ~{disk_gb}G

        echo "Converting to FASTQ..."
        mkdir -p ./fastq_out
        mkdir -p ./tmp_out
        
        # Step 2: Convert SRA to FASTQ formats using fasterq-dump
        # fasterq-dump supports multithreading and outputs cleanly to custom dir.
        fasterq-dump ./sra_cache/~{srr_id}/~{srr_id}.sra \
            -O ./fastq_out/ \
            -e ~{cpus} \
            -t ./tmp_out/
            
        echo "Done!"
    >>>

    runtime {
        docker: docker_image # A standard SRA toolkit image
        cpu: "~{cpus}"
        memory: "~{mem_gb} GB"
        disks: "local-disk " + disk_gb + " SSD"
        preemptible: 3
    }

    output {
        # Catch all the generated fastq files
        Array[File] fastq_files = glob("fastq_out/*.fastq")
    }
}
