version 1.0

workflow Tool_StrainEst{
	input {
		File database
		File bam
	}

	call strainEst {
		input:
			database = database,
			bam = bam
	}

	output {
		File strainest_output = strainEst.strainest_output
	}
}

task strainEst{
	input {
		File database
		File bam
	}

	command <<<
		samtools index ~{bam}
		mkdir -p output
		/usr/local/bin/strainest est ~{database} ~{bam} output
		tar -czf strainest_output.tgz output
	>>>

	output {
		File strainest_output = "strainest_output.tgz"
	}

	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/strainest:latest"
		cpu: 10
		memory: "20GB"
	}
}
