version 1.0

workflow Tool_Ballgown {
  input {
    File input_ballgown
    File pheno_data
    String Pattern
    String covariate
    String qvalue
  }

  call Ballgown {
    input:
      input_ballgown = input_ballgown,
      pheno_data = pheno_data,
      Pattern = Pattern,
      covariate = covariate,
      qvalue = qvalue
  }

  output {
    File transcript_results = Ballgown.transcript_results
    File gene_results = Ballgown.gene_results
    File diff_transcripts_results = Ballgown.diff_transcripts_results
    File diff_genes_results = Ballgown.diff_genes_results
  }

}

task Ballgown {
  input {
    File input_ballgown
    File pheno_data
    String Pattern
    String covariate
    String qvalue
  }

  command <<<
    unzip ~{input_ballgown}

    echo 'library("ballgown")' > temp.R
    echo 'library("genefilter")' >> temp.R
    echo 'library("dplyr")' >> temp.R
    echo 'args <- commandArgs()'  >> temp.R
    echo 'print (args)' >> temp.R
    echo 'for (i in seq(1,length(args))){' >> temp.R
    echo '  argsplit <- unlist(strsplit(args[i], split="="))' >> temp.R
    echo '  if (argsplit[1]=="inputfile") { if (!is.na(argsplit[2])){ inputfile = argsplit[2] } }' >> temp.R
    echo '  if (argsplit[1]=="outputfile") { if (!is.na(argsplit[2])) { outputfile = argsplit[2] } }' >> temp.R
    echo '  if (argsplit[1]=="qvalue") { if (!is.na(argsplit[2])) { qvalue =as.numeric(argsplit[2])} }' >> temp.R
    echo '  if (argsplit[1]=="Pattern") { if (!is.na(argsplit[2])){ Pattern = argsplit[2] } }' >> temp.R
    echo '  if (argsplit[1]=="Covariate") { if (!is.na(argsplit[2])) { Covariate = argsplit[2] } }' >> temp.R
    echo '}' >> temp.R
    echo 'pheno_data<-read.csv(inputfile)' >> temp.R
    echo 'bg_chrX = ballgown(dataDir ="ballgown", samplePattern=Pattern, pData=pheno_data)'     >> temp.R
    echo 'bg_chrX_filt = subset(bg_chrX,"rowVars(texpr(bg_chrX))     >1",genomesubset=TRUE)' >> temp.R
    echo 'results_transcripts = stattest(bg_chrX_filt,feature=    "transcript",covariate=Covariate, getFC=TRUE, meas="FPKM")' >> temp.R
    echo 'results_genes = stattest(bg_chrX_filt, feature="gene",covariate=Covariate,     getFC=TRUE,meas="FPKM")' >> temp.R
    echo  'results_transcripts=arrange(results_transcripts,pval)'>> temp.R
    echo 'results_genes=arrange(results_genes,pval)' >> temp.R
    echo 'write.csv(results_transcripts, file="chrX_transcript_results.csv")' >> temp.R
    echo 'write.csv(results_genes,file="chrX_gene_results.csv")' >> temp.R
    echo 'diff_transcripts <- subset(results_transcripts,results_transcripts$qval<qvalue)' >> temp.R
    echo 'diff_genes <- subset(results_genes,results_genes$qval<qvalue)' >> temp.R
    echo 'write.csv(diff_transcripts,file="diff_transcripts_results.csv")' >> temp.R
    echo 'write.csv(diff_genes, file="diff_genes_results.csv")' >> temp.R
    Rscript temp.R inputfile=~{pheno_data} outputfile=./  Pattern=~{Pattern} Covariate=~{covariate} qvalue=~{qvalue}

    mkdir ../../iwandresultfiles/
    cp -r chrX_transcript_results.csv chrX_gene_results.csv  diff_genes_results.csv diff_transcripts_results.csv  ../../iwandresultfiles/
  >>>

  output {
    File transcript_results = "chrX_transcript_results.csv"
    File gene_results = "chrX_gene_results.csv"
    File diff_transcripts_results = "diff_transcripts_results.csv"
    File diff_genes_results = "diff_genes_results.csv"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/ballgown:new"
    cpu: 4
    memory: "24GB"
  }

}
