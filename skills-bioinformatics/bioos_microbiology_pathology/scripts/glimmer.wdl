version 1.0

workflow Tool_Glimmer {
  input {
    File input_fasta
    Int args_max_olap
    Int args_gene_len
    Int args_threads
  }

  call glimmer as glimmer {
    input:
      genome_fasta = input_fasta,
      args_max_olap = args_max_olap,
      args_gene_len = args_gene_len,
      args_threads = args_threads
  }

  output {
    Array[File] run_files = glimmer.run_files
  }
}

task glimmer {
  input {
    File genome_fasta
    Int args_max_olap
    Int args_gene_len
    Int args_threads
  }

  command <<<
/BioBin/glimmer3.02/bin/long-orfs -n -t 1.15 ${genome_fasta} run1.longorfs
/BioBin/glimmer3.02/bin/extract -t ${genome_fasta} run1.longorfs > run1.train
/BioBin/glimmer3.02/bin/build-icm -r run1.icm < run1.train
/BioBin/glimmer3.02/bin/glimmer3  -o ${args_max_olap} -g ${args_gene_len} -t ${args_threads} ${genome_fasta} run1.icm run1
mkdir ../../iwandresultfiles
cp -r run1* ../../iwandresultfiles
  >>>

  output {
    Array[File] run_files = glob("run1*")
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/glimmer3:latest"
    cpu: args_threads
    memory: "15 GB"
  }
}


