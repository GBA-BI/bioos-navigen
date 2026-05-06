version 1.0

workflow covfit_sars_cov2_fitness_prediction {
    input {
        # 输入文件
        File input_fasta
        String sample_name
        
        # 可选参数
        Int fold_number = 0
        Boolean run_dms = false
        Int batch_size = 4
        Boolean use_gpu = false
        
        # 运行参数（带默认值）
        String docker_image = "registry-vpc.miracle.ac.cn/gznl/covfit:v1.0"
        Int memory_gb = 32
        Int disk_space_gb = 200
        Int cpu_threads = 8
    }
    
    call covfit_run {
        input:
            input_fasta = input_fasta,
            sample_name = sample_name,
            fold_number = fold_number,
            run_dms = run_dms,
            batch_size = batch_size,
            use_gpu = use_gpu,
            docker_image = docker_image,
            memory_gb = memory_gb,
            disk_space_gb = disk_space_gb,
            cpu_threads = cpu_threads
    }
    
    output {
        File predictions_tsv = covfit_run.predictions_tsv
        File dms_results_tsv = covfit_run.dms_results_tsv
        String summary_stats = covfit_run.summary_stats
    }
}

task covfit_run {
    input {
        File input_fasta
        String sample_name
        
        Int fold_number
        Boolean run_dms
        Int batch_size
        Boolean use_gpu
        
        # 运行参数
        String docker_image
        Int memory_gb
        Int disk_space_gb
        Int cpu_threads
    }
    
    command <<<
        # 在执行目录创建输出目录
        OUTPUT_DIR="$(pwd)/outputs"
        mkdir -p ${OUTPUT_DIR}
        
        # 进入 CoVFit CLI 目录运行命令
        cd /app/CoVFit_CLI
        
        # 构建基础命令
        CMD="/app/CoVFit_CLI/covfit_cli"
        CMD="${CMD} --input ~{input_fasta}"
        CMD="${CMD} --outdir ${OUTPUT_DIR}"
        CMD="${CMD} --fold ~{fold_number}"
        CMD="${CMD} --batch ~{batch_size}"
        
        # 可选参数
        if [ "~{run_dms}" = "true" ]; then
            CMD="${CMD} --dms"
        fi
        
        if [ "~{use_gpu}" = "true" ]; then
            CMD="${CMD} --gpu"
        fi
        
        # 执行命令
        echo "Running: ${CMD}"
        eval ${CMD}
        
        # 回到执行目录
        cd -
        
        # 列出输出目录内容
        echo "=== Output directory contents ==="
        ls -la ${OUTPUT_DIR}/
        echo "==============================="
        
        # 查找输出文件（只获取文件名，不要路径）
        OUTPUT_FILE=$(basename $(ls ${OUTPUT_DIR}/CoVFit_Predictions_fold_*.tsv 2>/dev/null || ls ${OUTPUT_DIR}/CoVFit_Predictions_Fold_*.tsv 2>/dev/null))
        
        echo "Found output file: ${OUTPUT_FILE}"
        
        # 如果请求了 DMS 结果，分离文件
        if [ "~{run_dms}" = "true" ] && [ -n "${OUTPUT_FILE}" ]; then
            # 提取 DMS 结果 (列 3-1550)
            cut -f 1,3-1550 ${OUTPUT_DIR}/${OUTPUT_FILE} > ${OUTPUT_DIR}/DMS_Results_~{sample_name}.tsv
        fi
        
        # 生成统计信息（只使用文件名，不使用完整路径）
        NUM_SEQS=$(grep -c '^>' ~{input_fasta})
        echo "CoVFit Analysis Summary: Sample=~{sample_name}, Fold=~{fold_number}, DMS=~{run_dms}, BatchSize=~{batch_size}, GPU=~{use_gpu}, Sequences=${NUM_SEQS}, OutputFile=${OUTPUT_FILE}" > summary_stats.txt
        
        # 复制输出文件到执行目录
        if [ -n "${OUTPUT_FILE}" ]; then
            cp ${OUTPUT_DIR}/${OUTPUT_FILE} predictions_tsv.tsv
            echo "Copied predictions_tsv.tsv successfully"
        else
            echo "ERROR: No output file found!" >&2
            ls -la ${OUTPUT_DIR}/ >&2
            exit 1
        fi
        
        # 处理 DMS 输出
        if [ "~{run_dms}" = "true" ] && [ -f "${OUTPUT_DIR}/DMS_Results_~{sample_name}.tsv" ]; then
            cp ${OUTPUT_DIR}/DMS_Results_~{sample_name}.tsv dms_results_tsv.tsv
            echo "Copied dms_results_tsv.tsv successfully"
        else
            echo "No DMS results" > dms_results_tsv.tsv
            echo "Created empty dms_results_tsv.tsv"
        fi
        
        # 验证文件是否存在
        echo "=== Final verification ==="
        ls -la predictions_tsv.tsv
        ls -la dms_results_tsv.tsv
        ls -la summary_stats.txt
        echo "========================="
        
        # 显示输出文件内容预览
        echo "=== Output file preview ==="
        head -5 predictions_tsv.tsv
        echo "==========================="
    >>>
    
    output {
        File predictions_tsv = "predictions_tsv.tsv"
        File dms_results_tsv = "dms_results_tsv.tsv"
        String summary_stats = read_string("summary_stats.txt")
    }
    
    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}
