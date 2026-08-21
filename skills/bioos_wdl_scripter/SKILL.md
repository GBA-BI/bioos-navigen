---
name: bioos_wdl_scripter
description: Generate and format WDL workflows that run on Bio-OS platform. Trigger this skill when custom WDL workflow code needs to be developed.
---

# Bio-OS WDL Scripter

## 1. Operating Principle
This skill defines the procedures for generating platform-compliant WDL 1.0 workflows from logical analysis steps.

## 2. Execution Workflow (The SOP)

You must follow these steps sequentially to generate a working WDL file.

### Step 1: Write the WDL Script
Generate the WDL text according to the **WDL Generation Standard** below. Ensure every logical step is its own `task` and all tasks are tied together in a single `workflow` block. Save the file locally (e.g., to `/tmp/workflow.wdl`).

#### WDL Generation Standard (Mandatory)
You must strictly follow these rules when generating WDL content.

**1. Overall Structure Principles**
- **Information Source**: Derive the script content from the ongoing interaction with the user or from any JSON analysis cards provided in the context. Always consult the user if parameters are missing.
- **Define Steps**: Break down the scientific goal into a sequence of logical, discrete steps (e.g., QC, Alignment, Variant Calling).
- **One Task per Step**: Each step MUST be implemented as a distinct `task`.
- **Single File**: The complete workflow, including all tasks and the final `workflow` block, MUST be generated in a single `.wdl` file.
- **NO PLACEHOLDERS**: The WDL script MUST be completely fully-formed and executable. Do NOT write placeholders, pseudo-code, or hardcoded paths for reference files (e.g., `<insert genome here>`). All files required by the script MUST be exposed as parameters in the `input` section with the type `File` so they can be securely passed in via Bio-OS during execution.

**2. Task-Level Structure**
Each `task` you generate MUST adhere to the following rules:

- **Input Section (`input { ... }`)**:
    - **File Inputs**: All input files MUST use the `File` data type (never use `String` for file paths).
    - **Runtime Variables**: The four mandatory runtime variables MUST be declared with sensible defaults:
        - `String docker_image`: The default MUST be the exact image URL provided/built for this specific task.
        - `Int memory_gb = 8`
        - `Int disk_space_gb = 100`
        - `Int cpu_threads = 4`

- **Command Section (`command <<< ... >>>`)**:
    - **No Embedded Scripts**: You MUST NOT embed multi-line Python, R, or Perl scripts directly within the `command` block. If a complex operation requires a script, that script must be saved as a separate file, included in the Docker container, and called from here.
    - **Execution**: The command block should contain only the bash execution commands.

- **Runtime Section (`runtime { ... }`)**:
    - This section is MANDATORY for every `task`.
    - It MUST contain exactly the following mapped parameters:
      ```wdl
      runtime {
          docker: docker_image
          memory: memory_gb + "GB"
          disk: disk_space_gb + "GB"
          cpu: cpu_threads
      }
      ```

- **Output Section (`output { ... }`)**:
    - Explicitly map output files using relative paths or explicit file names written by the command.

**3. Workflow Section (`workflow { ... }`)**
- This section is MANDATORY.
- It defines the execution order by chaining the tasks together.
- It MUST be included at the bottom of the same `.wdl` file as the tasks.

### Step 2: Final Output
Actively present the generated `.wdl` file or its absolute file path to the user, or clearly state it is ready for subsequent steps in the pipeline development process.
