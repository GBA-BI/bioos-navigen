version 1.0

task calc_features {
  input {
    File samples
    File alias_file
    File who_labels
    String output_dir
    Int interval_days
    String start_date
    String end_date
    Int nprocesses
    Int? nrows
    String docker_image
  }
  command <<<!
    mkdir -p ~{output_dir} && /app/run_hirisk.sh \
      --calc_features \
      --samples ~{samples} \
      --alias ~{alias_file} \
      --wholabels ~{who_labels} \
      --output ~{output_dir} \
      --interval_days ~{interval_days} \
      --start_date ~{start_date} \
      --end_date ~{end_date} \
      --nprocesses ~{nprocesses} \
      ~{if defined(nrows) then "--nrows " + nrows else ""}
  >>>
  runtime {
    docker: docker_image
    memory: "8 GB"
    cpu: 4
    disks: "local-disk 20 HDD"
  }
  output {
    String log_path = output_dir + "/log.txt"
    File log_file = output_dir + "/log.txt"
    Array[File] features_pkls = glob(output_dir + "/McAN_feature_*.pkl")
  }
}

task predict_surveillance {
  input {
    File alias_file
    File who_labels
    String output_dir
    Int interval_days
    String start_date
    String end_date
    File selected_feature_ml_file
    Boolean new_system
    String docker_image
    Array[File] features_pkls = []
  }
  command <<<!
    mkdir -p ~{output_dir} && \
    if [ ~{length(features_pkls)} -gt 0 ]; then cp ~{sep=" " features_pkls} ~{output_dir}; fi && \
    /app/run_hirisk.sh \
      --predict_surveillance \
      --alias ~{alias_file} \
      --wholabels ~{who_labels} \
      --output ~{output_dir} \
      --interval_days ~{interval_days} \
      --start_date ~{start_date} \
      --end_date ~{end_date} \
      --selected_feature_ml ~{selected_feature_ml_file} \
      ~{if new_system then "--new_system" else ""}
    
    echo "=== DEBUG: predict_surveillance outputs ==="
    ls -lR ~{output_dir}
    echo "========================================="
  >>>
  runtime {
    docker: docker_image
    memory: "8 GB"
    cpu: 4
    disks: "local-disk 20 HDD"
  }
  output {
    String out_dir = output_dir
    # Capture all output files to ensure performance_surveillance has access to full history
    Array[File] y_scores = glob(output_dir + "/y_score_*.npy")
    Array[File] y_preds = glob(output_dir + "/y_pred_*.pkl")
    Array[File] ground_truths = glob(output_dir + "/ground_truth_*.pkl")
    Array[File] pangos = glob(output_dir + "/pango_*.pkl")
    Array[File] classifiers = glob(output_dir + "/classifier_*.pkl")
  }
}

task performance_surveillance {
  input {
    File alias_file
    File who_labels
    String output_dir
    Int interval_days
    String start_date
    String end_date
    File selected_feature_ml_file
    String docker_image
    
    # Optional start date for performance evaluation (defaults to start_date if not provided)
    String? performance_start_date
    
    # Inputs from previous steps
    Array[File] features_pkls
    Array[File] y_scores
    Array[File] y_preds
    Array[File] ground_truths
    Array[File] pangos
    Array[File] classifiers
  }
  
  String actual_start_date = select_first([performance_start_date, start_date])
  
  command <<<!
    mkdir -p ~{output_dir} && \
    # Copy features
    if [ ~{length(features_pkls)} -gt 0 ]; then cp ~{sep=" " features_pkls} ~{output_dir}; fi && \
    # Copy prediction results
    if [ ~{length(y_scores)} -gt 0 ]; then cp ~{sep=" " y_scores} ~{output_dir}; fi && \
    if [ ~{length(y_preds)} -gt 0 ]; then cp ~{sep=" " y_preds} ~{output_dir}; fi && \
    if [ ~{length(ground_truths)} -gt 0 ]; then cp ~{sep=" " ground_truths} ~{output_dir}; fi && \
    if [ ~{length(pangos)} -gt 0 ]; then cp ~{sep=" " pangos} ~{output_dir}; fi && \
    if [ ~{length(classifiers)} -gt 0 ]; then cp ~{sep=" " classifiers} ~{output_dir}; fi && \
    
    echo "=== DEBUG: performance_surveillance inputs before run ==="
    ls -lR ~{output_dir}
    echo "======================================================="

    /app/run_hirisk.sh \
      --performance_surveillance \
      --alias ~{alias_file} \
      --wholabels ~{who_labels} \
      --output ~{output_dir} \
      --interval_days ~{interval_days} \
      --start_date ~{actual_start_date} \
      --end_date ~{end_date} \
      --selected_feature_ml ~{selected_feature_ml_file}
  >>>
  runtime {
    docker: docker_image
    memory: "8 GB"
    cpu: 4
    disks: "local-disk 20 HDD"
  }
  output {
    Array[File] roc_pdfs = glob(output_dir + "/ROC_*.pdf")
    Array[File] performance_pkls = glob(output_dir + "/performance_date_*.pkl")
    Array[File] pango_date_pkls = glob(output_dir + "/pango_date_*.pkl")
    Array[File] who_label_date_pkls = glob(output_dir + "/who_label_date_*.pkl")
    Array[File] earliest_pkls = glob(output_dir + "/*_earliest_*.pkl")
  }
}

workflow hiriskpredictor_performance_surveillance {
  input {
    File samples
    File alias_file
    File who_labels
    File selected_feature_ml_file
    Int interval_days = 7
    String start_date
    String end_date
    Int nprocesses = 7
    Int? nrows
    Boolean new_system = false
    String output_dir
    String? docker_image
    String? performance_start_date
  }
  
  String actual_docker_image = select_first([docker_image, "registry-vpc.miracle.ac.cn/auto-build/hiriskpredictor-wf:v0.3"])

  call calc_features { 
    input: 
      samples=samples, 
      alias_file=alias_file, 
      who_labels=who_labels, 
      output_dir=output_dir, 
      interval_days=interval_days, 
      start_date=start_date, 
      end_date=end_date, 
      nprocesses=nprocesses, 
      nrows=nrows, 
      docker_image=actual_docker_image 
  }
  
  call predict_surveillance { 
    input: 
      alias_file=alias_file, 
      who_labels=who_labels, 
      output_dir=output_dir, 
      interval_days=interval_days, 
      start_date=start_date, 
      end_date=end_date, 
      selected_feature_ml_file=selected_feature_ml_file, 
      new_system=new_system, 
      docker_image=actual_docker_image, 
      features_pkls=calc_features.features_pkls 
  }
  
  call performance_surveillance {
    input:
      alias_file=alias_file,
      who_labels=who_labels,
      output_dir=output_dir,
      interval_days=interval_days,
      start_date=start_date,
      end_date=end_date,
      performance_start_date=performance_start_date,
      selected_feature_ml_file=selected_feature_ml_file,
      docker_image=actual_docker_image,
      features_pkls=calc_features.features_pkls,
      y_scores=predict_surveillance.y_scores,
      y_preds=predict_surveillance.y_preds,
      ground_truths=predict_surveillance.ground_truths,
      pangos=predict_surveillance.pangos,
      classifiers=predict_surveillance.classifiers
  }

  output {
    String features_log = calc_features.log_path
    Array[File] y_scores = predict_surveillance.y_scores
    Array[File] y_preds = predict_surveillance.y_preds
    Array[File] classifiers = predict_surveillance.classifiers
    Array[File] roc_pdfs = performance_surveillance.roc_pdfs
    Array[File] performance_metrics = performance_surveillance.performance_pkls
  }
}
