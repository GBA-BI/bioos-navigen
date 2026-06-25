version 1.0

workflow Cellranger_VDJ_Workflow {
    input {

        String sample_name           
        File fastq1                 
        File fastq2                  
        String species                 
        

        Int memory_gb = 64          
        Int disk_gb = 500         
        Int cpu = 32               
    }
    

    File ref_index = if species == "GRCh38" then "s3://gznl-open-data-references/10xgenomics/reference/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0.tar.gz"
                      else "s3://gznl-open-data-references/10xgenomics/reference/refdata-cellranger-vdj-GRCm38-alts-ensembl-7.0.0.tar.gz"

    call CellrangerVDJ {
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
        File output_result = CellrangerVDJ.output_result
        File web_summary = CellrangerVDJ.web_summary
        File clonotypes_csv = CellrangerVDJ.clonotypes_csv
        File consensus_fasta = CellrangerVDJ.consensus_fasta
        File all_contig_fasta = CellrangerVDJ.all_contig_fasta
        File all_contig_annotations_csv = CellrangerVDJ.all_contig_annotations_csv
        File filtered_contig_annotations_csv = CellrangerVDJ.filtered_contig_annotations_csv
        File consensus_annotations_csv = CellrangerVDJ.consensus_annotations_csv
        File metrics_summary_csv = CellrangerVDJ.metrics_summary_csv
        File airr_rearrangement_tsv = CellrangerVDJ.airr_rearrangement_tsv
        File filtered_contig_fasta = CellrangerVDJ.filtered_contig_fasta
        File all_contig_annotation_bed  =CellrangerVDJ.all_contig_annotation_bed
    }
}

task CellrangerVDJ {
    input {
        String sample_name
        File fastq1
        File fastq2
        File ref_index
        Int memory_gb
        Int disk_gb
        Int cpu
        Boolean nosecondary = true  
        String chemistry = "auto"    
    }

    command <<<
        set -euo pipefail
        
       
        mkdir -p ref_index
        tar -xzf ~{ref_index} -C ref_index/
        
        REF_DIR=$(ls ref_index)
        

        mkdir -p fastqs
        cp ~{fastq1} fastqs/~{sample_name}_S1_L001_R1_001.fastq.gz
        cp ~{fastq2} fastqs/~{sample_name}_S1_L001_R2_001.fastq.gz

        # 运行cellranger vdj
        cellranger vdj \
            --id=~{sample_name} \
            --fastqs=fastqs \
            --reference=ref_index/$REF_DIR \
            --localcores=~{cpu} \
            --localmem=~{memory_gb}
            
        # 打包输出目录
        tar -zcvf ~{sample_name}.tar.gz ~{sample_name}/outs/
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
        File clonotypes_csv = "~{sample_name}/outs/clonotypes.csv"
        File consensus_fasta = "~{sample_name}/outs/consensus.fasta"
        File all_contig_fasta = "~{sample_name}/outs/all_contig.fasta"
        File all_contig_annotations_csv = "~{sample_name}/outs/all_contig_annotations.csv"
        File filtered_contig_annotations_csv = "~{sample_name}/outs/filtered_contig_annotations.csv"
        File consensus_annotations_csv = "~{sample_name}/outs/consensus_annotations.csv"
        File metrics_summary_csv = "~{sample_name}/outs/metrics_summary.csv"
        File airr_rearrangement_tsv = "~{sample_name}/outs/airr_rearrangement.tsv"
        File filtered_contig_fasta = "~{sample_name}/outs/filtered_contig.fasta"
        File all_contig_annotation_bed = "~{sample_name}/outs/all_contig_annotations.bed"
    }
}
