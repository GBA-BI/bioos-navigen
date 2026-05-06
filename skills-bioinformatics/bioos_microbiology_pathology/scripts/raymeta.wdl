version 1.0

workflow Tool_RayMeta {
	input{
		Int cpu
		Int kmer
		File fq1
		File fq2
	}
    call ray{
    input: fq1=fq1,fq2=fq2,cpu=cpu,kmer=kmer
   }

    output {
		Array[File] ray_outputs = ray.ray_outputs
	}
}

task ray {
	input{
		Int cpu
		Int kmer
		File fq1
		File fq2
	}

  command {
	/usr/lib64/openmpi/bin/mpiexec --allow-run-as-root -n ${cpu} /BioBin/Ray-2.3.1/Ray -k ${kmer} -p ${fq1} ${fq2} -o output
  }

  output {
	Array[File] ray_outputs = glob("output/**")
  }

  runtime {
     docker: "registry-vpc.miracle.ac.cn/nmdc/assembletool:latest"
     cpu: 16
     memory: "64 GB"
  }
}
