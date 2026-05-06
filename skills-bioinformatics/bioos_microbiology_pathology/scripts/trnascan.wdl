version 1.0

workflow Tool_tRNAscanSEV1 {

  input {
    File genome
    String other_para = ""
  }

  call tRNAscanSE {
    input:
      genome = genome,
      other_para = other_para
  }

  output {
    File tRNA_out = tRNAscanSE.tRNA_out
    File tRNA_stats = tRNAscanSE.tRNA_stats
  }
}

task tRNAscanSE {

  input {
    File genome
    String other_para = ""
  }

  command <<<
    set -euo pipefail
    tRNAscan-SE -qQ -Y -B -o tRNA.out -m tRNA.stats ~{other_para} ~{genome}
  >>>

  output {
    File tRNA_out = "tRNA.out"
    File tRNA_stats = "tRNA.stats"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/trnascan_se:latest"
    cpu: 8
    memory: "10GB"
  }
}
