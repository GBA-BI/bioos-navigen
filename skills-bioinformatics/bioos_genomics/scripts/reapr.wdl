version 1.0

workflow Tool_REAPR {
	input {
		File assembly_fa
		File fq1
		File fq2
	}

	call reapr {
		input:
			assembly_fa = assembly_fa,
			fq1 = fq1,
			fq2 = fq2
	}

	output {
		File output_tgz = reapr.output_tgz
	}
}

task reapr {
	input {
		File assembly_fa
		File fq1
		File fq2
	}

	command <<<
		/BioBin/Reapr_1.0.18/reapr smaltmap ${assembly_fa} ${fq1} ${fq2} long_mapped.bam
		/BioBin/Reapr_1.0.18/reapr pipeline ${assembly_fa} long_mapped.bam output
		tar -cvzf output.tgz output

		# Keep a copy in the execution directory for WDL outputs
		mkdir -p iwandresultfiles
		cp -f output.tgz iwandresultfiles/
	>>>

	output {
		File output_tgz = "output.tgz"
	}

	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/metatools:lite"
		cpu: 10
		memory: "20 GB"
	}
}