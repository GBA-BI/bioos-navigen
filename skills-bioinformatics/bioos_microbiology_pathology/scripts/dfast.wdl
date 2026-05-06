version 1.0

workflow Tool_DFAST02 {

 input {
 String cpu
 File fasta
 #@complete=t,f
 String complete 
 #@sort_sequence=t,f
 String sort_sequence
 #@use_tags=t,f
 String   use_tags
 String?  other_para 
 }

   call dfast{
    input: cpu=cpu,fasta=fasta,complete=complete,sort_sequence=sort_sequence,use_tags=use_tags,other_para=other_para
  }
}

task dfast {
 input {
 String cpu
 File fasta
 String complete 
 String sort_sequence
 String   use_tags
 String?  other_para 
 }

  command {
  
	dfast  --sort_sequence  ${sort_sequence}  --cpu ${cpu} --complete ${complete} --use_separate_tags ${use_tags} ${other_para}  --genome  ${fasta}
	mkdir ../../iwandresultfiles/
	cp -r OUT   ../../iwandresultfiles/

  }
  output {
    Array[File] out_dir = glob("OUT/*")
  }
  runtime {
     docker: "registry-vpc.miracle.ac.cn/nmdc/dfast_core:1.2.6"
     cpu: 16
     memory: "24 GB"
  }
}
