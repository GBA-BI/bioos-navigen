version 1.0

workflow Tool_BWA_MEM {
  input {
    File ref
    File fq1
    File fq2 
    String threads   
    String other_para  
  }

  call bwa_mem {
    input: 
      ref = ref,
      fq1 = fq1,
      fq2 = fq2,
      threads = threads,
      other_para = other_para
  }
}

task bwa_mem {
  input {
    File ref
    File fq1
    File fq2 
    String threads   
    String other_para  
  }

  command {
    /BioBin/bwa/bwa index ${ref} -p genome 
    /BioBin/bwa/bwa mem -P -t ${threads} ${other_para} -o output.sam ./genome ${fq1} ${fq2}  
    mkdir -p ../../iwandresultfiles/
    cp -r output.sam ../../iwandresultfiles/
  }

  output {
    File sam_output = "output.sam"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/bwa:latest"
    cpu: 16
    memory: "24GB"
  }
}
