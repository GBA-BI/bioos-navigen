version 1.0

workflow Tool_LUMPY {
  input {
    File fasta
    File fq1
    File fq2
  }

  call LUMPY {
    input: fasta = fasta, fq1 = fq1, fq2 = fq2
  }

  output {
    File vcf = LUMPY.output_vcf
  }
}

task LUMPY {
  input {
    File fasta
    File fq1
    File fq2
  }

  command <<<
    set -euo pipefail
    bwa index ~{fasta} -p tmp
    bwa mem -R '@RG\tID:id\tSM:sample\tLB:lib' ./tmp ~{fq1} ~{fq2} > out.sam
    samblaster --excludeDups --addMateTags -i ./out.sam \
      | samtools view -S -b - > out.bam
    samtools view -b -F 1294 out.bam > out.discordants.unsorted.bam
    samtools view -h out.bam \
      | /lumpy-sv/scripts/extractSplitReads_BwaMem -i stdin \
      | samtools view -Sb - > out.splitters.unsorted.bam
    samtools sort out.discordants.unsorted.bam -o out.discordants.bam
    samtools sort out.splitters.unsorted.bam -o out.splitters.bam
    lumpyexpress -B out.bam -S out.splitters.bam -D out.discordants.bam -o output.vcf
  >>>

  output {
    File output_vcf = "output.vcf"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/lumpy:latest"
    cpu: 8
    memory: "16 GB"
  }
}
