version 1.0

workflow Tools_RNAmmer {

  input {
    File genome
    String m
    String species
  }

  call RNAmmer {
    input: genome = genome, m = m, species = species
  }

  output {
    File rRNA_fasta = RNAmmer.rRNA_fasta
    File rRNA_hmmreport = RNAmmer.rRNA_hmmreport
    File rRNA_xml = RNAmmer.rRNA_xml
    File rRNA_gff2 = RNAmmer.rRNA_gff2
  }
}

task RNAmmer {

  input {
    File genome
    String m
    String species
  }

  command {
    rnammer -S ~{species} -multi -f rRNA.fasta -h rRNA.hmmreport -xml rRNA.xml -gff rRNA.gff2 -m ~{m} ~{genome}

  }

  output {
    File rRNA_fasta = "rRNA.fasta"
    File rRNA_hmmreport = "rRNA.hmmreport"
    File rRNA_xml = "rRNA.xml"
    File rRNA_gff2 = "rRNA.gff2"
  }

  runtime {
     docker: "registry-vpc.miracle.ac.cn/nmdc/rnammer:v1.2"
     cpu: 2
     memory: "10 GB"
  }

  meta {
    description: "RNAmmer for predicting rRNA genes"
  }

  parameter_meta {
    genome: "Genome FASTA file"
    m: "rRNA type(s) for -m, e.g., ssu, lsu, tsu"
    species: "Species model for -S, e.g., bac, arc, euk"
  }
}
