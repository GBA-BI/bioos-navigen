version 1.0

workflow Tool_STAR{
	input{
		File ref
		File gtf
		File fq1
		File fq2

		String? sjdbOverhang
		String? outSAMtype
	}

	call Star{
		input:
		  ref = ref,
		  gtf = gtf,
		  fq1 = fq1,
		  fq2 = fq2,
		  sjdbOverhang = sjdbOverhang,
		  outSAMtype = outSAMtype
	}

	output{
		Array[File] star_outputs = Star.star_outputs
	}
}

task Star{
	input{
		File ref
		File gtf
		File fq1
		File fq2

		String? sjdbOverhang
		String? outSAMtype
	}

	command{
		mkdir temp
		/usr/bin/STAR --runMode genomeGenerate --runThreadN 10 --genomeFastaFiles ~{ref} --sjdbGTFfile ~{gtf} ~{if defined(sjdbOverhang) then ("--sjdbOverhang " + sjdbOverhang) else ""} --genomeDir temp
		mkdir output
		/usr/bin/STAR --runThreadN 20 --genomeDir temp --readFilesIn ~{fq1} ~{fq2} ~{if defined(outSAMtype) then ("--outSAMtype " + outSAMtype) else ""} --outFileNamePrefix result
		mv result* output
	}

	output{
		Array[File] star_outputs = glob("output/*")
	}

	runtime{
		docker: "registry-vpc.miracle.ac.cn/nmdc/star:latest"
		cpu: 20
		memory: "30 GB"
	}
}