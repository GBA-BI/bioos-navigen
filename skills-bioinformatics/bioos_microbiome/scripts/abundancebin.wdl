version 1.0

workflow Tool_AbundanceBin {
  input {
    File input_file
    Int? bin_num
    Boolean recursive_classification = false
    Int? exclude_count
    Int? exclude_max
  }

  call abundancebin {
    input:
      input_file = input_file,
      bin_num = bin_num,
      recursive_classification = recursive_classification,
      exclude_count = exclude_count,
      exclude_max = exclude_max
  }

  output {
    Array[File] output_dir = abundancebin.output_files
  }
}

task abundancebin {
  input {
    File input_file
    Int? bin_num
    Boolean recursive_classification = false
    Int? exclude_count
    Int? exclude_max

    String output_dir = "iwandresultfiles"
  }

  command {
    mkdir -p result
    /BioBin/abundancebin/abundancebin \
      -input ~{input_file} \
      ~{if defined(bin_num) then ("-bin_num " + bin_num) else ""} \
      ~{if recursive_classification then "-RECURSIVE_CLASSIFICATION" else ""} \
      ~{if defined(exclude_count) then ("-exclude " + exclude_count) else ""} \
      ~{if defined(exclude_max) then ("-exclude_max " + exclude_max) else ""} \
      -output temp
    
    mv temp* result
    mkdir -p ~{output_dir}/
    mv result ~{output_dir}/
  }

  output {
    Array[File] output_files = glob("~{output_dir}/result/**")
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/abundancebin:latest"
    cpu: 10
    memory: "10 GB"
  }
}
