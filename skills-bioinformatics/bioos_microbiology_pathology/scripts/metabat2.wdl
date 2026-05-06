version 1.0

workflow Tool_MetaBAT2 {
	input {
		File input_dir
		File input_genome_fa
	}
	call metabat2 {
		input:
			input_dir = input_dir,
			input_genome_fa = input_genome_fa
	}
	
}

task metabat2 {
	input {
		File input_dir
		File input_genome_fa
	}
	command <<<
cp ~{input_genome_fa} ref_fa.fa
/opt/conda/bin/runMetaBat.sh ref_fa.fa ~{input_dir}

/opt/conda/bin/jgi_summarize_bam_contig_depths --outputDepth depth.txt ~{input_dir}
/opt/conda/bin/metabat2 -i ~{input_genome_fa} -a depth.txt -o bins_dir/bin

	>>>
	output {
		Array[File] bins = glob("bins_dir/bin*")
		File depth = "depth.txt"
	}
	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/metabat2:2.15--c1941c7"
		cpu: 2
		memory: "150 GB"
	}
}
