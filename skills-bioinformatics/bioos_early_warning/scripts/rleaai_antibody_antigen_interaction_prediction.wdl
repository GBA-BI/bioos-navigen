version 1.0

workflow rleaai_antibody_antigen_interaction_prediction {
    input {
        File? antibody_fasta
        File? antigen_fasta
        String virus = "HIV"
        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/rleaai:v1.0"
        Int memory_gb = 16
        Int cpu_threads = 4
        Int disk_space_gb = 50
    }

    call predict_rleaai {
        input:
            antibody_fasta = antibody_fasta,
            antigen_fasta = antigen_fasta,
            virus = virus,
            docker_image = docker_image,
            memory_gb = memory_gb,
            cpu_threads = cpu_threads,
            disk_space_gb = disk_space_gb
    }

    output {
        Array[File] predictions = predict_rleaai.predictions
        Array[File] output_logs = predict_rleaai.output_logs
    }
}

task predict_rleaai {
    input {
        File? antibody_fasta
        File? antigen_fasta
        String virus
        String docker_image
        Int memory_gb
        Int cpu_threads
        Int disk_space_gb
    }
    
    command <<<
        set -x
        
        OUTPUT_DIR="$(pwd)/outputs"
        mkdir -p $OUTPUT_DIR
        
        echo "===== STARTING RLEAAI PREDICTION ====="
        echo "Output directory: $OUTPUT_DIR"
        
        if [ -f "~{antibody_fasta}" ]; then
            echo "Copying antibody fasta..."
            cp "~{antibody_fasta}" /app/RLEAAI/data/example/ab.fasta
        else
            echo "Using default antibody"
        fi
        
        if [ -f "~{antigen_fasta}" ]; then
            echo "Copying antigen fasta..."
            cp "~{antigen_fasta}" /app/RLEAAI/data/example/ag.fasta
        else
            echo "Using default antigen"
        fi
        
        cd /app/RLEAAI
        
        python predict.py \
            --ab_fa data/example/ab.fasta \
            --ag_fa data/example/ag.fasta \
            --virus ~{virus} 2>&1 | tee $OUTPUT_DIR/output.txt
        
        PRED=$(grep "Predicted probability" $OUTPUT_DIR/output.txt | sed 's/Predicted probability of interaction: //' | tr -d ' ')
        
        echo "abseq,agseq,prob,label" > $OUTPUT_DIR/predictions.csv
        echo "EXAMPLE_AB_SEQ,EXAMPLE_AG_SEQ,$PRED,1" >> $OUTPUT_DIR/predictions.csv
        
        echo "===== PREDICTIONS.CSV CONTENT ====="
        cat $OUTPUT_DIR/predictions.csv
        
        echo "===== OUTPUT FILES ====="
        ls -la $OUTPUT_DIR/
        
        echo "===== COPY TO EXECUTION DIR ====="
        cp -r $OUTPUT_DIR .
        ls -la outputs/
    >>>
    
    output {
        Array[File] predictions = glob("outputs/predictions.csv")
        Array[File] output_logs = glob("outputs/output.txt")
    }
    
    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        cpu: cpu_threads
        disk: disk_space_gb + "GB"
    }
}
