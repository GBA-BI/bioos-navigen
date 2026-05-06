version 1.0

workflow population_immunity_sars_cov2_analysis {
  input {
    String docker_image = "registry-vpc.miracle.ac.cn/gznl/population-immunity-wf:latest"
  }

  call selection_all { input: docker_image = docker_image }

  call create_data {
    input:
      docker_image = docker_image,
      s_hat_alpha_wt = selection_all.s_hat_alpha_wt,
      s_hat_delta_alpha = selection_all.s_hat_delta_alpha,
      s_hat_omi_delta = selection_all.s_hat_omi_delta,
      s_hat_ba2_ba1 = selection_all.s_hat_ba2_ba1,
      s_hat_ba45_ba2 = selection_all.s_hat_ba45_ba2,
      s_hat_bq1_ba45 = selection_all.s_hat_bq1_ba45
  }

  call create_immune_trajectory {
    input:
      docker_image = docker_image,
      Data_alpha_shift = create_data.Data_alpha_shift,
      Data_delta_shift = create_data.Data_delta_shift,
      Data_omi_shift = create_data.Data_omi_shift,
      Data_ba2_shift = create_data.Data_ba2_shift,
      Data_ba45_shift = create_data.Data_ba45_shift,
      Data_bq1_shift = create_data.Data_bq1_shift
  }

  call update_B {
    input:
      docker_image = docker_image,
      Data_alpha_shift = create_data.Data_alpha_shift,
      Data_delta_shift = create_data.Data_delta_shift,
      Data_omi_shift = create_data.Data_omi_shift,
      Data_ba2_shift = create_data.Data_ba2_shift,
      Data_ba45_shift = create_data.Data_ba45_shift,
      Data_bq1_shift = create_data.Data_bq1_shift
  }

  call create_average_frequency {
    input:
      docker_image = docker_image,
      data_immune_trajectories = create_immune_trajectory.data_immune_trajectories
  }

  call plot_figures {
    input:
      docker_image = docker_image,
      data_immune_trajectories = create_immune_trajectory.data_immune_trajectories,
      Update_gamma_inf = update_B.Update_gamma_inf
  }

  output {
    File data_immune_trajectories = create_immune_trajectory.data_immune_trajectories
    File selection_potentials = create_immune_trajectory.selection_potentials
    File selection_potentials_average = create_immune_trajectory.selection_potentials_average
    File? R_average = create_immune_trajectory.R_average
    File? R_average_may = create_immune_trajectory.R_average_may
    File Update_gamma_inf = update_B.Update_gamma_inf
    File Average_Frequencies = create_average_frequency.Average_Frequencies
    Array[File] figures = plot_figures.figures
  }
}

task selection_all {
  input {
    String docker_image
  }
  command <<<
    set -euo pipefail
    dest=$(pwd)
    cd /opt/app/Selection_Inference
    mkdir -p ../output
    # If precomputed outputs exist, skip recomputation
    if [ ! -f ../output/s_hat_alpha_wt.txt ]; then python selection_inference_alpha.py; fi
    if [ ! -f ../output/s_hat_delta_alpha.txt ]; then python selection_inference_delta.py; fi
    if [ ! -f ../output/s_hat_omi_delta.txt ]; then python selection_inference_omicron.py; fi
    if [ ! -f ../output/s_hat_ba2_ba1.txt ]; then python selection_inference_ba2.py; fi
    if [ ! -f ../output/s_hat_ba45_ba2.txt ]; then python selection_inference_ba5.py; fi
    if [ ! -f ../output/s_hat_bq1_ba45.txt ]; then python selection_inference_bq1.py; fi
    cp ../output/s_hat_alpha_wt.txt ${dest}/
    cp ../output/s_hat_delta_alpha.txt ${dest}/
    cp ../output/s_hat_omi_delta.txt ${dest}/
    cp ../output/s_hat_ba2_ba1.txt ${dest}/
    cp ../output/s_hat_ba45_ba2.txt ${dest}/
    cp ../output/s_hat_bq1_ba45.txt ${dest}/
  >>>
  runtime {
    docker: docker_image
  }
  output {
    File s_hat_alpha_wt = "s_hat_alpha_wt.txt"
    File s_hat_delta_alpha = "s_hat_delta_alpha.txt"
    File s_hat_omi_delta = "s_hat_omi_delta.txt"
    File s_hat_ba2_ba1 = "s_hat_ba2_ba1.txt"
    File s_hat_ba45_ba2 = "s_hat_ba45_ba2.txt"
    File s_hat_bq1_ba45 = "s_hat_bq1_ba45.txt"
  }
}

