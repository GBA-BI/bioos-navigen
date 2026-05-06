version 1.0

workflow Tool_PRISM {
  input {
    File fa
    File sam
    String insert_size
    String standard_deviation_insert_size
  }

  call prism1 {
    input:
      fa = fa,
      sam = sam,
      m  = insert_size,
      e  = standard_deviation_insert_size
  }
}

task prism1 {
  input {
    File fa
    File sam
    String m
    String e
  }

  command <<<
    set -e
    # 运行脚本；它会在当前目录生成 PRISM_input/ 与 PRISM_output/
    sh /PRISM_1_1_6/toolkit/run_PRISM.sh -m ~{m} -e ~{e} -r ~{fa} -i ~{sam}

    # 脚本跑完后把 PRISM_output 搬到上一层并改名为 PRISM_<timestamp>
    # 现在把它再拷回到当前目录（task 根目录），方便 Cromwell 收集
    FINAL_DIR=$(ls -d ../PRISM_* 2>/dev/null || true)
    if [[ -n "$FINAL_DIR" ]]; then
        # 拷贝或硬链接；这里用 cp -r 最保险
        cp -r "$FINAL_DIR" results
    else
        # 极端兜底：如果脚本没搬，直接把 PRISM_output 拿来
        cp -r PRISM_output results
    fi
  >>>

  output {
    Array[File] files = glob("results/**")
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/prism:latest"
    cpu: 12
    memory: "24GB"
  }
}
