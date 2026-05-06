version 1.0

workflow Tool_BLASR {
  input {
    File input_query
    File input_ref
    
    String? clipping = "soft"
    String? outformat = "-m 5"
    String? nproc = "1"
    String? minmatch = "10"
    String? maxscore = "500"
    String? minreads_len = "50"
    String? subreads_len = "50"
  }
  
  call BLASR {
    input:
      input_query = input_query,
      input_ref = input_ref,
      clipping = clipping,
      outformat = outformat,
      nproc = nproc,
      minmatch = minmatch,
      maxscore = maxscore,
      minreads_len = minreads_len,
      subreads_len = subreads_len
  }
  
}

task BLASR {
  input {
    File input_query
    File input_ref
    
    String? clipping
    String? outformat
    String? nproc
    String? minmatch
    String? maxscore
    String? minreads_len
    String? subreads_len
  }
  
  command {
    

    
#    /BioBin/blasr/bin/blasr ${input_query} ${input_ref} -out result ${if defined(clipping) then "-clipping " + select_first([clipping]) else ""} ${if defined(outformat) then select_first([outformat]) else ""} ${if defined(nproc) then "-nproc " + select_first([nproc]) else ""} ${if defined(minmatch) then "-minMatch " + select_first([minmatch]) else ""} ${if defined(maxscore) then "-maxScore " + select_first([maxscore]) else ""} ${if defined(minreads_len) then "-minReadLength " + select_first([minreads_len]) else ""} ${if defined(subreads_len) then "-minSubreadLength " + select_first([subreads_len]) else ""}
  /BioBin/blasr/bin/blasr ${input_query} ${input_ref} -out result ${'-clipping ' + clipping} ${outformat} ${'-nproc ' + nproc} ${'-minMatch ' + minmatch} ${'-maxScore ' + maxscore} ${'-minReadLength ' + minreads_len} ${'-minSubreadLength ' + subreads_len}

  }
  
  output {
    File result = "result"
  }
  
  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/assembletool:latest"
    cpu: 10
    memory: "10 GB"
  }
}
