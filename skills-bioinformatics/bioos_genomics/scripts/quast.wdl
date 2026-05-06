version 1.0

workflow Tool_QUAST{
	input{
		File contigs
		File? ref
		File? features
		File? operons
		String? min_contig
		String? scaffolds
		String? eukaryote
	}

	call QUAST{
		input:
		  contigs = contigs,
		  ref = ref,
		  features = features,
		  operons = operons,
		  min_contig = min_contig,
		  scaffolds = scaffolds,
		  eukaryote = eukaryote
	}

	output{
		File quast_results_tgz = QUAST.quast_results_tgz
	}
}

task QUAST{
	input{
		File contigs
		File? ref
		File? features
		File? operons
		String? min_contig
		String? scaffolds
		String? eukaryote
	}

	command<<<
		mkdir -p quast_results
		/BioBin/quast-5.0.2/quast.py \
			-o quast_results \
			~{if defined(ref) then ('-r ' + select_first([ref])) else ''} \
			~{if defined(features) then ('-g ' + select_first([features])) else ''} \
			~{if defined(operons) then ('--operons ' + select_first([operons])) else ''} \
			~{if defined(min_contig) then ('--min-contig ' + select_first([min_contig])) else ''} \
			~{if defined(scaffolds) then select_first([scaffolds]) else ''} \
			~{if defined(eukaryote) then select_first([eukaryote]) else ''} \
			~{contigs}

		tar -czf quast_results.tar.gz quast_results
	>>>

	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/metatools:lite"
		cpu: 10
		memory: "10 GB"
	}

	output{
		File quast_results_tgz = "quast_results.tar.gz"
	}
}
