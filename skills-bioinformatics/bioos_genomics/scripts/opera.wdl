version 1.0

workflow Tool_OPERA{
	input {
		File contig_file
		File fq1
		File fq2
		File long_read_file

		String? kmer
		String? num_of_processors
	}

	call opera{
		input:
		  contig_file = contig_file,
		  fq1 = fq1,
		  fq2 = fq2,
		  long_read_file = long_read_file,
		  kmer = kmer,
		  num_of_processors = num_of_processors
	}

	output {
		File opera_result_tar = opera.opera_result_tar
	}
}

task opera{
	input{
		File contig_file
		File fq1
		File fq2
		File long_read_file

		String? kmer
		String? num_of_processors
	}

	command{
		ls -l / >> XXX
		ls -l /BioBin/OPERA-LG_v2.0.6/bin/OPERA-long-read.pl >> YYY
		/BioBin/OPERA-LG_v2.0.6/bin/OPERA-long-read.pl ${if defined(kmer) then ('--kmer ' + kmer) else ''} ${if defined(num_of_processors) then ('--num-of-processors ' + num_of_processors) else ''} --blasr /BioBin/blasr/bin/ --opera /BioBin/OPERA-LG_v2.0.6/bin/ --contig-file ${contig_file} --illumina-read1 ${fq1} --illumina-read2 ${fq2} --long-read-file ${long_read_file} --output-prefix opera-lr  --output-directory result

		mkdir ../../iwandresultfiles/
		mv result ../../iwandresultfiles/
		tar -czf iwandresultfiles_result.tar.gz -C ../../iwandresultfiles result
	}

	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/opera:latest"
		cpu: 20
		memory: "20 GB"
	}

	output {
		File opera_result_tar = "iwandresultfiles_result.tar.gz"
	}
}

