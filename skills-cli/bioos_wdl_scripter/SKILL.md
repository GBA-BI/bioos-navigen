---
name: bioos_wdl_scripter
description: Generate and format WDL workflows for Bio-OS platform execution. Trigger this skill when custom WDL workflow code needs to be developed.
---

# Bio-OS WDL Scripter

## Operating Principle
This skill defines the procedure for generating platform-compliant WDL 1.0 workflows for Bio-OS platform execution.

## Execution Workflow

### Step 1: Write the WDL script
Generate one complete `.wdl` file locally.

#### WDL Generation Standard
You must follow these rules.

1. Overall structure
- Derive the workflow from the user request or any project card already in context
- Break the scientific goal into discrete logical steps
- Implement each step as its own `task`
- Keep the full set of tasks and the `workflow` block in one file
- Do not leave placeholders, pseudo-code, or hardcoded reference paths
- Every required file must be exposed as a `File` input

2. Task-level structure
- Each `task` must have an `input` block
- File inputs must use `File`, not `String`
- Each task must declare these runtime variables with sensible defaults:
  - `String docker_image`
  - `Int memory_gb = 8`
  - `Int disk_space_gb = 100`
  - `Int cpu_threads = 4`
- Do not embed multi-line Python, R, or Perl scripts inside `command <<< >>>`
- Every task must include this exact runtime mapping:

```wdl
runtime {
    docker: docker_image
    memory: memory_gb + "GB"
    disk_space: disk_space_gb + "GB"
    cpu: cpu_threads
}
```

- Every task must include an explicit `output` block

3. Workflow structure
- The `workflow` block is mandatory
- The `workflow` block must connect tasks in the intended execution order

### Step 2: Final Output
Present the generated WDL file path or the final WDL content and make it available for downstream platform execution.
