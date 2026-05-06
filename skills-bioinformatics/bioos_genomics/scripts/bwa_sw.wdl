version 1.0

workflow Tool_BWA_SW {
  input {
    File ref
    File fq1
    File fq2 
    String threads   
  }

  call bwa_sw {
    input: 
      ref = ref,
      fq1 = fq1,
      fq2 = fq2,
      threads = threads
  }
}

task bwa_sw {
  input {
    File ref
    File fq1
    File fq2 
    String threads   
  }

  command {
    /BioBin/bwa/bwa index ${ref} -p genome 
    /BioBin/bwa/bwa bwasw -f output.sam -t ${threads} ./genome ${fq1} ${fq2}
    mkdir -p ../../iwandresultfiles/
    cp -r output.sam ../../iwandresultfiles/
  }
  
  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/bwa:latest"
    cpu: 16
    memory: "24GB"
  }
  
  output {
    File sam_output = "output.sam"
  }
}
