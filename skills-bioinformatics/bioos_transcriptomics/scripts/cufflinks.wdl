version 1.0

workflow Tool_Cufflinks {
  input {
    File gtf
    File bam
    Int threads = 1
  }

  call cufflinks {
    input:
      gtf = gtf,
      bam = bam,
      threads = threads
  }

  output {
    File transcripts_gtf = cufflinks.transcripts_gtf
    File isoforms_fpkm_tracking = cufflinks.isoforms_fpkm_tracking
    File genes_fpkm_tracking = cufflinks.genes_fpkm_tracking
    File skipped_gtf = cufflinks.skipped_gtf
  }
}

task cufflinks {
  input {
    File gtf
    File bam
    Int threads = 1
  }

  command {
    cufflinks -p ${threads} -G ${gtf} -o output ${bam}
    
    mkdir -p ../../iwandresultfiles/
    cp -r output/* ../../iwandresultfiles/
  }

  output {
    File transcripts_gtf = "output/transcripts.gtf"
    File isoforms_fpkm_tracking = "output/isoforms.fpkm_tracking"
    File genes_fpkm_tracking = "output/genes.fpkm_tracking"
    File skipped_gtf = "output/skipped.gtf"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/mrna:latest"
    cpu: 16
    memory: "24 GB"
  }
}
