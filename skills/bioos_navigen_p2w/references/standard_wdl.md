# WDL Generation Standard

This document defines the unified standard for generating WDL (Workflow Description Language) scripts. You, the Agent, are responsible for creating the entire script content according to these rules.

## 1. Overall Structure Principles

1.  **Information Source**:
    - In **General Mode**, script content is derived from interaction with the user.
    - In **Paper2Workspace Mode**, script content is derived from the analysis of the paper and its code repository. However, you can still ask user for help when needed.
2.  **Define Steps**: First, break down the scientific goal into a sequence of logical, discrete steps (e.g., QC, Alignment, Variant Calling).
3.  **One Task per Step**: Each step must be implemented as a distinct `task`.
4.  **Single File**: The complete workflow, including all tasks and the final `workflow` block, must be generated in a single `.wdl` file.

## 2. Task-Level Structure (Mandatory)

Each `task` you generate **must** adhere to the following structure and rules.

### Input Section (`input { ... }`)
-   **File Inputs**: All inputs that are files **must** use the `File` data type. Never use `String` for file paths.
-   **Runtime Inputs**: The four mandatory runtime variables (see below) must be declared here. You can and should provide sensible default values based on your knowledge and the task's requirements.
    - `String docker_image`: **Crucially, the default value for this must be an image URL provided by the user or one that you have just collaboratively built for this specific task.**
    - `Int memory_gb = 8`
    - `Int disk_space_gb = 100`
    - `Int cpu_threads = 4`

### Command Section (`command <<< ... >>>`)
-   **No Embedded Scripts**: You **must not** embed multi-line Python, R, or Perl scripts directly within the `command` block. This practice leads to errors that are difficult to debug.
-   **If Scripts Are Needed**: If a complex operation requires a script, that script must be saved as a separate file (e.g., `my_script.py`), be included in the task's Docker container, and then be called from the `command` block.
-   **Execution**: The command block should contain only the shell commands necessary to execute the tools provided by the Docker container.

### Runtime Section (`runtime { ... }`)
-   This section is **mandatory** for every `task`.
-   It **must** contain exactly the following four parameters, using the variable names declared in the `input` section.

    ```wdl
    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
    ```

### Example Task Structure

Here is a complete example of a well-formed `task` that follows all the rules:

```wdl
task star_align {
    input {
        File read1_fastq
        File read2_fastq
        File star_index_dir
        String sample_name

        # Mandatory runtime inputs with defaults
        String docker_image = "registry.hub.docker.com/biocontainers/star:2.7.10a--h9ee0642_0"
        Int memory_gb = 32
        Int disk_space_gb = 200
        Int cpu_threads = 8
    }

    command <<<
        STAR \
            --genomeDir ~{star_index_dir} \
            --readFilesIn ~{read1_fastq} ~{read2_fastq} \
            --readFilesCommand zcat \
            --runThreadN ~{cpu_threads} \
            --outFileNamePrefix ~{sample_name}_ \
            --outSAMtype BAM SortedByCoordinate
    >>>

    output {
        File sorted_bam = "~{sample_name}_Aligned.sortedByCoord.out.bam"
    }

    runtime {
        docker: docker_image
        memory: memory_gb + "GB"
        disk_space: disk_space_gb + "GB"
        cpu: cpu_threads
    }
}
```

## 3. Workflow Section (`workflow { ... }`)

-   This section is **mandatory**.
-   It defines the execution order by chaining the tasks together by calling them and providing their inputs.
-   It **must** be included in the same single `.wdl` file as the tasks.

### Example Workflow Structure

This example shows how to call the `star_align` task defined previously.

```wdl
workflow alignment_workflow {
    input {
        File read1
        File read2
        File star_index
        String sample
    }

    call star_align {
        input:
            read1_fastq = read1,
            read2_fastq = read2,
            star_index_dir = star_index,
            sample_name = sample
    }

    output {
        File final_bam = star_align.sorted_bam
    }
}
```