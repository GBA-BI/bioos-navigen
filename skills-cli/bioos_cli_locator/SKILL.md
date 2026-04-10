---
name: bioos_cli_locator
description: Resolve a runnable Bio-OS CLI launch recipe on the current machine. Use this skill when another Bio-OS CLI skill needs to execute commands but the correct launcher is not yet known.
---

# Bio-OS CLI Locator

## Operating Principle
This skill determines a reusable Bio-OS CLI launch recipe for the current machine and represents it as `<bioos_launch>` for downstream skills.

`<bioos_launch>` is not limited to a bare executable name. It may be any one-shot command prefix that reliably runs the CLI in the user's environment, for example:
- `bioos`
- `python3 -m bioos.cli.main`
- `conda run -n <env_name> bioos`
- `poetry run bioos`
- `uv run bioos`
- `pipenv run bioos`
- `/path/to/venv/bin/python -m bioos.cli.main`

## Resolution Workflow
Run these checks in order and stop at the first successful option.

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

6. If no runnable launch recipe can be resolved automatically
   - Ask the user for the exact command they usually use to run Bio-OS in that environment
   - Ask for a launcher, not for an installation path, because the launcher is what downstream skills need

## Usage Contract
- Once resolved, reuse the exact same `<bioos_launch>` in all subsequent Bio-OS CLI examples for that task.
- Prefer one-shot launchers over instructions that require mutating shell state mid-workflow.
- Do not hardcode machine-specific absolute paths in downstream skill instructions unless they were discovered on the current machine and are required for actual execution.
