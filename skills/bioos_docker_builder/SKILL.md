---
name: bioos_docker_builder
description: Construct, diagnose, and compile linux/amd64 Docker images that run on Bio-OS. Trigger this skill when a Docker image is required to be built from scratch.
---

# Bio-OS Docker Builder

## 1. Operating Principle
This skill defines the procedures for constructing rock-solid, Bio-OS-compatible (`linux/amd64`) Docker containers to resolve Conda, Pip, and Apt dependencies for bioinformatics pipelines or IES applications.

## 2. Execution Workflow (The SOP)

You must follow these steps sequentially to build and deliver a working Docker image.

### Step 1: Write the Dockerfile
Generate the Dockerfile text according to the **Dockerfile Generation Standard** below. Save it locally (e.g., to `/tmp/Dockerfile`).

#### Dockerfile Generation Standard (Mandatory)
You must strictly follow these rules when generating Dockerfile content.

**1. Base Image**
- All Dockerfiles **must** use the following base image:
  `registry-vpc.miracle.ac.cn/infcprelease/ies-default:v0.0.14`

**2. Installation Methods**
- The base image comes with `mamba` and `conda` pre-installed.
- **Allowed Methods**:
    - `apt-get install`: **Allowed and Encouraged** for system dependencies.
    - `git clone`: **Preferred Method** for installing tools from GitHub. Clone directly in the Dockerfile to keep the build context small.
    - `pip install`: For packages available on PyPI.
    - `conda install` / `mamba install`: For packages available in Conda channels.
    - `COPY`: Use **only** when absolutely necessary (requires ZIP Archive build method in Step 2).

**3. Forbidden Practices**
- **No Source Configuration**: Do not configure `pip` or `conda` channel sources within the Dockerfile (e.g., no `pip config set` or modification of `.condarc`). The remote server handles this automatically.

**4. Structure and Commands**
- **WORKDIR**: You **must** set a working directory (e.g., `WORKDIR /app`).
- **Restricted Filename Rule**: The Dockerfile **must** be named exactly `Dockerfile` (case-sensitive, no extensions). Do NOT use names like `Dockerfile.bwa` or `bwa.dockerfile`.
- **ENTRYPOINT & CMD**:
    - **CRITICAL**: You **MUST NOT** include `ENTRYPOINT` or `CMD` instructions at the end of your Dockerfile (e.g., `CMD ["/bin/bash"]`). The base image handles the entrypoint. Overriding it causes startup failures.
    - **Exception**: If absolutely necessary for a specific *non-interactive* container, it must be `["/bin/bash"]`, but generally **omit it entirely**.
- **Compiled Tools (`make`)**:
    - **CRITICAL**: Simply running `make` is **INSUFFICIENT**. You must effectively "install" it globally.
    - **BAD**: `RUN make`
    - **GOOD**: `RUN make && make install` OR `RUN make && cp binary_name /usr/local/bin/` OR `ENV PATH="/path/to/build/bin:${PATH}"`

### Step 2: Submit the Build
Use the `build_docker_image` tool to submit the Dockerfile to the remote Bio-OS build server.
*   **Type 1 (Direct)**: If your Dockerfile is self-contained (no `COPY` instructions), just pass the absolute path of the `Dockerfile`.
*   **Type 2 (ZIP Archive)**: If your Dockerfile needs to `COPY` local scripts or assets:
    1. Create a staging directory.
    2. Move the `Dockerfile` and all assets into it.
    3. Zip the *contents* of the directory (e.g., `cd staging_dir/ && zip -r ../archive.zip .`).
    4. Pass the `.zip` absolute path to the tool.

### Step 3: Monitor & Retry (The 3-Strike Loop)
Because image building takes time and source compilation is error-prone, you must monitor the status.
1. **Poll**: Periodically call `check_build_status` using the Task ID returned from Step 2.
2. **Success**: If the status is `Success`, retrieve the `image_url` and proceed to Step 4.
3. **Failure (Strike 1 & 2)**: If a build fails, read the build logs. Attempt to diagnose and fix the compilation environment, update the local Dockerfile, and submit a new build (return to Step 2).
4. **Failure (Strike 3)**: After 3 total failures of a build for the same environment, you MUST STOP. Consult the user to ask how they want to proceed (e.g., try another method, find a different base image, or abandon the build).

### Step 4: Final Output
Once `check_build_status` returns `Success`, actively present the final built image URL (e.g., `registry-vpc.miracle...:tag`) to the user or use it to continue the Orchestrator's workflow.
