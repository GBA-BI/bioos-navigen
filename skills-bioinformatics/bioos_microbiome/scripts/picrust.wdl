version 1.0


workflow Tool_PICRUSt {
  input {
    File biom
    String type
    String category  
    String level  
    String? limit 
  }

  call picrust {
    input: 
      biom = biom,
      type = type,
      category = category,
      level = level,
      limit = limit
  }

  output {
    File report = picrust.report
    File ko_predictions = picrust.ko_predictions
    File categorize_by_function = picrust.categorize_by_function
    File metagenome_contributions = picrust.metagenome_contributions
  }
}

task picrust {
  input {
    File biom
    String type
    String category  
    String level  
    String? limit
  }
  
  command {
    /Biobin/miniconda2/bin/python /Biobin/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/normalize_by_copy_number.py -i ${biom} -o otus_corrected.biom  

    /Biobin/miniconda2/bin/python /Biobin/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/predict_metagenomes.py -i otus_corrected.biom -t ${type} -o ko_predictions.biom 

    /Biobin/miniconda2/bin/python /Biobin/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/categorize_by_function.py -i ko_predictions.biom -c ${category} -l ${level} -o categorize_by_function.txt 
    
    if [ -n "${limit}" ]; then
      /Biobin/miniconda2/bin/python /Biobin/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/metagenome_contributions.py -i otus_corrected.biom -t ${type} -l ${limit} -o metagenome_contributions.txt
    else
      /Biobin/miniconda2/bin/python /Biobin/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/metagenome_contributions.py -i otus_corrected.biom -t ${type} -o metagenome_contributions.txt
    fi

    echo 'PICRUST report' > PICRUST.report.txt
    echo 'normalize_by_copy_number.py done !' >> PICRUST.report.txt
    echo 'predict_metagenomes.py done ! Created PICRUST_ko_predictions.biom file . ' >> PICRUST.report.txt
    echo 'categorize_by_function.py done ! Created PICRUST_pathway_predictions.biom file.' >> PICRUST.report.txt
    echo 'metagenome_contributions.py done ! Created PICRUST_metagenome_contributions.txt file.' >> PICRUST.report.txt
    echo 'PICRUST Finished!' >> PICRUST.report.txt
  }

  output {
    File report = "PICRUST.report.txt"
    File ko_predictions = "ko_predictions.biom"
    File categorize_by_function = "categorize_by_function.txt"
    File metagenome_contributions = "metagenome_contributions.txt"
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/nmdc/picrust:new"
    cpu: 4
    memory: "100 GB"
  }
}
