version 1.0

workflow Tool_MUMmer {
	input{
	 File ref
	 File fa
	 String out_prefix = "out"
	}

   call mummer {
    input: ref=ref, fa=fa, out_prefix=out_prefix
  }

  output {
    Array[File] result_files = mummer.result_files
  }
}

task mummer {
	input{
	 File ref
	 File fa
	 String out_prefix
	}

  command {
	/MUMmer3.23/nucmer --prefix ${out_prefix} --maxmatch ${ref} ${fa}
	mkdir -p ../../iwandresultfiles/
	cp -r ${out_prefix}* ../../iwandresultfiles/

  }
  output {
    Array[File] result_files = glob("${out_prefix}*")
  }
  runtime {
     docker: "registry-vpc.miracle.ac.cn/nmdc/mummer3:v1"
     cpu: 2
     memory: "100 GB"
  }
}
