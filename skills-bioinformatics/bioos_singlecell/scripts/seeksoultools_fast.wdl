version 1.0

workflow SeekSoulToolsFastWorkflow {
  input {
    File fq1
    File fq2
    String samplename
    File genome_tar
    String genome_name

    String chemistry = "DD-Q"
    Boolean include_introns = true
    Int core = 8

    Int memory_gb = 64
    Int disk_gb = 500
  }

  call SeekSoulToolsFastRun {
    input:
      fq1 = fq1,
      fq2 = fq2,
      samplename = samplename,
      genome_tar = genome_tar,
      chemistry = chemistry,
      include_introns = include_introns,
      core = core,
      genome_name = genome_name,
      memory_gb = memory_gb,
      disk_gb = disk_gb
  }

  output {
    File result_tar = SeekSoulToolsFastRun.result_tar
    File stdout_log = SeekSoulToolsFastRun.stdout_log
    File stderr_log = SeekSoulToolsFastRun.stderr_log
    File summary_json = SeekSoulToolsFastRun.summary_json
    File summary_csv = SeekSoulToolsFastRun.summary_csv
    File report_html = SeekSoulToolsFastRun.report_html
    File step1_file = SeekSoulToolsFastRun.step1_file
    File step2_file = SeekSoulToolsFastRun.step2_file
    File step3_file = SeekSoulToolsFastRun.step3_file
    File step4_file = SeekSoulToolsFastRun.step4_file
    File raw_feature_bc_matrix = SeekSoulToolsFastRun.raw_feature_bc_matrix
    File filtered_feature_bc_matrix = SeekSoulToolsFastRun.filtered_feature_bc_matrix
  }
}

task SeekSoulToolsFastRun {
  input {
    File fq1
    File fq2
    String samplename
    File genome_tar
    String chemistry
    String genome_name
    Boolean include_introns
    Int core
    Int memory_gb
    Int disk_gb
  }

  command <<<
    set -euo pipefail

    export PATH="/opt/conda/bin:/usr/local/bin:/usr/bin:/bin:${PATH}"

    # Some Cromwell backends run outside the image's interactive shell init.
    # Probe common install locations before failing.
    if ! command -v seeksoultools >/dev/null 2>&1; then
      for candidate in \
        /opt/conda/bin/seeksoultools \
        /usr/local/bin/seeksoultools \
        /usr/bin/seeksoultools \
        /bin/seeksoultools
      do
        if [[ -x "${candidate}" ]]; then
          export PATH="$(dirname "${candidate}"):${PATH}"
          break
        fi
      done
    fi

    if ! command -v seeksoultools >/dev/null 2>&1; then
      found_bin="$(find /opt /usr/local /usr/bin /bin -type f -name seeksoultools -perm -111 2>/dev/null | head -n 1 || true)"
      if [[ -n "${found_bin}" ]]; then
        export PATH="$(dirname "${found_bin}"):${PATH}"
      fi
    fi

    command -v seeksoultools
    command -v pigz
    command -v tar

    rm -rf "~{genome_name}" "/opt/~{genome_name}" "~{samplename}"
    mkdir -p "/opt/~{genome_name}"

    pigz -dc "~{genome_tar}" | tar -xvf - -C "$(pwd)"
    mv "~{genome_name}"/* "/opt/~{genome_name}/"

    cmd=(seeksoultools fast run
      --fq1 "~{fq1}"
      --fq2 "~{fq2}"
      --samplename "~{samplename}"
      --genomeDir "/opt/~{genome_name}/star/"
      --gtf "/opt/~{genome_name}/genes/genes.gtf"
      --chemistry "~{chemistry}"
      --core "~{core}"
      --include-introns
    )

    if [[ "~{include_introns}" == "true" ]]; then
      cmd+=(--include-introns)
    fi

    "${cmd[@]}"

    test -d "~{samplename}"
    tar -zcvf "~{samplename}.tar.gz" "~{samplename}"

    mv ./log ./log_old
    mv ~{samplename}/* ./

    tar -zcvf ~{samplename}_step1.tar.gz step1
    tar -zcvf ~{samplename}_step2.tar.gz step2
    tar -zcvf ~{samplename}_step3.tar.gz step3
    tar -zcvf ~{samplename}_step4.tar.gz step4

    mv step3/* ./
    tar -zcvf ~{samplename}_raw_feature_bc_matrix.tar.gz raw_feature_bc_matrix
    tar -zcvf ~{samplename}_filtered_feature_bc_matrix.tar.gz filtered_feature_bc_matrix
  >>>

  output {
    File result_tar = "~{samplename}.tar.gz"
    File summary_json = "~{samplename}_summary.json"
    File summary_csv = "~{samplename}_summary.csv"
    File report_html = "~{samplename}_report.html"
    File step1_file = "~{samplename}_step1.tar.gz"
    File step2_file = "~{samplename}_step2.tar.gz"
    File step3_file = "~{samplename}_step3.tar.gz"
    File step4_file = "~{samplename}_step4.tar.gz"
    File raw_feature_bc_matrix = "~{samplename}_raw_feature_bc_matrix.tar.gz"
    File filtered_feature_bc_matrix = "~{samplename}_filtered_feature_bc_matrix.tar.gz"
    File stdout_log = stdout()
    File stderr_log = stderr()
  }

  runtime {
    docker: "registry-vpc.miracle.ac.cn/gznl/seeksoultools:20260511"
    cpu: core
    memory: "~{memory_gb} GB"
    disks: "local-disk ~{disk_gb} HDD"
  }
}
