version 1.0

workflow Tool_oases{
	input{
		File seq1
		File? seq2

		String kmer
		String reads_type
		String reads_format
		String? ins_length
		String? cov_cutoff
		String? edgeFractionCutoff
		String? min_trans_lgth
		String? min_pair_count
	}

	call oases{
		input:
		  seq1 = seq1,
		  seq2 = seq2,
		  kmer = kmer,
		  reads_type = reads_type,
		  reads_format = reads_format,
		  ins_length = ins_length,
		  cov_cutoff = cov_cutoff,
		  edgeFractionCutoff = edgeFractionCutoff,
		  min_trans_lgth = min_trans_lgth,
		  min_pair_count = min_pair_count	  
		  
	}
}

task oases{
	input{
		File seq1
		File? seq2

		String kmer
		String reads_type
		String reads_format
		String? ins_length
		String? cov_cutoff
		String? edgeFractionCutoff
		String? min_trans_lgth
		String? min_pair_count
	}

	command{
		mkdir outdir
		/usr/miniconda2/bin/velveth outdir ~{kmer} ~{reads_type} ~{reads_format} ~{seq1} ~{if defined(seq2) then seq2 else ''}
		/usr/miniconda2/bin/velvetg outdir -read_trkg yes ~{if defined(ins_length) then ('-ins_length ' + ins_length) else ''}
		/usr/miniconda2/bin/oases outdir \
			~{if defined(cov_cutoff) then ('-cov_cutoff ' + cov_cutoff) else ''} \
			~{if defined(edgeFractionCutoff) then ('-edgeFractionCutoff ' + edgeFractionCutoff) else ''} \
			~{if defined(ins_length) then ('-ins_length2 ' + ins_length) else ''} \
			~{if defined(min_trans_lgth) then ('-min_trans_lgth ' + min_trans_lgth) else ''} \
			~{if defined(min_pair_count) then ('-min_pair_count ' + min_pair_count) else ''}
		mkdir result
		mv outdir/transcripts.fa outdir/contig-ordering.txt result


	}
	output{
		Array[File] files=glob("result/**")
	}
	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/oases:latest"
		cpu: 20
		memory: "50 GB"
	}
}
