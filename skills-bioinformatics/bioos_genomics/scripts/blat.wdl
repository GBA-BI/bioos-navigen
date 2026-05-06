version 1.0

workflow Tool_Blat {
    input {
        File db_fasta
        File query_fasta
        String prefix
    }
    
    call blat {
        input: 
            db_fasta = db_fasta,
            query_fasta = query_fasta,
            prefix = prefix
    }
}

task blat {
    input {
        File db_fasta
        File query_fasta
        String prefix
    }

    command {
        /BioBin/blat/bin/blat ${db_fasta} ${query_fasta} ${prefix}.txt 
        mkdir -p ../../iwandresultfiles
        cp -r ${prefix}.txt ../../iwandresultfiles
    }
    
    output {
        File blat_result = "${prefix}.txt"
    }
    
    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/metatools:lite"
        cpu: 2
        memory: "10G"
    }
}

