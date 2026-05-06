version 1.0

workflow Tool_DIAMOND{
	input{
		File db_fasta
		File query_fasta
		String args_cand
		String prefix
		Int args_outfmt
		Int args_threads
		String evalue
	}
	call diamond{ input: db_fasta = db_fasta, query_fasta = query_fasta, args_cand = args_cand, prefix = prefix, args_threads = args_threads, args_outfmt = args_outfmt, evalue = evalue }
}

task diamond{
	input{
		File db_fasta
		File query_fasta
		String args_cand
		String prefix
		Int args_threads
		Int args_outfmt
		String evalue
	}

	command<<<
		diamond makedb --in ~{db_fasta} -d nr
		diamond ~{args_cand} -d nr -q ~{query_fasta} -o ~{prefix}.txt --threads ~{args_threads} -f ~{args_outfmt} -e ~{evalue}
		mkdir -p ../../iwandresultfiles
		cp -r ~{prefix}.txt ../../iwandresultfiles
	>>>

	output{
		File diamond_result = "~{prefix}.txt"
	}
	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/diamond:latest"
		cpu: 10
		memory: "10G"
	}
}
