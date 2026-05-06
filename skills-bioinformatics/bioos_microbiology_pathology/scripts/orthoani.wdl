version 1.0

workflow Tool_OrthoANI {
  input {
    File fasta1
    File fasta2
    Int threads = 4
  }

  call orthoANI {
    input:
      fasta1 = fasta1,
      fasta2 = fasta2,
      threads = threads
  }

  output {
    File ani_txt    = orthoANI.ANI_txt
    File ggdc_txt   = orthoANI.GGDC_txt
    File report_txt = orthoANI.report_txt
  }
}

task orthoANI {
  input {
    File fasta1
    File fasta2
    Int  threads
  }

  command <<<
    # 屏蔽 JVM 提示
    unset _JAVA_OPTIONS

    set -euo pipefail

    java -jar /BioBin/OrthoANI/OAT_cmd.jar \
      -blastplus_dir /BioBin/ncbi-blast-2.10.0+/bin \
      -method ani \
      -fasta1 ~{fasta1} \
      -fasta2 ~{fasta2} \
      -num_threads ~{threads} \
      > ANI.txt

    java -jar /BioBin/OrthoANI/OAT_cmd.jar \
      -blastplus_dir /BioBin/ncbi-blast-2.10.0+/bin \
      -method ggdc \
      -fasta1 ~{fasta1} \
      -fasta2 ~{fasta2} \
      -num_threads ~{threads} \
      > GGDC.txt

    # 生成汇总报告
    awk '/GGDC/ { printf "GGDC\t%.4f\n", $3*100 }' GGDC.txt  > OrthoANI.report.txt
    awk '/OrthoANI/ { print "ANI"$2"\t"$3 }'    ANI.txt     >> OrthoANI.report.txt

    cat >> OrthoANI.report.txt <<'EOF'

(Recommended Use GGDC2. The GGDC is a state-of-the-art in silico method for genome-to-genome comparison, thus reliably mimicking conventional DDH, except for its pitfalls.)

References:
1. Meier-Kolthoff, J.P., Auch, A.F., Klenk, H.-P., Göker, M. Genome sequence-based species delimitation with confidence intervals and improved distance functions. BMC Bioinformatics 14:60, 2013.
2. Imchang Lee, Yeong Ouk Kim, Sang-Cheol Park, Jongsik Chun: OrthoANI: An improved algorithm and software for calculating average nucleotide identity. International Journal of Systematic and Evolutionary Microbiology, 2016.
EOF
  >>>

  output {
    File ANI_txt   = "ANI.txt"
    File GGDC_txt  = "GGDC.txt"
    File report_txt = "OrthoANI.report.txt"
  }

  runtime {
    docker : "registry-vpc.miracle.ac.cn/nmdc/orthoani:latest"
    cpu    : threads
    memory : "10 GB"
  }
}
