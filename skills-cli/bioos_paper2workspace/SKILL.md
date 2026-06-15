---
name: bioos_paper2workspace
description: Parse and orchestrate the reproduction of a computational biology paper on Bio-OS platform. Trigger this skill when the user provides a paper or asks to reproduce a paper on Bio-OS.
---

# Bio-OS Paper2Workspace

Resolve the Bio-OS CLI launcher first and refer to it as `<bioos_launch>`. If it is not known yet, explicitly load the `bioos_cli_locator` skill before running the commands below.

## Operating Principle
This skill defines the end-to-end procedure for converting a paper or analysis repository into an executable Bio-OS workspace.

## The Card
Maintain a JSON card named `{Timestamp}_{UUID}_p2w_card.json` in the user's current directory. Initialize it in Stage 1 and update it at the end of every stage.

### Paper2Workspace Context Schema
Use this schema shape exactly.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Paper2Workspace_Context_v1",
  "type": "object",
  "required": ["schema_version", "status", "paper_meta_info", "reproduce_decision"],
  "properties": {
    "schema_version": { "type": "string", "const": "1.0.0" },
    "status": {
      "type": "string",
      "enum": [
        "initial",
        "stage_1_complete",
        "stage_2_complete",
        "stage_3_complete",
        "stage_4_complete",
        "finished",
        "failed"
      ]
    },
    "project_id": { "type": "string" },
    "paper_meta_info": {
      "type": "object",
      "required": ["title", "paper_type"],
      "properties": {
        "title": { "type": "string" },
        "doi": { "type": "string" },
        "published_at": { "type": "string" },
        "authors": { "type": "array", "items": { "type": "string" } },
        "organizations": { "type": "array", "items": { "type": "string" } },
        "journal": { "type": "string" },
        "paper_type": {
          "type": "string",
          "enum": ["dataset", "tool_package", "drylab_analysis", "out_of_scope"]
        },
        "github_repo_urls": { "type": "array", "items": { "type": "string" } },
        "datasets_catalog": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "source": { "type": "string" },
              "identifier": { "type": "string" },
              "description": { "type": "string" }
            },
            "required": ["source", "identifier"]
          }
        },
        "abstract_summary": { "type": "string" }
      }
    },
    "reproduce_decision": {
      "type": "object",
      "required": ["decision"],
      "properties": {
        "decision": { "type": "string", "enum": ["IES", "WDL", "WDL+IES", "REJECT"] },
        "reason": { "type": "string" },
        "confidence_score": { "type": "number" }
      }
    },
    "analytical_procedures": {
      "type": "object",
      "properties": {
        "global_inputs": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": { "type": "string" },
              "type": { "type": "string", "default": "File" },
              "source_url": { "type": "string" }
            }
          }
        },
        "wdl_workflow": {
          "type": "object",
          "properties": {
            "workflow_name": { "type": "string" },
            "tasks": {
              "type": "array",
              "items": {
                "type": "object",
                "required": ["step_id", "name", "command_template", "environment"],
                "properties": {
                  "step_id": { "type": "string" },
                  "name": { "type": "string" },
                  "command_template": { "type": "string" },
                  "environment": {
                    "type": "object",
                    "properties": {
                      "docker_image_name_suggestion": { "type": "string" },
                      "docker_image": { "type": "string" },
                      "base_system": {
                        "type": "object",
                        "properties": {
                          "os_family": { "type": "string" },
                          "python_version": { "type": "string" },
                          "cuda_version": { "type": "string" }
                        }
                      },
                      "system_dependencies": {
                        "type": "object",
                        "properties": {
                          "apt_packages": { "type": "array", "items": { "type": "string" } }
                        }
                      },
                      "python_environment": {
                        "type": "object",
                        "properties": {
                          "requirements_file_path": { "type": "string" },
                          "pip_packages": { "type": "array", "items": { "type": "string" } },
                          "conda_packages": { "type": "array", "items": { "type": "string" } },
                          "raw_install_commands": { "type": "array", "items": { "type": "string" } }
                        }
                      },
                      "r_environment": {
                        "type": "object",
                        "properties": {
                          "r_version": { "type": "string" },
                          "cran_packages": { "type": "array", "items": { "type": "string" } },
                          "bioc_packages": { "type": "array", "items": { "type": "string" } },
                          "raw_install_commands": { "type": "array", "items": { "type": "string" } }
                        }
                      },
                      "repository_context": {
                        "type": "object",
                        "properties": {
                          "git_url": { "type": "string" },
                          "branch": { "type": "string" },
                          "working_dir": { "type": "string" }
                        }
                      }
                    }
                  },
                  "resources_hint": {
                    "type": "object",
                    "properties": {
                      "min_cpu": { "type": "integer" },
                      "min_memory_gb": { "type": "integer" },
                      "gpu_required": { "type": "boolean" }
                    }
                  }
                }
              }
            },
            "wdl_script_path": { "type": "string" },
            "registered_workflow_name": { "type": "string" },
            "submission_id": { "type": "string" },
            "output_s3_urls": { "type": "array", "items": { "type": "string" } }
          }
        },
        "ies_application": {
          "type": "object",
          "properties": {
            "app_name": { "type": "string" },
            "environment": {
              "type": "object",
              "properties": {
                "docker_image_name_suggestion": { "type": "string" },
                "docker_image": { "type": "string" },
                "base_system": {
                  "type": "object",
                  "properties": {
                    "os_family": { "type": "string" },
                    "python_version": { "type": "string" },
                    "cuda_version": { "type": "string" }
                  }
                },
                "system_dependencies": {
                  "type": "object",
                  "properties": {
                    "apt_packages": { "type": "array", "items": { "type": "string" } }
                  }
                },
                "python_environment": {
                  "type": "object",
                  "properties": {
                    "requirements_file_path": { "type": "string" },
                    "pip_packages": { "type": "array", "items": { "type": "string" } },
                    "conda_packages": { "type": "array", "items": { "type": "string" } },
                    "raw_install_commands": { "type": "array", "items": { "type": "string" } }
                  }
                },
                "r_environment": {
                  "type": "object",
                  "properties": {
                    "r_version": { "type": "string" },
                    "cran_packages": { "type": "array", "items": { "type": "string" } },
                    "bioc_packages": { "type": "array", "items": { "type": "string" } },
                    "raw_install_commands": { "type": "array", "items": { "type": "string" } }
                  }
                },
                "repository_context": {
                  "type": "object",
                  "properties": {
                    "git_url": { "type": "string" },
                    "branch": { "type": "string" },
                    "working_dir": { "type": "string" }
                  }
                }
              }
            },
            "resources_hint": {
              "type": "object",
              "properties": {
                "min_cpu": { "type": "integer" },
                "min_memory_gb": { "type": "integer" },
                "gpu_required": { "type": "boolean" }
              }
            },
            "ies_app_id": { "type": "string" },
            "workspace_name": { "type": "string" }
          }
        }
      }
    }
  }
}
```

## Execution Workflow

### Stage 1: Paper analysis and decision
Goal: read the paper or repository, extract metadata, and decide whether reproduction is feasible.

1. Ingest the paper source or recognize a direct GitHub URL.
2. Generate a UUID for `project_id` and a timestamp in `YYYYMMDD_HHMMSS`.
3. Fill `paper_meta_info`.
   - If the user provides a direct GitHub URL, skip paper parsing, set `paper_type` to `tool_package`, record the repo URL, and move straight to Stage 2.
   - Otherwise identify `paper_type`, repo URLs, dataset accessions, and `abstract_summary`.
   - If only a `GSE` accession is available but raw data is needed, resolve SRR runs with:
     `python3 scripts/get_srr_from_gse.py <GSE_ID>`
   - Record both the original `GSE` and the resolved `SRR` values in `datasets_catalog`.
   - If no usable code repository can be found, the decision must be `REJECT`.
4. Make `reproduce_decision`.
   - dataset or tool package only -> `IES`
   - drylab secondary-analysis pipeline -> `WDL`
   - combined pipeline plus downstream interactive analysis -> `WDL+IES`
   - no code, no data, or out-of-scope paper -> `REJECT`
5. Initialize the card, set `status` to `stage_1_complete`, and report the decision.

### Stage 2: Resource acquisition and deep analysis
Goal: download assets and map the executable plan.

1. Download resources.
   - For repositories: `git clone` them locally.
   - For external datasets such as GEO or SRA: explicitly declare that `bioos_data_fetcher` is required.
2. Analyze the codebase.
   - Read `README.md`, dependency files, configs, and main scripts.
   - Identify environment requirements and split the analysis into secondary-analysis steps and tertiary-analysis steps.
3. Populate `analytical_procedures`.
   - For `IES`: fill `ies_application`
   - For `WDL`: fill `wdl_workflow` and define each task's `command_template`, environment, and resource hints
4. Update the card and set `status` to `stage_2_complete`.

### Stage 3: Development
Goal: build the executable artifacts.

1. Explicitly declare that `bioos_pipeline_developer` is required and follow it.
2. Development directives:
   - Clone the paper repository inside the generated Dockerfiles when the workflow depends on repo code at runtime.
   - Convert `wdl_workflow.tasks` into one generated WDL script and its task images.
   - Convert `ies_application` into one interactive image.
3. Persist outputs back to the card.
   - Save actual Docker image URLs into the task or IES environments.
   - Save the local WDL path into `wdl_workflow.wdl_script_path`.
4. Update the card and set `status` to `stage_3_complete`.

### Stage 4: Bio-OS deployment
Goal: launch the artifacts on Bio-OS.

1. Explicitly declare that `bioos_platform_operator` skill is required and follow it.
2. Import and submit the WDL workflow if present, and create the IES application if present.
3. Persist the resulting execution identifiers.
   - `wdl_workflow.registered_workflow_name`
   - `wdl_workflow.submission_id`
   - `wdl_workflow.output_s3_urls`
   - `ies_application.ies_app_id`
   - `ies_application.workspace_name`
4. Update the card and set `status` to `stage_4_complete`.

### Stage 5: Summarization and dashboard upload
Goal: publish the reproduction summary into the Bio-OS workspace.

1. Write a comprehensive markdown summary to `__dashboard__.md`.
2. Upload it with:
   `<bioos_launch> workspace dashboard-upload --workspace-name <workspace_name> --local-file-path __dashboard__.md --output json --pretty`
3. Set the card status to `finished`.
4. Present the final card and tell the user the Paper2Workspace run is complete.
