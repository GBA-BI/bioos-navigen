version 1.0

workflow Tool_PILER_CR {
  input {
    File fasta
  }

  call pilercr { input: fasta = fasta }

  output {
    File pilercr_result = pilercr.pilercr_output
  }
}

task pilercr {
  input {
    File fasta
  }

  # 让 pilercr 直接输出到当前目录
  command <<<
    set -e
    /BioBin/pilercr1.06/pilercr -in ~{fasta} -out pilercr.txt
  >>>

  output {
    File pilercr_output = "pilercr.txt"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/metatools:lite"
    cpu: 2
    memory: "3 GB"
  }
}
