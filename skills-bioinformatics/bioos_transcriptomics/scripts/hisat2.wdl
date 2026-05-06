version 1.0

workflow Tool_Hisat2 {
	input {
		File fasta
		File? splicesite
		File fq1
		File fq2
		Int cpu
	}

	call hisat2 {
		input: fasta = fasta, splicesite = splicesite, fq1 = fq1, fq2 = fq2, cpu = cpu
	}

	output {
		File sam = hisat2.sam
	}
}

task hisat2 {
	input {
		File fasta
		File? splicesite
		File fq1
		File fq2
		Int cpu
	}

	command <<<
	set -euo pipefail
	hisat2-build ~{fasta} temp
	hisat2 -x temp ~{if defined(splicesite) then "--known-splicesite-infile " + splicesite else ""} -p ~{cpu} -1 ~{fq1} -2 ~{fq2} > output.sam
	>>>

	output {
		File sam = "output.sam"
	}

	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/mrna:latest"
		cpu: cpu
		memory: "48 GB"
	}
}
