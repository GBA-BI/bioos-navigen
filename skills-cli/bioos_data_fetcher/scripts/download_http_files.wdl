version 1.0

workflow DownloadHTTPFiles {
    input {
        Array[String] urls = []
        File? manifest
        String docker_image = "registry-vpc.miracle.ac.cn/auto-build/sra-toolkit:v1"
        Int memory_gb = 4
        Int disk_space_gb = 20
        Int cpu_threads = 1
        Int retry_count = 5
        Int retry_delay_seconds = 10
        Int connect_timeout_seconds = 30
    }

    call DownloadHTTPFilesTask {
        input:
            urls = urls,
            manifest = manifest,
            docker_image = docker_image,
            memory_gb = memory_gb,
            disk_space_gb = disk_space_gb,
            cpu_threads = cpu_threads,
            retry_count = retry_count,
            retry_delay_seconds = retry_delay_seconds,
            connect_timeout_seconds = connect_timeout_seconds
    }

    output {
        Array[File] downloaded_files = DownloadHTTPFilesTask.downloaded_files
        File download_report = DownloadHTTPFilesTask.download_report
    }
}

task DownloadHTTPFilesTask {
    input {
        Array[String] urls
        File? manifest
        String docker_image
        Int memory_gb = 4
        Int disk_space_gb = 20
        Int cpu_threads = 1
        Int retry_count = 5
        Int retry_delay_seconds = 10
        Int connect_timeout_seconds = 30
    }

    command <<<
        set -euo pipefail

        mkdir -p downloads
        : > requested_files.tsv
        : > seen_file_names.txt

        cat > direct_urls.txt <<'DIRECT_URLS'
        ~{sep='\n' urls}
        DIRECT_URLS

        add_request() {
            local url="$1"
            local file_name="$2"
            local expected_sha256="$3"

            url="${url%$'\r'}"
            file_name="${file_name%$'\r'}"
            expected_sha256="${expected_sha256%$'\r'}"

            case "$url" in
                http://*|https://*) ;;
                *)
                    echo "Only HTTP/HTTPS URLs are allowed: $url" >&2
                    exit 2
                    ;;
            esac

            if [ -z "$file_name" ]; then
                local clean_url="${url%%\#*}"
                clean_url="${clean_url%%\?*}"
                file_name="${clean_url##*/}"
            fi

            case "$file_name" in
                ""|"."|".."|*/*|*\\*)
                    echo "Invalid output file name '$file_name' for URL: $url" >&2
                    echo "Provide a simple file_name in the manifest for URLs without a usable basename." >&2
                    exit 2
                    ;;
            esac

            if grep -Fqx "$file_name" seen_file_names.txt; then
                echo "Duplicate output file name '$file_name'. Use unique file_name values in the manifest." >&2
                exit 2
            fi

            if [ -n "$expected_sha256" ] && [ "$expected_sha256" != "-" ]; then
                if ! printf '%s' "$expected_sha256" | grep -Eq '^[0-9A-Fa-f]{64}$'; then
                    echo "Invalid SHA-256 value for '$file_name': $expected_sha256" >&2
                    exit 2
                fi
                expected_sha256=$(printf '%s' "$expected_sha256" | tr '[:upper:]' '[:lower:]')
            else
                expected_sha256=""
            fi

            printf '%s\n' "$file_name" >> seen_file_names.txt
            printf '%s\t%s\t%s\n' "$url" "$file_name" "$expected_sha256" >> requested_files.tsv
        }

        while IFS= read -r url || [ -n "$url" ]; do
            [ -z "$url" ] && continue
            add_request "$url" "" ""
        done < direct_urls.txt

        MANIFEST_PATH="~{default='' manifest}"
        if [ -n "$MANIFEST_PATH" ]; then
            line_number=0
            while IFS=$'\t' read -r url file_name expected_sha256 extra || [ -n "$url$file_name$expected_sha256$extra" ]; do
                line_number=$((line_number + 1))
                url="${url%$'\r'}"

                [ -z "$url" ] && continue
                case "$url" in \#*) continue ;; esac

                if [ "$line_number" -eq 1 ] && [ "$url" = "url" ]; then
                    continue
                fi

                if [ -n "$extra" ]; then
                    echo "Manifest line $line_number has more than three tab-separated columns." >&2
                    exit 2
                fi
                if [ -z "$file_name" ]; then
                    echo "Manifest line $line_number is missing the required file_name column." >&2
                    exit 2
                fi

                add_request "$url" "$file_name" "$expected_sha256"
            done < "$MANIFEST_PATH"
        fi

        request_count=$(wc -l < requested_files.tsv | tr -d '[:space:]')
        if [ "$request_count" -eq 0 ]; then
            echo "No download requests were provided. Set urls, manifest, or both." >&2
            exit 2
        fi

        printf 'url\tfile_name\tsize_bytes\tsha256\n' > download_report.tsv

        while IFS=$'\t' read -r url file_name expected_sha256; do
            destination="downloads/$file_name"
            partial="downloads/.$file_name.part"

            echo "Downloading $url as $file_name"

            curl_args=(
                --fail
                --location
                --show-error
                --silent
                --retry "~{retry_count}"
                --retry-delay "~{retry_delay_seconds}"
                --connect-timeout "~{connect_timeout_seconds}"
                --proto "=http,https"
                --output "$partial"
            )

            if [ -s "$partial" ]; then
                curl_args+=(--continue-at -)
            fi

            if ! curl "${curl_args[@]}" "$url"; then
                if [ -s "$partial" ]; then
                    echo "Resume failed; restarting '$file_name' from byte zero." >&2
                    rm -f "$partial"
                    curl \
                        --fail \
                        --location \
                        --show-error \
                        --silent \
                        --retry "~{retry_count}" \
                        --retry-delay "~{retry_delay_seconds}" \
                        --connect-timeout "~{connect_timeout_seconds}" \
                        --proto "=http,https" \
                        --output "$partial" \
                        "$url"
                else
                    exit 1
                fi
            fi

            actual_sha256=$(sha256sum "$partial" | awk '{print $1}')
            if [ -n "$expected_sha256" ] && [ "$actual_sha256" != "$expected_sha256" ]; then
                echo "SHA-256 mismatch for '$file_name'." >&2
                echo "Expected: $expected_sha256" >&2
                echo "Actual:   $actual_sha256" >&2
                exit 3
            fi

            mv "$partial" "$destination"
            size_bytes=$(wc -c < "$destination" | tr -d '[:space:]')
            printf '%s\t%s\t%s\t%s\n' "$url" "$file_name" "$size_bytes" "$actual_sha256" >> download_report.tsv
        done < requested_files.tsv

        echo "Downloaded $request_count file(s)."
    >>>

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }

    output {
        Array[File] downloaded_files = glob("downloads/*")
        File download_report = "download_report.tsv"
    }
}
