version 1.0

workflow Tool_BWA_ALN {
  input {
    File ref
    File fq1
    File fq2 
    Int threads
  }

  call bwa_aln {
    input: 
      ref = ref,
      fq1 = fq1,
      fq2 = fq2,
      threads = threads
  }

  output {
    File output_sam = bwa_aln.output_sam
  }
}

task bwa_aln {
  input {
    File ref
    File fq1
    File fq2 
    Int threads
  }

  command {
    /BioBin/bwa/bwa index ${ref} -p genome 
    /BioBin/bwa/bwa aln -t ${threads} ./genome ${fq1} > leftRead.sai
    /BioBin/bwa/bwa aln -t ${threads} ./genome ${fq2} > rightRead.sai
    /BioBin/bwa/bwa sampe -f output.sam ./genome leftRead.sai rightRead.sai ${fq1} ${fq2} 
    
    mkdir -p ../../iwandresultfiles/
    cp -r output.sam ../../iwandresultfiles/
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/bwa:latest"
    cpu: 16
    memory: "24 GB"
  }

  output {
    File output_sam = "output.sam"
  }
}
