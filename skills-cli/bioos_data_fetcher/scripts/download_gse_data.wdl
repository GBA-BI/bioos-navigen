version 1.0

workflow DownloadGSE {
    input {
        String gse_id
        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/sra-toolkit:v1"
        Int cpus = 2
        Int mem_gb = 4
        Int disk_gb = 50
    }

    call DownloadGSETask {
        input:
            gse_id = gse_id,
            docker_image = docker_image,
            cpus = cpus,
            mem_gb = mem_gb,
            disk_gb = disk_gb
    }

    output {
        Array[File] output_files = DownloadGSETask.out_files
    }
}

task DownloadGSETask {
    input {
        String gse_id
        String docker_image
        Int cpus
        Int mem_gb
        Int disk_gb
    }

    String target_dir = "gse_download"

    command <<<
        set -euo pipefail

        # Convert to uppercase and strip whitespace
        GSE_ID=$(echo "~{gse_id}" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
        
        # We need bash, curl, xmllint tools (which ubuntu brings)
        apt-get update && apt-get install -y curl wget || true

        echo "Starting download for ${GSE_ID} to ~{target_dir}..."
        mkdir -p ~{target_dir}

        # Calculate prefix (folder1)
        NUM_PART="${GSE_ID#GSE}"
        NUM_LEN=${#NUM_PART}
        if [ "$NUM_LEN" -le 3 ]; then
            PREFIX="GSEnnn"
        else
            BASE_LEN=$(( ${#GSE_ID} - 3 ))
            PREFIX="${GSE_ID:0:$BASE_LEN}nnn"
        fi

        BASE_URL="https://ftp.ncbi.nlm.nih.gov/geo/series/${PREFIX}/${GSE_ID}"
        echo "Base URL derived as: ${BASE_URL}"

        # We download 'matrix' and 'suppl' and 'miniml' if available
        for SUBDIR in matrix suppl miniml soft; do
            echo "Checking ${SUBDIR} directory..."
            SUBDIR_URL="${BASE_URL}/${SUBDIR}/"
            
            # Use curl to get the directory listing, ignoring errors if no dir exists
            set +e
            HTTP_CODE=$(curl -sL -w "%{http_code}" -o /tmp/index.html "${SUBDIR_URL}")
            set -e

            if [ "${HTTP_CODE}" = "200" ]; then
                echo "Directory ${SUBDIR} exists. Downloading files..."
                mkdir -p "~{target_dir}/${SUBDIR}"
                
                # Use grep over HTML hrefs.
                # Only include valid data files: Exclude ? (query params), / (absolute paths), https? (external links), and require a dot (file extension).
                FILES=$(grep -oI 'href="[^"]*"' /tmp/index.html | sed 's/href="//g' | sed 's/"//g' | grep -v '^?' | grep -v '^/' | grep -v '^http' | grep '\.')
                
                for FILE in $FILES; do
                    echo " -> Downloading ${FILE}..."
                    # We can use wget with resume, add retries and force IPv4, remove -q to see errors
                    wget --tries=5 --timeout=60 --waitretry=10 -nv -4 -c "${SUBDIR_URL}${FILE}" -O "~{target_dir}/${SUBDIR}/${FILE}" || curl -L --retry 5 -o "~{target_dir}/${SUBDIR}/${FILE}" -C - "${SUBDIR_URL}${FILE}"
                done
            else
                echo "Directory ${SUBDIR} skipped (HTTP ${HTTP_CODE})"
            fi
        done
        
        # Return all files within the subdirectories
        echo "GSE download routine finished."
    >>>

    runtime {
        docker: docker_image
        cpu: "~{cpus}"
        memory: "~{mem_gb} GB"
        disks: "local-disk " + disk_gb + " SSD"
        preemptible: 3
    }

    output {
        Array[File] out_files = glob("~{target_dir}/*/*")
    }
}
