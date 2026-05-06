task spades {
    File fq1
    File fq2
    String prefix
    String outFolder
    String kmer
    Int threads
    Boolean careful = true
    Boolean single_cell = true
    Boolean disable_gzip_output = true
    String spades_bin = "/BioBin/SPAdes-3.13.0-Linux/bin/spades.py"

    command {
        set -euo pipefail
        out_path="${prefix}_spades/${outFolder}"
        mkdir -p "$out_path"
        python ${spades_bin} \
            --pe1-1 ${fq1} \
            --pe1-2 ${fq2} \
            -k ${kmer} \
            --threads ${threads} \
            ${true='--careful' false='' careful} \
            ${true='--sc' false='' single_cell} \
            ${true='--disable-gzip-output' false='' disable_gzip_output} \
            -o "$out_path"
    }

    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/assembletool:latest"
        cpu: threads
        memory: "50 GB"
    }

    output {
        File   log      = "${prefix}_spades/${outFolder}/spades.log"
        File   params   = "${prefix}_spades/${outFolder}/params.txt"
        File   contigs  = "${prefix}_spades/${outFolder}/contigs.fasta"
        File   scaffolds= "${prefix}_spades/${outFolder}/scaffolds.fasta"
        File   graph    = "${prefix}_spades/${outFolder}/assembly_graph_with_scaffolds.gfa"
    }
}

workflow spades_workflow {
    File  fq1
    File  fq2
    String prefix
    String outFolder = "result"
    String kmer = "21,33,55"
    Int    threads = 8

    call spades {
        input:
            fq1      = fq1,
            fq2      = fq2,
            prefix   = prefix,
            outFolder= outFolder,
            kmer     = kmer,
            threads  = threads
    }

    output {
        File   log       = spades.log
        File   params    = spades.params
        File   contigs   = spades.contigs
        File   scaffolds = spades.scaffolds
        File   graph     = spades.graph
        String out_dir   = "${prefix}_spades/${outFolder}"
    }
}
