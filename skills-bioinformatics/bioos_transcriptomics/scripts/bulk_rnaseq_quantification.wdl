version 1.0

task star {
    input {
        # Command parameters
        File fastq1
        File? fastq2
        String sample_id

        # STAR parameters
        File star_index
        Int? outFilterMultimapNmax
        Int? alignSJoverhangMin
        Int? alignSJDBoverhangMin
        Int? outFilterMismatchNmax
        Float? outFilterMismatchNoverLmax
        Int? alignIntronMin
        Int? alignIntronMax
        Int? alignMatesGapMax
        String? outFilterType
        Float? outFilterScoreMinOverLread
        Float? outFilterMatchNminOverLread
        Int? limitSjdbInsertNsj
        String? outSAMstrandField
        String? outFilterIntronMotifs
        String? alignSoftClipAtReferenceEnds
        String? quantMode
        String? outSAMattrRGline
        String? outSAMattributes
        File? varVCFfile
        String? waspOutputMode
        Int? chimSegmentMin
        Int? chimJunctionOverhangMin
        String? chimOutType
        Int? chimMainSegmentMultNmax
        Int? chimOutJunctionFormat
        File? sjdbFileChrStartEnd

        # Runtime parameters
        String dockerImage = "registry-vpc.miracle.ac.cn/broad/gtex-rnaseq:V10"
        Int memory = 64
        Int disk_space = 500
        Int num_threads = 16
        Boolean num_preempt = true
    }

    parameter_meta {
        sample_id: "Sample identifier, the prefix use for each output file name"
        fastq1: "Paths to the FASTQ files (Read1)"
        fastq2: "Paths to the FASTQ files (Read2)"
        star_index: "Path to the directory (tar) containing the STAR index"
        memory: "Amount of memory to allocate to the STAR"   
        disk_space: "Amount of disk space to allocate to the STAR"
        num_threads: "Amount of cores to allocate to the STAR"
        num_preempt: "Whether to set preemption when running the STAR"
        dockerImage: "The docker image when running the STAR"
    }

    command {
        set -e pipefail

        if [[ ${fastq1} == *".tar" || ${fastq1} == *".tar.gz" ]]; then
            tar -xvvf ${fastq1}
            fastq1_abs=$(for f in *_1.fastq*; do echo "$(pwd)/$f"; done | paste -s -d ',')
            fastq2_abs=$(for f in *_2.fastq*; do echo "$(pwd)/$f"; done | paste -s -d ',')
            if [[ $fastq1_abs == *"*_1.fastq*" ]]; then  # no paired-end FASTQs found; check for single-end FASTQ
                fastq1_abs=$(for f in *.fastq*; do echo "$(pwd)/$f"; done | paste -s -d ',')
                fastq2_abs=''
            fi
        else
            # make sure paths are absolute
            fastq1_abs=${fastq1}
            fastq2_abs=${fastq2}
            if [[ $fastq1_abs != /* ]]; then
                fastq1_abs=$PWD/$fastq1_abs
                fastq2_abs=$PWD/$fastq2_abs
            fi
        fi

        echo "FASTQs:"
        echo $fastq1_abs
        echo $fastq2_abs

        # extract index
        echo $(date +"[%b %d %H:%M:%S] Extracting STAR index")
        mkdir -p star_index
        tar -xvvf ${star_index} -C star_index --strip-components=1

        mkdir -p star_out
        # placeholders for optional outputs
        touch star_out/${sample_id}.Aligned.toTranscriptome.out.bam
        touch star_out/${sample_id}.Chimeric.out.sorted.bam
        touch star_out/${sample_id}.Chimeric.out.sorted.bam.bai
        touch star_out/${sample_id}.ReadsPerGene.out.tab  # run_STAR.py will gzip

        /src/run_STAR.py \
            star_index $fastq1_abs $fastq2_abs ${sample_id} \
            --output_dir star_out \
            ${"--outFilterMultimapNmax " + outFilterMultimapNmax} \
            ${"--alignSJoverhangMin " + alignSJoverhangMin} \
            ${"--alignSJDBoverhangMin " + alignSJDBoverhangMin} \
            ${"--outFilterMismatchNmax " + outFilterMismatchNmax} \
            ${"--outFilterMismatchNoverLmax " + outFilterMismatchNoverLmax} \
            ${"--alignIntronMin " + alignIntronMin} \
            ${"--alignIntronMax " + alignIntronMax} \
            ${"--alignMatesGapMax " + alignMatesGapMax} \
            ${"--outFilterType " + outFilterType} \
            ${"--outFilterScoreMinOverLread " + outFilterScoreMinOverLread} \
            ${"--outFilterMatchNminOverLread " + outFilterMatchNminOverLread} \
            ${"--limitSjdbInsertNsj " + limitSjdbInsertNsj} \
            ${"--outSAMstrandField " + outSAMstrandField} \
            ${"--outFilterIntronMotifs " + outFilterIntronMotifs} \
            ${"--alignSoftClipAtReferenceEnds " + alignSoftClipAtReferenceEnds} \
            ${"--quantMode " + quantMode} \
            ${"--outSAMattrRGline " + outSAMattrRGline} \
            ${"--outSAMattributes " + outSAMattributes} \
            ${"--varVCFfile " + varVCFfile} \
            ${"--waspOutputMode " + waspOutputMode} \
            ${"--chimSegmentMin " + chimSegmentMin} \
            ${"--chimJunctionOverhangMin " + chimJunctionOverhangMin} \
            ${"--chimOutType " + chimOutType} \
            ${"--chimMainSegmentMultNmax " + chimMainSegmentMultNmax} \
            ${"--chimOutJunctionFormat " + chimOutJunctionFormat} \
            ${"--sjdbFileChrStartEnd " + sjdbFileChrStartEnd} \
            --threads ${num_threads}

        mv "star_out/${sample_id}._STARpass1/${sample_id}.SJ.pass1.out.tab.gz" star_out
    }

    output {
        File bam_file = "star_out/${sample_id}.Aligned.sortedByCoord.out.bam"
        File bam_index = "star_out/${sample_id}.Aligned.sortedByCoord.out.bam.bai"
        File transcriptome_bam = "star_out/${sample_id}.Aligned.toTranscriptome.out.bam"
        File chimeric_junctions = "star_out/${sample_id}.Chimeric.out.junction.gz"
        File chimeric_bam_file = "star_out/${sample_id}.Chimeric.out.sorted.bam"
        File chimeric_bam_index = "star_out/${sample_id}.Chimeric.out.sorted.bam.bai"
        File read_counts = "star_out/${sample_id}.ReadsPerGene.out.tab.gz"
        File junctions = "star_out/${sample_id}.SJ.out.tab.gz"
        File junctions_pass1 = "star_out/${sample_id}.SJ.pass1.out.tab.gz"
        Array[File] logs = ["star_out/${sample_id}.Log.final.out", "star_out/${sample_id}.Log.out", "star_out/${sample_id}.Log.progress.out"]
    }

    runtime {
        docker: "${dockerImage}"
        memory: "${memory}GB"
        disk: "${disk_space}GB"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
        continueOnReturnCode: 0
    }

    meta {
        author: "Francois Aguet"
        parameters: "Consult the instruction for the GTEx pipeline (https://github.com/broadinstitute/gtex-pipeline/blob/master/TOPMed_RNAseq_pipeline.md) for more information."
    }
}

task rnaseqc2 {
    input {
        # Command parameters
        File genes_gtf
        String sample_id

        # rnaseqc2 parameters
        File bam_file
        String? strandedness 
        File? intervals_bed

        # Runtime parameters
        String dockerImage = "registry-vpc.miracle.ac.cn/broad/gtex-rnaseq:V10"
        Int memory = 8
        Int disk_space = 100
        Int num_threads = 4
        Boolean num_preempt = true
    }

    parameter_meta {
        sample_id: "Sample identifier, the prefix use for each output file name"
        genes_gtf: "Path to the collapsed, gene-level GTF"
        memory: "Amount of memory to allocate to the rnaseqc2"
        disk_space: "Amount of disk space to allocate to the rnaseqc2"
        num_threads: "Amount of cores to allocate to the rnaseqc2"
        num_preempt: "Whether to set preemption when running the rnaseqc2"
        dockerImage: "The docker image when running the rnaseqc2"
        bam_file: "Path to the BAM file created by the STAR"
    }

    command {
        set -e pipefail
        echo $(date +"[%b %d %H:%M:%S] Running RNA-SeQC 2")
        touch ${sample_id}.fragmentSizes.txt
        
        /src/run_rnaseqc.py \
            ${genes_gtf} ${bam_file} ${sample_id} \
            -o . \
            ${"--bed " + intervals_bed} \
            ${"--stranded " + strandedness} 

        echo "  * compressing outputs"
        gzip *.gct
        echo $(date +"[%b %d %H:%M:%S] done")
    }

    output {
        File gene_tpm = "${sample_id}.gene_tpm.gct.gz"
        File gene_counts = "${sample_id}.gene_reads.gct.gz"
        File exon_counts = "${sample_id}.exon_reads.gct.gz"
        File metrics = "${sample_id}.metrics.tsv"
        File insertsize_distr = "${sample_id}.fragmentSizes.txt"
    }

    runtime {
        docker: "${dockerImage}"
        memory: "${memory}GB"
        disk: "${disk_space}GB"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
        continueOnReturnCode: 0
    }

    meta {
        author: "Francois Aguet"
        parameters: "Consult the instruction for the GTEx pipeline (https://github.com/broadinstitute/gtex-pipeline/blob/master/TOPMed_RNAseq_pipeline.md) for more information"
    }
}

task rsem {
    input {
        # Command parameters
        String sample_id

        # Runtime parameters
        String dockerImage = "registry-vpc.miracle.ac.cn/broad/gtex-rnaseq:V10"
        Int memory = 32
        Int disk_space = 300
        Int num_threads = 8
        Boolean num_preempt = true
        
        # RSEM parameters
        File transcriptome_bam
        File rsem_reference
        Int? max_frag_len
        String? estimate_rspd
        String? is_stranded
        String? paired_end
        String? calc_ci
    }

    parameter_meta {
        sample_id: "Sample identifier, the prefix use for each output file name"
        transcriptome_bam: "Path to the BAM file aligned to transcriptome created by the STAR"
        rsem_reference: "Path to the directory (tar) containing the RSEM reference"
        memory: "Amount of memory to allocate to the RSEM"
        disk_space: "Amount of disk space to allocate to the RSEM"
        num_threads: "Amount of cores to allocate to the RSEM"
        num_preempt: "Whether to set preemption when running the RSEM"
        dockerImage: "The docker image when running the RSEM"
    }
    
    command {
        set -e pipefail
        
        # extract index  
        mkdir -p rsem_reference
        tar -vxf ${rsem_reference} -C rsem_reference --strip-components=1

        /src/run_RSEM.py \
            ${"--max_frag_len " + max_frag_len} \
            ${"--estimate_rspd " + estimate_rspd} \
            ${"--is_stranded " + is_stranded} \
            ${"--paired_end " + paired_end} \
            ${"--calc_ci " + calc_ci} \
            --threads ${num_threads} \
            rsem_reference ${transcriptome_bam} ${sample_id}
        gzip *.results
    }

    output {
        File genes="${sample_id}.rsem.genes.results.gz"
        File isoforms="${sample_id}.rsem.isoforms.results.gz"
    }

    runtime {
        docker: "${dockerImage}"
        memory: "${memory}GB"
        disk: "${disk_space}GB"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
        continueOnReturnCode: 0
    }

    meta {
        author: "David Wu"
        parameters: "Consult the instruction for the GTEx pipeline (https://github.com/broadinstitute/gtex-pipeline/blob/master/TOPMed_RNAseq_pipeline.md) for more information"
    }
}

workflow bulk_rnaseq_quantification {
    input {
        File fastq1
        File? fastq2
        File genes_gtf
        String sample_id
        String paired_end
        File star_index
        File rsem_reference
    }
    
    parameter_meta {
        sample_id: "Sample identifier, the prefix use for each output file name"
        fastq1: "Path to the FASTQ files (Read1)"
        fastq2: "Path to the FASTQ files (Read2)"
        genes_gtf: "Path to the collapsed, gene-level GTF"
        paired_end: "true/false"
        star_index: "Path to the STAR index archive"
        rsem_reference: "Path to the RSEM reference archive"
    }

    call star {
        input: 
            sample_id=sample_id,
            fastq1=fastq1,
            fastq2=fastq2,
            star_index=star_index
    }

    call rnaseqc2 {
        input:
            bam_file=star.bam_file,
            genes_gtf=genes_gtf,
            sample_id=sample_id
    }

    call rsem {
        input:
            transcriptome_bam=star.transcriptome_bam,
            sample_id=sample_id,
            is_stranded="false",
            paired_end=paired_end,
            rsem_reference=rsem_reference
    }

    output {
        #star
        File bam_file=star.bam_file
        File bam_index=star.bam_index
        File transcriptome_bam=star.transcriptome_bam
        File chimeric_junctions=star.chimeric_junctions
        File chimeric_bam_file=star.chimeric_bam_file
        File read_counts=star.read_counts
        File junctions=star.junctions
        File junctions_pass1=star.junctions_pass1
        Array[File] logs=star.logs
        #rnaseqc
        File gene_tpm=rnaseqc2.gene_tpm
        File gene_counts=rnaseqc2.gene_counts
        File exon_counts=rnaseqc2.exon_counts
        File metrics=rnaseqc2.metrics
        File insertsize_distr=rnaseqc2.insertsize_distr
        #rsem
        File genes=rsem.genes
        File isoforms=rsem.isoforms
    }

    meta {
        author: "Francois Aguet"
        source: "the GTEx pipeline (https://github.com/broadinstitute/gtex-pipeline/blob/master/TOPMed_RNAseq_pipeline.md)"
    }
}
