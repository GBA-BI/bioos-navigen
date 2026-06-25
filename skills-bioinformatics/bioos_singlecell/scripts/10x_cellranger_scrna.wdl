version 1.0

workflow Cellranger_10x_Workflow {
    input {
        String sample_name            
        File fastq1                  
        File fastq2                  
        String species               
        
        Int memory_gb = 64          
        Int disk_gb = 500           
        Int cpu = 32               
    }
    File ref_index = if species == "GRCh38" then "s3://gznl-open-data-references/10xgenomics/reference/refdata-gex-GRCh38-2020-A.tar.gz"
                      else "s3://gznl-open-data-references/10xgenomics/reference/refdata-gex-mm10-2020-A.tar.gz"
    call CellrangerCount {
        input:
            sample_name = sample_name,
            fastq1 = fastq1,
            fastq2 = fastq2,
            ref_index = ref_index,
            memory_gb = memory_gb,
            disk_gb = disk_gb,
            cpu = cpu
    }

    output {
        File output_result = CellrangerCount.output_result
        File web_summary = CellrangerCount.web_summary                                
        File metrics_summary = CellrangerCount.metrics_summary                        
        File filtered_feature_bc_matrix_h5 = CellrangerCount.filtered_feature_bc_matrix_h5    
        File filtered_feature_bc_matrix_mex = CellrangerCount.filtered_feature_bc_matrix_mex  
        File raw_feature_bc_matrix_h5 = CellrangerCount.raw_feature_bc_matrix_h5            
        File raw_feature_bc_matrix_mex = CellrangerCount.raw_feature_bc_matrix_mex          
        File output_bam = CellrangerCount.output_bam                                
        File output_bam_index = CellrangerCount.output_bam_index                    
    }
}

task CellrangerCount {
    input {
        String sample_name
        File fastq1
        File fastq2
        File ref_index
        Int memory_gb
        Int disk_gb
        Int cpu
        Int expect_cells = 3000     
        Boolean nosecondary = true  
        String chemistry = "auto"    
    }

    String expect_cells_cmd = "--expect-cells=" + expect_cells
    String nosecondary_cmd = if nosecondary then "--nosecondary" else ""
    String chemistry_cmd = "--chemistry=" + chemistry

    command <<<
        set -euo pipefail
        
        mkdir -p ref_index
        tar -xzf ~{ref_index} -C ref_index/
        
        REF_DIR=$(ls ref_index)
        
        mkdir -p fastqs
        cp ~{fastq1} fastqs/~{sample_name}_S1_L001_R1_001.fastq.gz
        cp ~{fastq2} fastqs/~{sample_name}_S1_L001_R2_001.fastq.gz

        cellranger count \
            --id=~{sample_name} \
            --fastqs=fastqs \
            --transcriptome=ref_index/$REF_DIR \
            --localcores=~{cpu} \
            --localmem=~{memory_gb} \
            ~{expect_cells_cmd} \
            ~{nosecondary_cmd} \
            ~{chemistry_cmd}

        tar -zcvf ~{sample_name}.tar.gz ~{sample_name}

        cd ~{sample_name}/outs
  
        tar -czf filtered_feature_bc_matrix.tar.gz filtered_feature_bc_matrix
        tar -czf raw_feature_bc_matrix.tar.gz raw_feature_bc_matrix
    >>>

    runtime {
        docker: "registry-vpc.miracle.ac.cn/broad/cromwell-cellranger:6.1.2"
        memory: "~{memory_gb} GB"
        disks: "local-disk ~{disk_gb} SSD"
        cpu: cpu
    }

    output {
        File output_result = "~{sample_name}.tar.gz"
        File web_summary = "~{sample_name}/outs/web_summary.html"
        File metrics_summary = "~{sample_name}/outs/metrics_summary.csv"
        File filtered_feature_bc_matrix_h5 = "~{sample_name}/outs/filtered_feature_bc_matrix.h5"
        File filtered_feature_bc_matrix_mex = "~{sample_name}/outs/filtered_feature_bc_matrix.tar.gz"
        File raw_feature_bc_matrix_h5 = "~{sample_name}/outs/raw_feature_bc_matrix.h5"
        File raw_feature_bc_matrix_mex = "~{sample_name}/outs/raw_feature_bc_matrix.tar.gz"
        File output_bam = "~{sample_name}/outs/possorted_genome_bam.bam"
        File output_bam_index = "~{sample_name}/outs/possorted_genome_bam.bam.bai"
    }
}
