version 1.0

workflow Tool_XSTREAM {

  input {
    File fasta
    String i
    String I
    String g
    String e
    String D
    String m
    String t
    String? x
  }

  call xstream {
    input:
      fasta = fasta,
      i = i,
      I = I,
      g = g,
      e = e,
      D = D,
      m = m,
      t = t,
      x = x
  }

  output {
    Array[File] html_reports = xstream.html_reports
    File? log = xstream.log
  }
}

task xstream {
  input {
    File fasta
    String i
    String I
    String g
    String e
    String D
    String m
    String t
    String? x
  }

  command <<<
    set -euo pipefail
    java -jar /BioBin/xstream/xstream.jar ~{fasta} -I~{I} ~{if defined(x) then "-x " + x else ""} -D~{D} -e~{e} -g~{g} -i~{i} -m~{m} -t~{t} 2>&1 | tee xstream.run.log
  >>>

  output {
    Array[File] html_reports = glob("*.html")
    File log = "xstream.run.log"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/xstream:latest"
    cpu: 8
    memory: "24G"
  }
}


