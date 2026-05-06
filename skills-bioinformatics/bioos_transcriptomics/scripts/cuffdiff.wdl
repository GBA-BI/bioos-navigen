version 1.0

workflow Tool_Cuffdiff {
  input {
    File gtf
    File sam_1
    File sam_2
    File fasta
    String threads
    String? labels
    Boolean time_series
    Boolean multi_read_correct
    String library_type
    String FDR
  }

  String time = if time_series then "--time-series" else ""
  String correct = if multi_read_correct then "--multi-read-correct" else ""

  call cufdiff {
    input:
      gtf = gtf,
      sam_1 = sam_1,
      sam_2 = sam_2,
      fasta = fasta,
      threads = threads,
      labels = labels,
      time = time,
      correct = correct,
      library_type = library_type,
      FDR = FDR
  }
}

task cufdiff {
  input {
    File gtf
    File sam_1
    File sam_2
    File fasta
    String threads
    String? labels
    String time
    String correct
    String library_type
    String FDR
  }

  command {
    mkdir -p output
    

    cuffdiff \
      --FDR ${FDR} \
      --labels ${labels} \
      --library-type ${library_type} \
      -p ${threads} \
      ${time} \
      ${correct} \
      -b ${fasta} \
      -o output \
      ${gtf} \
      ~{sam_1} ~{sam_2}


  }
	output{
		Array[File] files=glob("output/**")
	}
  runtime {
    docker:"registry-vpc.miracle.ac.cn/nmdc/mrna:latest"
    cpu: 16
    memory: "24 GB"
  }
}
