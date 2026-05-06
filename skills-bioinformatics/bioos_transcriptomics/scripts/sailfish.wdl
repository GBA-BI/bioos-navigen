version 1.0
workflow Tool_sailfish{
	input{
		File transcripts
		File seq1
		File seq2

		String? kmer
		String? threads
		String lib_type
	}

	call sailfish{
		input:
		  transcripts = transcripts,
		  seq1 = seq1,
		  seq2 = seq2,
		  kmer = kmer,
		  threads = threads,
		  lib_type = lib_type
		  
	}
}

task sailfish{
	input{
		File transcripts
		File seq1
		File seq2

		String? kmer
		String? threads
		String lib_type
	}

	command<<<
		cp ~{transcripts} transcripts.fasta
		sailfish index -t transcripts.fasta ~{if defined(kmer) then ("-k " + kmer) else ""} -o ./
		sailfish quant -i ./ -1 ~{seq1} -2 ~{seq2} ~{if defined(threads) then ("-p " + threads) else ""} -l ~{lib_type} -o output
	>>>
	output{
		Array[File] files=glob("output/**")
	}
	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/sailfish:latest"
		cpu: 10
		memory: "20 GB"
	}
}
