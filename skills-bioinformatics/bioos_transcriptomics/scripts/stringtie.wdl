version 1.0

workflow Tool_StringTie {

input {
File bam 
File gtf 
String label
String f 
String M  
String m  
String A   
String C 
Boolean B 
}

String B_ = if (B) then "-B" else ""

call StringTie {
  input: bam=bam, gtf=gtf, label=label, f=f, M=M, m=m, A=A, C=C, B=B_
}

output {
  Array[File] outputs = StringTie.output_files
}
}

task StringTie {

input {
File bam 
File gtf 
String label
String f 
String M  
String m  
String A   
String C 
String B  
}

  command <<<
stringtie ${bam} -G ${gtf} -o assembly.gtf -l ${label} -f ${f} -M ${M} -m ${m} -A ${A} -C ${C} ${B}
mkdir output
mv ${A} ./output
mv ${C} ./output
mv assembly.gtf ./output
tar -zcvf Ballgown_input.tgz ./*.ctab
mv Ballgown_input.tgz ./output
mkdir -p ../../iwandresultfiles/
cp -r output ../../iwandresultfiles/
>>>

  output {
    Array[File] output_files = glob("output/*")
  }

  runtime {
     docker: "registry-vpc.miracle.ac.cn/nmdc/mrna:latest"
     cpu: 4
     memory: "24 GB"
  }
}
