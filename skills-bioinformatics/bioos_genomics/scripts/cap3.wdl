version 1.0

workflow Tool_CAP3 {
    input {
        File fasta
    }
    
    call cap3 {
        input: 
            fasta = fasta
    }
    

}

task cap3 {
    input {
        File fasta
    }
    
    command {
        name=`basename ${fasta}`
        cp ${fasta} ./
        
        /CAP3/cap3 $name > cap.log
        
        mkdir -p ../../iwandresultfiles/
        mv *cap* ../../iwandresultfiles/
    }
    
    output {
        Array[File] result = glob("../../iwandresultfiles/**")
    }
    
    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/cap3:latest"
        cpu: 2
        memory: "8G"
    }
}
