# Troubleshooting Guide

This guide provides solutions to common problems, particularly related to Docker and WDL.

## Issue 1: Python Dependency Installation Fails During Docker Build

**Symptom**: The `pip install -r requirements.txt` command fails, often with an error like `g++: not found` or an inability to find a matching distribution.

**Cause**: A version specified in `requirements.txt` is too strict (using `==`). This forces `pip` to find an exact version, which may not have a pre-compiled wheel for the `linux/amd64` architecture, leading to an attempt to compile from source without the necessary build tools.

**Solution**: Loosen the version constraint from `==` to `>=`.

-   **Before**: `biopython==1.81`
-   **After**: `biopython>=1.81`

**Rationale**: Using `>=` allows `pip` to select the oldest compatible version that has a pre-compiled wheel available, avoiding the need for source compilation.

---




## Issue 2: Python Script's Relative Paths Fail Inside Container

**Symptom**: `FileNotFoundError: [Errno 2] No such file or directory: '../data/file.csv'`.

**Cause**: The script's working directory inside the container is not what the developer assumed. Cromwell executes in its own directory, which is mounted into the container, but the script might be run from `/app/` or another path.

**Solution**: **Never use relative paths in Python scripts.** Construct absolute paths dynamically.

-   **Python Example**:
    ```python
    import os

    # Get the directory where the script is located.
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    # Assume the project's base path is one level up.
    BASE_PATH = os.path.dirname(SCRIPT_DIR)

    # Construct absolute paths for data and results.
    data_path = os.path.join(BASE_PATH, 'data', 'input.csv')
    output_path = os.path.join(BASE_PATH, 'results', 'output.csv')

    # Ensure the output directory exists before writing.
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    ```

---

## Self-Checklist Before Proceeding

### Dockerfile
-   [ ] Base Image: `registry-vpc.miracle.ac.cn/infcprelease/ies-default:latest`
-   [ ] **No `ENTRYPOINT` set** that would conflict with WDL commands.
-   [ ] Build docker through build_docker_image MCP tool.

### WDL
-   [ ] No embedded Python code in the `command` block.
-   [ ] `command` block correctly calls scripts from the Docker image.
-   [ ] All file inputs use the `File` type.
-   [ ] Each `task` has a `runtime` block with `docker`, `memory`, `disk_space`, and `cpu` variables.
-   [ ] Each `task` `input` section declares the runtime variables (e.g., `String docker_image`, `Int memory_gb`).
-   [ ] The `docker_image` input has a valid default value.
-   [ ] All outputs are declared with relative paths in the `output` block.
-   [ ] `validate_wdl` passes successfully.
