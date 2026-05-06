version 1.0

workflow Tool_Trinity {
	input {
		File fq1
		File fq2
		String seqtype
		String max_memory
		Int? cpu
		Boolean jaccard_clip = false
	}

	call trinity {
		input:
		  fq1 = fq1,
		  fq2 = fq2,
		  seqtype = seqtype,
		  max_memory = max_memory,
		  cpu = cpu,
		  jaccard_clip = jaccard_clip
	}

	output {
		File trinity_out_dir_tar = trinity.trinity_out_dir_tar
	}
}

task trinity {
	input {
		File fq1
		File fq2
		String seqtype
		String max_memory
		Int cpu = 20
		Boolean jaccard_clip = false
	}

	command <<<
		set -euo pipefail
		if ~{jaccard_clip}; then
			JACCARD="--jaccard_clip"
		else
			JACCARD=""
		fi
		Trinity --left ~{fq1} --right ~{fq2} --seqType ~{seqtype} --max_memory ~{max_memory} --CPU ~{cpu} $JACCARD --bflyHeapSpaceMax  100G

		# Archive full output directory for portability
		tar -czf trinity_out_dir.tar.gz trinity_out_dir
	>>>

	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/trinity:latest"
		cpu: 20
		memory: "200 GB"
	}

	output {
		File trinity_out_dir_tar = "trinity_out_dir.tar.gz"
	}
}
