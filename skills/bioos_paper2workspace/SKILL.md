---
name: bioos_paper2workspace
description: Parse and orchestrate the reproduction of a computational biology paper on Bio-OS platform. Trigger this skill when the user provides a paper (PDF/DOI/URL) or asks to "reproduce a paper".
---

# Bio-OS Paper2Workspace

## 1. Operating Principle
This procedure details the end-to-end Standard Operating Procedure (SOP) for converting a scientific publication into an executable environment on the Bio-OS cloud.

## 2. The "Card" (Single Source of Truth)
You must manage a JSON file named `{Timestamp}_{UUID}_p2w_card.json` in the user's current directory. You must initialize it in Stage 1 and update the `status` and fields at the end of every Stage.

### Paper2Workspace_Context_v1 Schema (Mandatory)
You must strictly follow this JSON schema structure for the Card:

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
      "enum": ["initial", "stage_1_complete", "stage_2_complete", "stage_3_complete", "finished", "failed"]
    },
    "project_id": { "type": "string", "description": "The generated UUID" },
    
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
          "enum": ["dataset", "tool_package", "drylab_analysis", "out_of_scope"],
          "description": "dataset/tool_package -> IES; drylab_analysis -> WDL; others -> REJECT"
        },
        "github_repo_urls": { "type": "array", "items": { "type": "string" } },
        "datasets_catalog": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "source": { "type": "string", "description": "e.g., 'Direct URL', 'GEO', 'SRA', 'Zenodo'" },
              "identifier": { "type": "string", "description": "The URL or Accession ID (e.g., GSE12345)" },
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
      "description": "Filled in Stage 2. Describes the execution plan.",
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
          "description": "Secondary Analysis pipeline",
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
                  "command_template": { 
                      "type": "string", 
                      "description": "Shell command for this WDL task." 
                  },
                  "environment": {
                    "type": "object",
                    "properties": {
                      "docker_image_name_suggestion": { "type": "string" },
                      "docker_image": { "type": "string", "description": "Actual built image URL (Filled in Stage 3)" },
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
                        "properties": { "apt_packages": { "type": "array", "items": { "type": "string" } } }
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
            "wdl_script_path": { "type": "string", "description": "Local path to the generated WDL script (Filled in Stage 3)" },
            "registered_workflow_name": { "type": "string", "description": "Filled in Stage 4" },
            "submission_id": { "type": "string", "description": "Filled in Stage 4" },
            "output_s3_urls": { "type": "array", "items": { "type": "string" }, "description": "Filled in Stage 4" }
          }
        },
        "ies_application": {
          "type": "object",
          "description": "Tertiary Analysis interactive environment",
          "properties": {
            "app_name": { "type": "string" },
            "environment": {
              "type": "object",
              "properties": {
                "docker_image_name_suggestion": { "type": "string" },
                "docker_image": { "type": "string", "description": "Actual built image URL (Filled in Stage 3)" },
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
                  "properties": { "apt_packages": { "type": "array", "items": { "type": "string" } } }
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
            "ies_app_id": { "type": "string", "description": "Filled in Stage 4" },
            "workspace_name": { "type": "string", "description": "Filled in Stage 4" }
          }
        }
      }
    }
  }
}
```

## 3. Execution Workflow (The SOP)

You must follow these stages sequentially. Do not proceed to the next stage until the current one is complete and the Card is updated.

### 【Stage 1】Paper Analysis & Decision

**Goal:** Read the paper, extract metadata, and determine if it can be reproduced.

1. **Ingest**: Read the provided PDF/Text/Web OR recognize a direct GitHub URL.
2. **Generate UUID & Timestamp**: Generate a unique UUID (e.g., `550e8400-e29b...`) to serve as the `project_id`, and get the current time in `YYYYMMDD_HHMMSS` format to serve as the `Timestamp`. Initialization of the Card is required for ALL paths.
3. **Analyze `paper_meta_info`**:
   * **SHORTCUT**: If the user provided a **Direct GitHub URL**:
     * Skip paper analysis.
     * Fill `paper_type` = "tool_package" (default assumption).
     * Fill `github_repo_urls` with the provided GitHub URL.
     * Fill `abstract_summary` with "Direct GitHub Repo provided by user."
     * **JUMP** directly to Stage 2 (`Resource Acquisition`).
   * **Standard Path**:
     * Identify `paper_type`.
     * Extract `github_repo_urls`.
     * Extract `datasets_catalog`: Look for accession codes (GSE, GEO, SRA, SRP, PRJNA) or direct URLs.
       * **CRITICAL GEO TO SRA RESOLUTION**: Many papers (e.g., single-cell studies) only provide a GEO `GSE` number without specifying the raw sequencing `SRR` sample numbers in SRA. If only a GSE number is found and raw data is needed, you MUST execute `python scripts/get_srr_from_gse.py <GSE_ID>` to retrieve the associated SRR array (returned as JSON). Include both the GSE number and the resolved SRR numbers in the `datasets_catalog`.
     * **Repo Discovery Strategy**:
       * **IF** a GitHub URL is found: Use it.
       * **IF** a non-GitHub Project URL is found: Use `read_url_content` to scrape the page for a GitHub link.
       * **IF** still no GitHub URL: Use `search_web` with query `"{Tool Name} github repository"`.
       * **IF** no Git repo can be found: Decision MUST be **REJECT**.
     * Extract `abstract_summary`. **Mandatory**: If not explicitly found, you must fill this with "UNKNOWN" or a generated summary.
4. **Make `reproduce_decision`**:
   * *Bioinformatics Analysis Paradigms Context*:
     * **Secondary Analysis (WDL)**: Standardized, batch-processing pipelines (e.g., FASTQ to VCF, read mapping with BWA/STAR, variant calling). This maps to **WDL** on Bio-OS.
     * **Tertiary Analysis (IES)**: Interactive, personalized downstream analysis and visualization (e.g. custom R/Python scripting, Rmarkdown, Jupyter Notebooks). This maps to **IES** (Interactive Environment Settings) on Bio-OS.
   * **IF** the paper is purely a "dataset" OR "tool_package" (or only provides Tertiary analysis scripts) → Decision: **IES**.
   * **IF** the paper is purely a "drylab_analysis" focusing on Secondary batch processing → Decision: **WDL**.
   * **IF** the paper contains both Secondary pipelining followed by Tertiary custom analysis → Decision: **WDL+IES**.
   * **IF** `paper_type` is "wet_lab", "review", or has NO code/data → Decision: **REJECT**.
   * *Constraint*: If IES type but no repo/install instructions are found → **REJECT**.
   * *Note*: If the paper provides an existing Workflow file (WDL/CWL), treat it as a tool (**IES**).
5. **Output**:
   * Initialize `{Timestamp}_{UUID}_p2w_card.json` containing the schema above in the user's current directory.
   * Set `status` to `stage_1_complete`.
   * Report the decision to the user.

### 【Stage 2】Resource Acquisition & Deep Analysis

**Goal:** Download assets and map out the exact analytical steps.

1. **Download**:
   * **For GitHub repositories**: Execute local `git clone` commands to download the codebase directly into the current directory.
   * **For external datasets (GEO, SRA, Zenodo)**: Explicitly declare that the **`bioos_data_fetcher`** skill is required. This loads the data fetching instructions into context. Follow those instructions to download data *to the Bio-OS platform*.
2. **Analyze Codebase**:
   * Read `README.md`, `requirements.txt`, `.yaml`, and main scripts from the cloned repo.
   * Identify environment dependencies (Python/R versions, packages).
   * Classify the analytical logical steps into Secondary Analysis (WDL) and Tertiary Analysis (IES) based on the definitions in Stage 1.
3. **Populate `analytical_procedures` in Card**:
   * **For IES (Tertiary Analysis)**: Initialize the `ies_application` object. Fill `app_name` and provide `environment` details thoroughly based on the analysis. (No `command_template` is needed).
   * **For WDL (Secondary Analysis)**: Initialize the `wdl_workflow` object with `workflow_name` and `description`. For each distinct step, create an entry in the `tasks` array, defining the specific `command_template` (bash commands and variables) and its specific `environment`.
4. **Output**:
   * Update `{Timestamp}_{UUID}_p2w_card.json`.
   * Set `status` to `stage_2_complete`.

### 【Stage 3】Development (Build & Code)

**Goal:** Create the executable artifacts (Dockerfiles & WDL) using specialized skills.

1. **Generate Pipeline**: Explicitly declare that the **`bioos_pipeline_developer`** skill is required to process the environments and logical steps from the Card's `wdl_workflow` and `ies_application` objects into a single WDL file and its Docker containers. This loads the pipeline generation SOP into your context. Follow those instructions. 
   * **CRITICAL DEVELOPMENT DIRECTIVES**: 
     1. Ensure that the paper's GitHub repository is explicitly `git clone`d inside the generated Dockerfiles for all analysis environments.
     2. Process `wdl_workflow.tasks` to generate a unified WDL script and its required constituent task Docker images.
     3. Process `ies_application` strictly to build a single interactive container environment.
2. **Persist State**: Once pipeline generation outputs the final artifacts:
   * **WDL**: Update `wdl_workflow.tasks[].environment.docker_image` with the **actual built image URLs**. Save the local path to the combined script in `wdl_workflow.wdl_script_path`.
   * **IES**: Update `ies_application.environment.docker_image` with the **actual built image URL**.
3. **Output**: Update `{Timestamp}_{UUID}_p2w_card.json` and set status to `stage_3_complete`.

### 【Stage 4】Bio-OS Deployment

**Goal:** Launch the analysis on the cloud platform using operator skills.

1. **Execute Workflows**: Explicitly declare that the **`bioos_platform_operator`** skill is required. This loads the operator SOP into your context. Follow those instructions to import the completed WDL workflow (from `wdl_workflow.wdl_script_path`), and submit the analysis submission, and/or create the IES interactive application via the Bio-OS API and monitor the jobs.
2. **Persist State**: Wait for the execution tracking cycles to complete. Once execution yields successful results:
   * **WDL**: Update `wdl_workflow.registered_workflow_name`, `wdl_workflow.submission_id`, and `wdl_workflow.output_s3_urls` in the Card.
   * **IES**: Update `ies_application.ies_app_id` and `ies_application.workspace_name` in the Card.
3. **Output**: Set status to `stage_4_complete` in the Card.

### 【Stage 5】Summarization & Dashboard Upload

**Goal:** Summarize the entire reproduction process and publish it to the Bio-OS workspace.

1. **Draft Dashboard**: Create a comprehensive markdown summary of the entire Paper2Workspace journey, including the paper metadata, the analytical procedures, and the final execution outputs. Save it locally as `__dashboard__.md`.
2. **Upload Dashboard**: Use the `upload_dashboard_file` MCP tool to upload `__dashboard__.md` to the target Bio-OS workspace. This serves as the workspace description and the official record of the reproduction work.
3. **Conclude**: Inform the user that the Paper2Workspace reproduction process and execution are complete, and present the final JSON card.


