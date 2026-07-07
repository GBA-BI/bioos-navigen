---
name: bioos_docker_builder
description: Construct, diagnose, and compile linux/amd64 Docker images for Bio-OS by using the Bio-OS CLI docker commands. Trigger this skill when a Bio-OS-compatible image must be built from scratch.
---

# Bio-OS Docker Builder

Resolve the Bio-OS CLI launcher first and refer to it as `<bioos_launch>`. If it is not known yet, explicitly load the `bioos_cli_locator` skill before running the commands below.

## Operating Principle
This skill defines the standard procedure for constructing Bio-OS-compatible `linux/amd64` Docker images for workflows or IES applications.

## Execution Workflow

### Step 1: Write the Dockerfile
Generate the Dockerfile locally and save it as `Dockerfile`.

#### Dockerfile Generation Standard
You must follow these rules.

1. Base image
- Always use `registry-vpc.miracle.ac.cn/infcprelease/ies-default:v0.0.14`

2. Installation methods
- `apt-get install`: allowed and encouraged for system dependencies
- `git clone`: preferred for GitHub-hosted tools
- `pip install`: allowed for PyPI packages
- `conda install` or `mamba install`: allowed for Conda packages
- `COPY`: use only when necessary, because it requires the ZIP build flow in Step 2

3. Forbidden practices
- Do not reconfigure `pip` or `conda` sources inside the Dockerfile

4. Structure and commands
- You must set a `WORKDIR`
- The file must be named exactly `Dockerfile`
- Do not set `ENTRYPOINT` or `CMD` unless a specific non-interactive container absolutely requires it
- If you compile with `make`, make the binaries usable globally with `make install`, `cp ... /usr/local/bin/`, or `ENV PATH=...`

### Step 2: Submit the build with CLI
Choose deterministic `repo_name` and `tag`, then submit the build through the CLI.

- Direct Dockerfile build:
  `<bioos_launch> docker build --repo-name <repo_name> --tag <tag> --source-path /abs/path/to/Dockerfile --output json --pretty`
- ZIP build for Dockerfiles that use `COPY`:
  1. Create a staging directory
  2. Put `Dockerfile` and all required assets into it
  3. Zip the contents of that directory
  4. Run `<bioos_launch> docker build --repo-name <repo_name> --tag <tag> --source-path /abs/path/to/archive.zip --output json --pretty`

Immediately compute the final image URL as well:
- `<bioos_launch> docker url --repo-name <repo_name> --tag <tag> --output json`

Record two things:
- the build task id from the `docker build` JSON response
- the final image URL from `docker url` or the `ImageURL` field returned by the build response

### Step 3: Monitor and retry
Poll the build status with:
- `<bioos_launch> docker status --task-id <task_id> --output json --pretty`

Use this loop:
1. If the status says the build succeeded, stop and keep the final image URL.
2. If the build failed, inspect the returned error or log fields, fix the Dockerfile, and submit a new build.
3. After 3 total failures for the same environment, stop and ask the user how they want to proceed.

### Step 4: Final Output
When the build succeeds, actively present the final image URL and use it in the downstream workflow or IES configuration.
