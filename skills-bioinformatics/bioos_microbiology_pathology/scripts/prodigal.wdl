version 1.0

task prodigal {
    input {
        File inputFile
    }
    command {
        /BioBin/Prodigal/bin/prodigal \
            -a prodigal.faa \
            -d prodigal.fna \
            -f gff \
            -g 11 \
            -p single \
            -i ${inputFile} \
            -o prodigal.gff \
            -m
    }

    output {
        File faaFile = "prodigal.faa"
        File fnaFile = "prodigal.fna"
        File gffFile = "prodigal.gff"
    }

    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/metatools:lite"
        cpu: 10
        memory: "20GB"
    }

}

workflow Tool_prodigal {
    input {
        File inputFile
    }

    call prodigal {
        input:
            inputFile = inputFile
    }

    output {
        File faaFile = prodigal.faaFile
        File fnaFile = prodigal.fnaFile
        File gffFile = prodigal.gffFile
    }
}
