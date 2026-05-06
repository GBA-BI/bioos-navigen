version 1.0

workflow Tool_CD_HIT {
  input {
    File fasta
    Float identity
    Int threads
    Int word_length
  }

  call cdhit {
    input:
      fasta = fasta,
      identity = identity,
      threads = threads,
      word_length = word_length
  }

  output {
    File output_tgz = cdhit.output_tgz
  }
}

task cdhit {
  input {
    File fasta
    Float identity
    Int threads
    Int word_length
  }

  command {
    cd-hit -i ${fasta} -o nr.fas -c ${identity} -n ${word_length} -T ${threads} -M 100000
    tar zcvf output.tgz nr.*
  }

  output {
    File output_tgz = "output.tgz"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/cdhit:4.7-1"
    cpu: 16
    memory: "100GB"
  }
}
