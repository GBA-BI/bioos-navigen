---
name: bioos_cli_locator
description: Resolve a runnable Bio-OS CLI launch recipe on the current machine. Use this skill when another Bio-OS CLI skill needs to execute commands but the correct launcher is not yet known.
---

# Bio-OS CLI Locator

## Operating Principle
This skill determines a reusable Bio-OS CLI launch recipe for the current machine and represents it as `<bioos_launch>` for downstream skills.

It should also bootstrap `pybioos` when the CLI is not installed yet. Do this only after all local launcher discovery checks fail, then install `pybioos`, re-run launcher discovery, and finally guide first-time credential setup if the CLI is present but not configured.

`<bioos_launch>` is not limited to a bare executable name. It may be any one-shot command prefix that reliably runs the CLI in the user's environment, for example:
- `bioos`
- `python3 -m bioos.cli.main`
- `conda run -n <env_name> bioos`
- `poetry run bioos`
- `uv run bioos`
- `pipenv run bioos`
- `/path/to/venv/bin/python -m bioos.cli.main`

## Resolution Workflow
Run these checks in order. Stop at the first successful launcher, except where an installation or configuration verification step explicitly says to continue.

1. Prefer a direct executable already available in the current shell
   - Run `command -v bioos`
   - If it succeeds, set `<bioos_launch>` to `bioos`

2. Check whether the current Python interpreter can already run the module
   - Run `python3 -m bioos.cli.main --help`
   - If it succeeds, set `<bioos_launch>` to `python3 -m bioos.cli.main`

3. Inspect the active environment generically
   - If `VIRTUAL_ENV` is set, test `<venv>/bin/python -m bioos.cli.main --help`
   - If `CONDA_PREFIX` is set, test `<conda_prefix>/bin/bioos --help` and `<conda_prefix>/bin/python -m bioos.cli.main --help`
   - If one succeeds, set `<bioos_launch>` to that working recipe

4. Inspect common project-local launchers generically
   - In the current workspace, check standard local environment locations such as `.venv`, `venv`, or `env`
   - Prefer testing their Python interpreter with `-m bioos.cli.main --help` instead of assuming shell activation state
   - If one succeeds, set `<bioos_launch>` to that working recipe

5. Inspect common environment managers only when they are already present
   - If `conda` exists, a valid one-shot launcher may be `conda run -n <env_name> bioos`
   - If `poetry` exists, test `poetry run bioos --help`
   - If `uv` exists, test `uv run bioos --help`
   - If `pipenv` exists, test `pipenv run bioos --help`
   - Use one of these only after verifying it actually works in the current workspace

6. If no runnable launch recipe can be resolved automatically, install `pybioos`
   - Treat this as the normal first-run path for agents that have installed Bio-OS NaviGen skills but do not yet have the `pybioos` package.
   - Prefer the current active Python environment:
     - If `VIRTUAL_ENV` is set, run `<venv>/bin/python -m pip install pybioos`
     - Else if `CONDA_PREFIX` is set, run `<conda_prefix>/bin/python -m pip install pybioos`
     - Else run `python3 -m pip install --user pybioos`
   - Do not use `sudo`, do not change global pip configuration, and do not install before steps 1-5 have failed.
   - If installation fails because the Python environment is externally managed or user-site installs are disabled, ask the user whether to create/use a virtual environment or provide their preferred launcher.
   - After installation, repeat steps 1-4. If a launcher works, set `<bioos_launch>` to that recipe.
   - If the package installs but the `bioos` executable is not on `PATH`, prefer `python3 -m bioos.cli.main` or the environment-specific Python module launcher instead of asking the user to edit shell startup files.

7. Verify first-time `pybioos` configuration after a launcher is resolved
   - Run `<bioos_launch> config path --pretty` to discover the config path. By default this is `~/.bioos/config.yaml`, unless `BIOOS_CONFIG_PATH` is set.
   - Run `<bioos_launch> auth status --pretty` to check whether access key, secret key, endpoint, and region are resolved. This command masks the access key in output.
   - `pybioos` resolves credentials in this order: explicit CLI flags, environment variables (`MIRACLE_ACCESS_KEY`, `MIRACLE_SECRET_KEY`, `BIOOS_ENDPOINT`, `BIOOS_REGION`), then the local config file.
   - If credentials are missing, guide the user to configure them before running downstream Bio-OS commands. Do not fabricate credentials.
   - Prefer persistent config for normal use. The config payload is:

```yaml
client:
  MIRACLE_ACCESS_KEY: "<AK>"
  MIRACLE_SECRET_KEY: "<SK>"
  serveraddr: "https://bio-top.miracle.ac.cn"
  region: "cn-north-1"
  repository_endpoint: "https://network.miracle.ac.cn"
```

   - If the user wants the agent to write AK/SK into the config file, first get explicit user approval and the actual values. Write only to the path reported by `<bioos_launch> config path --pretty`, create parent directories if needed, preserve unrelated existing config when practical, and set file permissions to owner-only, for example `chmod 600 ~/.bioos/config.yaml`.
   - Never print, commit, or include AK/SK in generated files. Use placeholders in examples and masked values in status summaries.
   - After configuration, rerun `<bioos_launch> auth status --pretty`. If it is not successful, report the masked status and the actionable error.

8. If installation and configuration guidance still cannot produce a runnable launcher
   - Ask the user for the exact command they usually use to run Bio-OS in that environment
   - Ask for a launcher, not for an installation path, because the launcher is what downstream skills need

## Usage Contract
- Once resolved, reuse the exact same `<bioos_launch>` in all subsequent Bio-OS CLI examples for that task.
- Prefer one-shot launchers over instructions that require mutating shell state mid-workflow.
- Do not skip install/bootstrap guidance when all discovery checks fail on a new agent machine.
- Do not run downstream Bio-OS operations that require authentication until `<bioos_launch> auth status --pretty` confirms usable credentials or the user explicitly supplies `--ak`, `--sk`, and optional endpoint overrides for that one command.
- Do not hardcode machine-specific absolute paths in downstream skill instructions unless they were discovered on the current machine and are required for actual execution.
