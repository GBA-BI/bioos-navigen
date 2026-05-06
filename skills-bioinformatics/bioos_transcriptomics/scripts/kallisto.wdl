version 1.0

workflow Tool_Kallisto {
	input {
		File input_read1
		File input_read2
		File kallisto_db_fa
	}

	call kallisto {
		input:
			input_read1 = input_read1,
			input_read2 = input_read2,
			kallisto_db_fa = kallisto_db_fa
	}

	output {
		File transcripts_index = kallisto.transcripts_index
		File abundance_tsv = kallisto.abundance_tsv
		File abundance_h5 = kallisto.abundance_h5
		File run_info_json = kallisto.run_info_json
	}
}

task kallisto {
	input {
		File input_read1
		File input_read2
		File kallisto_db_fa
	}

	command <<<
		/usr/local/bin/kallisto index -i transcripts.idx ~{kallisto_db_fa}
		/usr/local/bin/kallisto quant -i transcripts.idx -o output -b 100 ~{input_read1} ~{input_read2}
	>>>

	output {
		File transcripts_index = "transcripts.idx"
		File abundance_tsv = "output/abundance.tsv"
		File abundance_h5 = "output/abundance.h5"
		File run_info_json = "output/run_info.json"
	}

	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/kallisto:latest"
		cpu: 1
		memory: "10 GB"
	}
}


