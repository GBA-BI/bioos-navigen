version 1.0

workflow Tool_Kaiju {
	input {
		File dmp
		File fmi
		File seq1
		File? seq2

		String? threads
		String? mode
		String? number_of_greedy_mismatches
		String? minimum_match_length
		String? minimum_match_score_in_greedy
		String? minimum_evalue
		String? protein_seq
	}

	call kaiju {
		input:
		  dmp = dmp,
		  fmi = fmi,
		  seq1 = seq1,
		  seq2 = seq2,
		  threads = threads,
		  mode = mode,
		  number_of_greedy_mismatches = number_of_greedy_mismatches,
		  minimum_match_length = minimum_match_length,
		  minimum_match_score_in_greedy = minimum_match_score_in_greedy,
		  minimum_evalue = minimum_evalue,
		  protein_seq = protein_seq
	}

	
}

task kaiju {
	input {
		File dmp
		File fmi
		File seq1
		File? seq2

		String? threads
		String? mode
		String? number_of_greedy_mismatches
		String? minimum_match_length
		String? minimum_match_score_in_greedy
		String? minimum_evalue
		String? protein_seq
	}

	command <<<
		/BioBin/kaiju/bin/kaiju \
			-t ~{dmp} \
			-f ~{fmi} \
			-i ~{seq1} \
			~{if defined(seq2) then "-j " else ""}~{if defined(seq2) then seq2 else ""} \
			~{if defined(threads) then "-z " + threads else ""} \
			~{if defined(mode) then "-a " + mode else ""} \
			~{if defined(number_of_greedy_mismatches) then "-e " + number_of_greedy_mismatches else ""} \
			~{if defined(minimum_match_length) then "-m " + minimum_match_length else ""} \
			~{if defined(minimum_match_score_in_greedy) then "-s " + minimum_match_score_in_greedy else ""} \
			~{if defined(minimum_evalue) then "-E " + minimum_evalue else ""} \
			~{if defined(protein_seq) then "-" + protein_seq else ""} \
			-v -o kaiju_out

		mkdir -p ../../iwandresultfiles/
		cp kaiju_out ../../iwandresultfiles/
	>>>

	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/metatools:lite"
		cpu: "20"
		memory: "30GB"
	}

	output {
		Array[File] kaiju_output = glob("../../iwandresultfiles/**")
	}
}
