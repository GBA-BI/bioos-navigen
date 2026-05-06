version 1.0

workflow Tool_Prokka {
    input {
        File input_fasta
        String prefix
        String kingdom
    }
    
    call prokka_annotation {
        input:
            genome_fasta = input_fasta,
            prefix = prefix,
            kingdom = kingdom
    }
    
}

task prokka_annotation {
    input {
        File genome_fasta
        String prefix
        String kingdom
    }
    
    command {
        /prokka-1.14.5/bin/prokka \
        --outdir ./ \
        --prefix ${prefix} \
        ${genome_fasta} \
        --force --kingdom ${kingdom}
        
        mkdir -p ../../iwandresultfiles
        cp -r ${prefix}.gff ${prefix}.faa ${prefix}.gbk ${prefix}.tsv ../../iwandresultfiles
    }
    
    output {
        Array[File] out = glob("../../iwandresultfiles/**")
    }
    
    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/prokka:latest"
        cpu: 4
        memory: "10GB"
    }
}
