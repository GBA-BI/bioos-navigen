version 1.0

workflow RGIWorkflow {
    input {
        File faa
        String sampleName
    }
    
    call RGI {
        input:
            faa = faa,
            sampleName = sampleName
    }
    
    output {
        File rgi_result = RGI.rgi
    }
}

task RGI {
    input {
        File faa
        String sampleName
    }
    
    command {
        export PATH=/opt/conda/envs/rgi/bin:$PATH
        mkdir rgi_db    
        rgi load --card_json /share/workflow/wdl/GCmeta/Annotation/database/RGI/card.json --local
        rgi main -i ${faa} -t protein -o ${sampleName}_RGI --clean -n 20 --include_loose -a DIAMOND --clean --local >log
        mkdir -p ../../../tmp_dir/CARD/
        cp ${sampleName}_RGI.txt ../../../tmp_dir/CARD/
        mkdir -p ../../../iwandresultfiles/result/Gene_annotation/RGI
        cp ${sampleName}_RGI.txt ../../../iwandresultfiles/result/Gene_annotation/RGI
        if [ -f "../../../tmp_dir/CARD/${sampleName}_RGI.txt" ]
        then
            echo "RGI was done" >>../../../iwandresultfiles/result/log.txt
        else
            echo "RGI was done" >>../../../iwandresultfiles/result/log.txt
        fi
    }
    
    output {
        String rgi = "../../../tmp_dir/CARD/${sampleName}_RGI.txt"
    }
    
    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/rgi:6.0.3"
        cpu: "20"
        memory: "40G"
    }
}
