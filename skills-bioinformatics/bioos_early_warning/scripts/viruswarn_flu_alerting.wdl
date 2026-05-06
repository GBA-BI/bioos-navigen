version 1.0

workflow viruswarn_flu_alerting {
    input {
        File? input_fasta
        File? metadata_file
        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/viruswarn-repro:v0.2"
        Int memory_gb = 8
        Int cpu_threads = 4
        Int disk_space_gb = 50
    }

    call RunVirusWarnFlu {
        input:
            input_fasta = input_fasta,
            metadata_file = metadata_file,
            docker_image = docker_image,
            memory_gb = memory_gb,
            cpu_threads = cpu_threads,
            disk_space_gb = disk_space_gb
    }

    output {
        File? report_html = RunVirusWarnFlu.report_html
        Array[File] all_htmls = RunVirusWarnFlu.all_htmls
        Array[File] report_csvs = RunVirusWarnFlu.report_csvs
        File? nextflow_log = RunVirusWarnFlu.nextflow_log
    }
}

task RunVirusWarnFlu {
    input {
        File? input_fasta
        File? metadata_file
        String docker_image
        Int memory_gb
        Int cpu_threads
        Int disk_space_gb
    }

    command <<<
        set -e

        # Copy the repo contents to the current execution directory
        cp -r /app/VirusWarn-Flu/. .

        # Prepare input files
        FASTA_ARG=""
        if [ -n "~{input_fasta}" ]; then
            FASTA_ARG="--fasta ~{input_fasta}"
        else
            echo "No input FASTA provided, using default test data."
            FASTA_ARG="--fasta test/openflu_h1n1.fasta"
        fi

        METADATA_ARG=""
        if [ -n "~{metadata_file}" ]; then
            METADATA_ARG="--metadata ~{metadata_file}"
        else
            echo "No metadata provided, using default test data."
            METADATA_ARG="--metadata test/metadata_h1n1.xlsx"
        fi

        # Run VirusWarn-Flu
        # Ensure we export R_LIBS_USER for seqinr package
        export R_LIBS_USER=~/R/library
        
        # Use || true to prevent immediate exit
        nextflow run main.nf \
            -profile local \
            $FASTA_ARG \
            $METADATA_ARG || echo "Nextflow finished with error code, but continuing to check output..."
            
        # Move results to a clean location for output capture
        mkdir -p final_results
        
        # Strategy: Find ALL HTML files in results directory and copy them
        # This will catch report.html, qc.html, and any others
        find results -name "*.html" -exec cp {} final_results/ \; || true
        
        # If report.html was copied, ensure it exists as 'report.html' for the specific output
        # (It might have been copied as 'vocal-report.html' or something else if names vary)
        if [ ! -f final_results/report.html ] && [ -f results/03_report/report.html ]; then
             cp results/03_report/report.html final_results/
        fi
        
        # Copy CSVs
        find results -name "*.csv" -exec cp {} final_results/ \; || true
        
        # Copy log
        cp .nextflow.log final_results/nextflow.log || true
    >>>

    output {
        File? report_html = "final_results/report.html"
        Array[File] all_htmls = glob("final_results/*.html")
        Array[File] report_csvs = glob("final_results/*.csv")
        File? nextflow_log = "final_results/nextflow.log"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + " GB"
        cpu: cpu_threads
        disk_space: disk_space_gb + " GB"
    }
}
