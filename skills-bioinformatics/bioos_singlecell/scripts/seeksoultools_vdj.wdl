version 1.0

workflow SeekSoulToolsVdjWorkflow {
  input {
    File fq1
    File fq2
    String samplename

    # Use TCR for T cell receptor analysis, BCR for B cell receptor analysis.
    String chain

    String chemistry = "DD5V1"
    String organism = "human"
    Int core = 16

    Int memory_gb = 64
    Int disk_gb = 500
  }

  call SeekSoulToolsVdjRun {
    input:
      fq1 = fq1,
      fq2 = fq2,
      samplename = samplename,
      chemistry = chemistry,
      chain = chain,
      organism = organism,
      core = core,
      memory_gb = memory_gb,
      disk_gb = disk_gb
  }

  output {
    File result_tar = SeekSoulToolsVdjRun.result_tar
    File run_tar = SeekSoulToolsVdjRun.run_tar
    File outs_tar = SeekSoulToolsVdjRun.outs_tar
    File stdout_log = SeekSoulToolsVdjRun.stdout_log
    File stderr_log = SeekSoulToolsVdjRun.stderr_log
    File airr_rearrangement_csv = SeekSoulToolsVdjRun.airr_rearrangement_csv
    File all_contig_annotations_csv = SeekSoulToolsVdjRun.all_contig_annotations_csv
    File clontypes_csv = SeekSoulToolsVdjRun.clontypes_csv
    File metrics_summary_csv = SeekSoulToolsVdjRun.metrics_summary_csv
    File consensus_fasta = SeekSoulToolsVdjRun.consensus_fasta
    File consensus_annotations_csv = SeekSoulToolsVdjRun.consensus_annotations_csv
    File all_contig_fasta = SeekSoulToolsVdjRun.all_contig_fasta
    File filtered_contig_igblast = SeekSoulToolsVdjRun.filtered_contig_igblast
    File filtered_contig_annotations_csv = SeekSoulToolsVdjRun.filtered_contig_annotations_csv
    File report_html = SeekSoulToolsVdjRun.report_html
  }
}

task SeekSoulToolsVdjRun {
  input {
    File fq1
    File fq2
    String samplename
    String chemistry
    String chain
    String organism
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
    command -v tar

    case "~{chain}" in
      TCR)
        vdj_chain="TR"
        ;;
      BCR)
        vdj_chain="IG"
        ;;
      *)
        echo "ERROR: chain must be TCR or BCR, got '~{chain}'." >&2
        exit 1
        ;;
    esac

    rm -rf "~{samplename}" "~{samplename}.tar.gz"
    mkdir -p "~{samplename}"

    seeksoultools vdj run \
      --fq1 "~{fq1}" \
      --fq2 "~{fq2}" \
      --chemistry "~{chemistry}" \
      --samplename "~{samplename}" \
      --chain "${vdj_chain}" \
      --core "~{core}" \
      --outdir "$(pwd)/~{samplename}" \
      --organism "~{organism}"

    test -d "~{samplename}"
    tar -zcvf "~{samplename}.tar.gz" "~{samplename}"

    mv ./log ./log_old
    mv ~{samplename}/* ./
    tar -zcvf ~{samplename}_run.tar.gz run
    tar -zcvf ~{samplename}_outs.tar.gz outs
  >>>

  output {
    File result_tar = "~{samplename}.tar.gz"
    File run_tar = "~{samplename}_run.tar.gz"
    File outs_tar = "~{samplename}_outs.tar.gz"
    File airr_rearrangement_csv = "outs/airr_rearrangement.csv"
    File all_contig_annotations_csv = "outs/all_contig_annotations.csv"
    File clontypes_csv = "outs/clonotypes.csv"
    File metrics_summary_csv = "outs/metrics_summary.csv"
    File consensus_fasta = "outs/consensus.fasta"
    File consensus_annotations_csv = "outs/consensus_annotations.csv"
    File all_contig_fasta = "outs/all_contig.fasta"
    File filtered_contig_igblast = "outs/filtered_contig_igblast.fasta"
    File filtered_contig_annotations_csv = "outs/filtered_contig_annotations.csv"
    File report_html = "outs/report.html"
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
