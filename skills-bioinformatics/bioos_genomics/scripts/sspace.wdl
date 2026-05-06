version 1.0

workflow Tool_SSPACE {
	input {
		File fq1
		File fq2
		File fa

		String expected_inserted_size
		String minimum_allowed_error
	}

	call SSPACE {
		input:
			fq1 = fq1,
			fq2 = fq2,
			fa = fa,
			expected_inserted_size = expected_inserted_size,
			minimum_allowed_error = minimum_allowed_error
	}

}

task SSPACE {
	input {
		File fq1
		File fq2
		File fa

		String expected_inserted_size
		String minimum_allowed_error
	}

	command <<<
		echo "Lib1 bowtie ~{fq1} ~{fq2} ~{expected_inserted_size} ~{minimum_allowed_error} FR" > libraries.txt
		perl /BioBin/SSPACE/SSPACE-STANDARD-3.0_linux-x86_64/SSPACE_Standard_v3.0.pl \
			-l libraries.txt \
			-s ~{fa} \
			-m 32 -o 20 -k 5 -a 0.70 -n 15 -p 0 -v 0 -z 0 -g 0 -T 1 \
			-b result
	>>>

	output {
		File libraries = "libraries.txt"
		Array[File] result_files = glob("result/**")
	}

	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/sspace:v1"
		cpu: 10
		memory: "30 GB"
	}
}