task create_data {
  input {
    String docker_image
    File s_hat_alpha_wt
    File s_hat_delta_alpha
    File s_hat_omi_delta
    File s_hat_ba2_ba1
    File s_hat_ba45_ba2
    File s_hat_bq1_ba45
  }
  command <<<
    set -eo pipefail
    dest=$(pwd)
    cd /opt/app
    mkdir -p output
    alpha_src="~{s_hat_alpha_wt}"
    delta_src="~{s_hat_delta_alpha}"
    omi_src="~{s_hat_omi_delta}"
    ba2_src="~{s_hat_ba2_ba1}"
    ba45_src="~{s_hat_ba45_ba2}"
    bq1_src="~{s_hat_bq1_ba45}"
    cp "$alpha_src" output/s_hat_alpha_wt.txt
    cp "$delta_src" output/s_hat_delta_alpha.txt
    cp "$omi_src" output/s_hat_omi_delta.txt
    cp "$ba2_src" output/s_hat_ba2_ba1.txt
    cp "$ba45_src" output/s_hat_ba45_ba2.txt
    cp "$bq1_src" output/s_hat_bq1_ba45.txt
    python Create_Data_ad_do.py
    python Create_Data_omicron.py
    cp output/Data_alpha_shift.txt "${dest}/"
    cp output/Data_delta_shift.txt "${dest}/"
    cp output/Data_omi_shift.txt "${dest}/"
    cp output/Data_ba2_shift.txt "${dest}/"
    cp output/Data_ba45_shift.txt "${dest}/"
    cp output/Data_bq1_shift.txt "${dest}/"
  >>>
  runtime {
    docker: docker_image
  }
  output {
    File Data_alpha_shift = "Data_alpha_shift.txt"
    File Data_delta_shift = "Data_delta_shift.txt"
    File Data_omi_shift = "Data_omi_shift.txt"
    File Data_ba2_shift = "Data_ba2_shift.txt"
    File Data_ba45_shift = "Data_ba45_shift.txt"
    File Data_bq1_shift = "Data_bq1_shift.txt"
  }
}

task create_immune_trajectory {
  input {
    String docker_image
    File Data_alpha_shift
    File Data_delta_shift
    File Data_omi_shift
    File Data_ba2_shift
    File Data_ba45_shift
    File Data_bq1_shift
  }
  command <<<
    set -eo pipefail
    dest=$(pwd)
    cd /opt/app
    mkdir -p output
    da_src="~{Data_alpha_shift}"
    dd_src="~{Data_delta_shift}"
    do_src="~{Data_omi_shift}"
    d2_src="~{Data_ba2_shift}"
    d45_src="~{Data_ba45_shift}"
    dq_src="~{Data_bq1_shift}"
    cp "$da_src" output/Data_alpha_shift.txt
    cp "$dd_src" output/Data_delta_shift.txt
    cp "$do_src" output/Data_omi_shift.txt
    cp "$d2_src" output/Data_ba2_shift.txt
    cp "$d45_src" output/Data_ba45_shift.txt
    cp "$dq_src" output/Data_bq1_shift.txt
    python Create_Immune_Trajectory_Data.py
    cp output/data_immune_trajectories.txt ${dest}/
    cp output/selection_potentials.txt ${dest}/
    cp output/selection_potentials_average.txt ${dest}/
    if [ -f output/R_average.txt ]; then cp output/R_average.txt ${dest}/; fi
    if [ -f output/R_average_may.txt ]; then cp output/R_average_may.txt ${dest}/; fi
  >>>
  runtime {
    docker: docker_image
    cpu: 2
    memory: "8G"
  }
  output {
    File data_immune_trajectories = "data_immune_trajectories.txt"
    File selection_potentials = "selection_potentials.txt"
    File selection_potentials_average = "selection_potentials_average.txt"
    File? R_average = "R_average.txt"
    File? R_average_may = "R_average_may.txt"
  }
}

task update_B {
  input {
    String docker_image
    File Data_alpha_shift
    File Data_delta_shift
    File Data_omi_shift
    File Data_ba2_shift
    File Data_ba45_shift
    File Data_bq1_shift
  }
  command <<<
    set -euo pipefail
    dest=$(pwd)
    cd /opt/app
    mkdir -p output
    cp ~{Data_alpha_shift} output/Data_alpha_shift.txt
    cp ~{Data_delta_shift} output/Data_delta_shift.txt
    cp ~{Data_omi_shift} output/Data_omi_shift.txt
    cp ~{Data_ba2_shift} output/Data_ba2_shift.txt
    cp ~{Data_ba45_shift} output/Data_ba45_shift.txt
    cp ~{Data_bq1_shift} output/Data_bq1_shift.txt
    python Update_B.py
    cp output/Update_gamma_inf.txt ${dest}/
  >>>
  runtime {
    docker: docker_image
  }
  output {
    File Update_gamma_inf = "Update_gamma_inf.txt"
  }
}

task create_average_frequency {
  input {
    String docker_image
    File data_immune_trajectories
  }
  command <<<
    set -euo pipefail
    dest=$(pwd)
    cd /opt/app
    mkdir -p output
    cp ~{data_immune_trajectories} output/data_immune_trajectories.txt
    python Create_Average_Frequency.py
    cp output/Average_Frequencies.txt ${dest}/
  >>>
  runtime {
    docker: docker_image
  }
  output {
    File Average_Frequencies = "Average_Frequencies.txt"
  }
}

task plot_figures {
  input {
    String docker_image
    File data_immune_trajectories
    File Update_gamma_inf
  }
  command <<<
    set -euo pipefail
    dest=$(pwd)
    cd /opt/app/Plot_Figures
    mkdir -p ../output
    cp ~{data_immune_trajectories} ../output/data_immune_trajectories.txt
    cp ~{Update_gamma_inf} ../output/Update_gamma_inf.txt
    python Plot_Fig1.py
    python Plot_Fig2.py
    python Plot_Fig3.py
    python Plot_Fig4_W.py
    python Plot_Fig4_redY.py
    python Plot_Fig5.py
    # Collect figures from both current directory and parent (if any)
    cp *.pdf ${dest}/ 2>/dev/null || true
    cp ../*.pdf ${dest}/ 2>/dev/null || true
  >>>
  runtime {
    docker: docker_image
  }
  output {
    Array[File] figures = glob("*.pdf")
  }
}