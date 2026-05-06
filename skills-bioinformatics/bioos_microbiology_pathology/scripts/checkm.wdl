version 1.0

workflow Tool_Checkm {
  input {
    String extension
    String thread
    File inputfasta
  }

  call Checkm {
    input:
      extension = extension,
      thread = thread,
      inputfasta = inputfasta
  }

  output {
    File genome_statistics = Checkm.genome_statistics
  }
}

task Checkm {
  input {
    String extension
    String thread
    File inputfasta
  }

  command {
    mkdir -p input
    cp ${inputfasta} input
    mkdir -p tmp
    mkdir result
    checkm lineage_wf -t ${thread} -x ${extension} ./input ./result --tmpdir ./tmp > genome_statistics.txt
    
  }

  output {
    File genome_statistics = "genome_statistics.txt"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/checkm:1.1.3"
    cpu: 20
    memory: "50G"
  }
}
