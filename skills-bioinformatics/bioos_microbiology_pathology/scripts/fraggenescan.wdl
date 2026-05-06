version 1.0

workflow Tool_FragGeneScan{
	input{
		File input_fasta
		String train_model
		Int complete
	}

	call fraggenescan{
		input:
			genome_fasta = input_fasta,
			train_model = train_model,
			complete = complete
	}

	output{
		Array[File] result_files = fraggenescan.result_files
	}
}

task fraggenescan{
	input{
		File genome_fasta
		String train_model
		Int complete
	}

	command<<<
		/BioBin/MaxBin2/auxiliary/FragGeneScan1.30/run_FragGeneScan.pl -genome=~{genome_fasta} -out=result -complete=~{complete} -train=~{train_model}
	>>>

	output{
		Array[File] result_files = glob("result*")
	}

	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/metatools:lite"
		cpu: 1
		memory: "15G"
	}
}
