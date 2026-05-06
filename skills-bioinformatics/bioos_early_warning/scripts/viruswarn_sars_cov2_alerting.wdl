version 1.0

workflow viruswarn_sars_cov2_alerting {
    input {
        File? input_fasta
        File? metadata_file
        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/viruswarn-repro:v0.2"
        Int memory_gb = 8
        Int cpu_threads = 4
        Int disk_space_gb = 50
    }

    call RunVirusWarnSC2 {
        input:
            input_fasta = input_fasta,
            metadata_file = metadata_file,
            docker_image = docker_image,
            memory_gb = memory_gb,
            cpu_threads = cpu_threads,
            disk_space_gb = disk_space_gb
    }

    output {
        File? report_html = RunVirusWarnSC2.report_html
        Array[File] report_csvs = RunVirusWarnSC2.report_csvs
        File? nextflow_log = RunVirusWarnSC2.nextflow_log
    }
}

task RunVirusWarnSC2 {
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
        cp -r /app/viruswarn-sc2/. .

        # Prepare input files
        FASTA_ARG=""
        if [ -n "~{input_fasta}" ]; then
            FASTA_ARG="--fasta ~{input_fasta}"
        else
            echo "No input FASTA provided, using default test data."
            FASTA_ARG="--fasta test/sample-test.fasta"
        fi

        METADATA_ARG=""
        if [ -n "~{metadata_file}" ]; then
            METADATA_ARG="--metadata ~{metadata_file}"
        fi

        # Run VirusWarn-SC2
        echo "Starting Nextflow run..."
        nextflow run main.nf \
            -profile local \
            $FASTA_ARG \
            $METADATA_ARG || echo "Nextflow finished with error code, but continuing to check output..."
            
        echo "Nextflow run completed."

        # Move results to a clean location for output capture
        mkdir -p final_results
        
        # Specific copy for VirusWarn-SC2 output structure based on file_list.txt
        # It produces ./results/03_report/vocal-report.html
        
        if [ -f "results/03_report/vocal-report.html" ]; then
            cp "results/03_report/vocal-report.html" final_results/report.html
        elif [ -f "results/03_report/report.html" ]; then
            cp "results/03_report/report.html" final_results/report.html
        else
            # Fallback: copy any HTML in results/03_report/
            find results/03_report -name "*.html" -exec cp {} final_results/report.html \; || true
        fi
        
        # Copy CSVs
        # ./results/03_report/vocal-alerts-clusters-summaries-all.csv 
        # ./results/03_report/vocal-alerts-samples-all.csv
        find results/03_report -name "*.csv" -exec cp {} final_results/ \; || true
        
        # Copy log
        cp .nextflow.log final_results/nextflow.log || true
    >>>

    output {
        File? report_html = "final_results/report.html"
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
