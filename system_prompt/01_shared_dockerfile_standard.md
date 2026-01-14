# Dockerfile Generation Standard

This document defines the unified standard for generating Dockerfile content. You, the Agent, are responsible for creating the content accordingto these rules. This standard applies to all Dockerfiles, whether for WDL tasks or for IES environments.

## 1. Base Image (Mandatory)

- All Dockerfiles **must** use the following base image:
  `registry-vpc.miracle.ac.cn/infcprelease/ies-default:v0.0.14`

## 2. Installation Methods (Flexible)

- You have the flexibility to choose the best installation method based on the software requirements. The `registry-vpc.miracle.ac.cn/infcprelease/ies-default:v0.0.14` base image comes with `conda` pre-installed.
- **Allowed Methods**:
    - `apt-get install`: **Allowed and Encouraged** for system dependencies.
    - `git clone`: **Preferred Method** for installing tools from GitHub. Clone directly in the Dockerfile to keep the build context small.
    - `pip install`: For packages available on PyPI.
    - `conda install`: For packages available in Conda channels.
    - `COPY`: Use **only** when absolutely necessary (e.g., for local custom scripts). Avoid `COPY . .` if a `git clone` can achieve the same result. **Note: Using `COPY` requires the ZIP archive build method (Type 2).**

## 3. Forbidden Practices

- **No Source Configuration**: Do not configure `pip` or `conda` channel sources within the Dockerfile (e.g., no `pip config set` or modification of `.condarc`). The remote build service (`build_docker_image`) handles this server-side for optimization and standardization.
- **No Source Configuration**: Do not configure `pip` or `conda` channel sources within the Dockerfile (e.g., no `pip config set` or modification of `.condarc`). The remote build service (`build_docker_image`) handles this server-side for optimization and standardization.

## 4. Structure and Commands

- **WORKDIR**: You **must** set a working directory, for example: `WORKDIR /app`.
- **ENTRYPOINT**:
    - This directive should generally be **omitted**.
    - If absolutely necessary, it **must** be set only to `/bin/bash`. No other entrypoints are allowed. This ensures containers are interactive and compatible with WDL command overrides.
    - If you install a tool from source (e.g., using `make`), you **must** ensure it is executable globally.
    - **CRITICAL**: Simply running `make` is **INSUFFICIENT**. You must effectively "install" it.
    - **BAD**: `RUN make` (The binary stays in the build dir, unavailable to the user).
    - **GOOD (Option A)**: `RUN make && make install` (if supported).
    - **GOOD (Option B)**: `RUN make && cp binary_name /usr/local/bin/`.
    - **GOOD (Option C)**: `ENV PATH="/path/to/build/bin:${PATH}"`.

## 5. Build Process and `source_path` Types

The `build_docker_image` MCP-Tool accepts two types of `source_path` parameter. Your primary decision is to determine if your Dockerfile requires the `COPY` instruction.

### **Restricted Filename Rule**
- The Dockerfile **must** be named exactly `Dockerfile` (case-sensitive, no extensions).
- **CRITICAL**: Do NOT use names like `Dockerfile.bwa` or `bwa.dockerfile`. The system will reject them.


### Type 1: Direct Dockerfile Path (for self-contained Dockerfiles)
-   **When to Use**: Use this simpler method when your Dockerfile is self-contained and does **not** require any `COPY` instructions for local files. It can still use `RUN` commands with `pip`, `conda`, or `git clone`.
-   **Process**: Provide the absolute path directly to the `Dockerfile` as the `source_path` parameter.

### Type 2: ZIP Archive Path (for Dockerfiles with `COPY`)
-   **When to Use**: You **must** use this method whenever your Dockerfile needs to use the `COPY` instruction to include local scripts, configuration files, or other assets from your workspace.
-   **Process**:
    1.  Create a temporary staging directory (e.g., `staging_dir`).
    2.  Copy the `Dockerfile` AND all required local files (the source of the `COPY` commands) into this staging directory.
    3.  **Crucially, create the ZIP archive from the *contents* of the staging directory.** This ensures the `Dockerfile` is at the root of the archive. The correct procedure is to change directory into the staging directory and then zip its contents. For example: `cd staging_dir/ && zip -r ../archive.zip .`.
    4.  Provide the absolute path to this new `.zip` file as the `source_path` parameter to `build_docker_image`.
    5.  After the build is initiated, you may clean up the temporary staging directory and the ZIP archive.
