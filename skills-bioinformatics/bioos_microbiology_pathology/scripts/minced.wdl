version 1.0

workflow Tool_minced{
	input{
		File genome

		String? minNR
		String? minRL
		String? maxRL
		String? minSL
		String? maxSL
	}

	call minced{
		input:
		  genome = genome,
		  minNR = minNR,
		  minRL = minRL,
		  maxRL = maxRL,
		  minSL = minSL,
		  maxSL = maxSL	  
	}

	output{
		File result_txt = minced.result_txt
		File result_gff = minced.result_gff
	}
}

task minced{
	input{
		File genome

		String? minNR
		String? minRL
		String? maxRL
		String? minSL
		String? maxSL
	}

	command<<<
		set -euo pipefail
		minced~{if defined(minNR) then (" -minNR " + minNR) else ""}~{if defined(minRL) then (" -minRL " + minRL) else ""}~{if defined(maxRL) then (" -maxRL " + maxRL) else ""}~{if defined(minSL) then (" -minSL " + minSL) else ""}~{if defined(maxSL) then (" -maxSL " + maxSL) else ""} -gffFull ~{genome} result.txt result.gff
	>>>

	output{
		File result_txt = "result.txt"
		File result_gff = "result.gff"
	}

	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/minced:latest"
		cpu: 10
		memory: "20GB"
	}
}
