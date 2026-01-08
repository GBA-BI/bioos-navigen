#!/usr/bin/env python3
import os
import re

SYSTEM_PROMPT_DIR = 'system_prompt'
OUTPUT_FILE = 'GEMINI.md'

GEMINI_HEADER = """# Bio-OS Navigen - Unified System Prompt

## Overview
This file is a complete, self-contained system prompt for the Bio-OS Navigen agent.


## Core Identity: Bio-OS Navigen

You are **Bio-OS Navigen**, a specialized, pluggable AI agent designed to operate on the Bio-OS platform. Your purpose is to assist users in accomplishing complex bioinformatics tasks.

---

# Part 1: Core Principles and Standards

This section contains the non-negotiable principles and standards you must follow in all modes of operation.
"""

PART_2_HEADER = """
---

# Part 2: Modes of Operation

You operate in one of four distinct modes. Your **first and most important task** upon receiving a user request is to determine which mode is appropriate. Once a mode is selected, you must strictly follow the instructions for that mode for the remainder of the session.

## 2.1. Initial Analysis and Mode Selection

When the user provides their first prompt, follow these steps:
1.  Analyze the user's input for keywords and intent.
2.  Based on the triggers defined below, decide which of the four modes to activate.
3.  State clearly to the user which mode you are entering. For example: "It looks like you want to reproduce a paper. I am entering **Paper2Workspace Mode**."
4.  If you cannot determine the mode, ask clarifying questions. Example: "Are you looking to analyze new data, reproduce a paper, or discuss an existing workspace?"

## 2.2. The Four Modes
"""

def read_file(filename):
    path = os.path.join(SYSTEM_PROMPT_DIR, filename)
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def process_principles(content):
    # Adjust headers for "Persona" section to match GEMINI.md style
    # Original: # 1. Persona: Bio-OS Navigen
    # Target: ## 1.1. Persona: The Tripartite Expert
    content = content.replace('# 1. Persona: Bio-OS Navigen', '## 1.1. Persona: The Tripartite Expert')

    # Original: ## 1.1. Bioinformatics Scientist
    # Target: ### 1.1.1. Bioinformatics Scientist
    content = re.sub(r'## 1\.(\d)\.', r'### 1.1.\1.', content)

    # Adjust Core Operational Principles
    # Original: # 2. Core Operational Principles
    # Target: ## 1.2. Core Operational Principles
    content = content.replace('# 2. Core Operational Principles', '## 1.2. Core Operational Principles')

    # Original: ## 2.1. Path and Environment
    # Target: ### 1.2.1. Path and Environment
    content = re.sub(r'## 2\.(\d)\.', r'### 1.2.\1.', content)

    # Replace file references
    content = content.replace('file named `01_shared_dockerfile_standard.md`', 'unified Dockerfile Generation Standard')
    content = content.replace('file named `01_shared_wdl_standard.md`', 'WDL Generation Standard')
    content = content.replace('file named `01_shared_troubleshooting_guide.md`', 'global Troubleshooting Guide')
    content = content.replace('file named `01_shared_logging_standard.md`', 'Global Logging Standard')

    # Remove the initial header/intro of the file if needed
    content = re.sub(r'^# Bio-OS Navigen Persona and Core Principles\n\n.*?\n\n---\n\n', '', content, flags=re.DOTALL)

    return content

def process_wdl(content):
    # Target: ## 1.3. WDL Generation Standard
    content = re.sub(r'^# WDL Generation Standard', '## 1.3. WDL Generation Standard', content)

    # Adjust subsections
    # ## 1. Overall -> ### 1.3.1. Overall
    content = re.sub(r'## (\d)\.', r'### 1.3.\1.', content)

    # Adjust lower levels? In original WDL file: "### Input Section" -> GEMINI: "#### Input Section"
    content = re.sub(r'### ', '#### ', content)

    return content

def process_dockerfile(content):
    # Target: ## 1.4. Dockerfile Generation Standard
    content = re.sub(r'^# Dockerfile Generation Standard', '## 1.4. Dockerfile Generation Standard', content)

    # ## 1. -> ### 1.4.1.
    content = re.sub(r'## (\d)\.', r'### 1.4.\1.', content)

    # ### Type 1 -> #### Type 1
    content = re.sub(r'### ', '#### ', content)

    return content

def process_logging(content):
    # Target: ## 1.5. Global Logging Standard
    content = re.sub(r'^# Global Logging Standard', '## 1.5. Global Logging Standard', content)

    # ## 1. -> ### 1.5.1.
    content = re.sub(r'## (\d)\.', r'### 1.5.\1.', content)

    # ### Generic Example -> #### Generic Example
    content = re.sub(r'### ', '#### ', content)

    return content

def process_troubleshooting(content):
    # Target: ## 1.6. Troubleshooting Guide
    content = re.sub(r'^# Troubleshooting Guide', '## 1.6. Troubleshooting Guide', content)

    # ## Issue 1 -> ### Issue 1
    content = re.sub(r'## Issue', '### Issue', content)

    # ## Self-Checklist -> ### Self-Checklist
    content = re.sub(r'## Self-Checklist', '### Self-Checklist', content)

    # ### Dockerfile -> #### Dockerfile
    content = re.sub(r'### ', '#### ', content)

    return content

def process_mode_general(content):
    # # Mode 1: General Mode -> ### Mode 1: General Mode
    content = re.sub(r'^# Mode 1: General Mode', '### Mode 1: General Mode', content)

    # Replace file references
    content = content.replace('`01_shared_dockerfile_standard.md`', 'Dockerfile Generation Standard')
    content = content.replace('`01_shared_wdl_standard.md`', 'WDL Generation Standard')

    # Adjust headers
    # ## Workflow Development Process -> #### Workflow Development Process
    content = re.sub(r'^## ', '#### ', content, flags=re.MULTILINE)

    # ### 1. WDL Workflow Retrieval -> ##### 1. WDL Workflow Retrieval
    content = re.sub(r'^### ', '##### ', content, flags=re.MULTILINE)

    return content

def process_mode_p2w(content):
    # # Mode 2: Paper2Workspace -> ### Mode 2: Paper2Workspace
    content = re.sub(r'^# Mode 2: Paper2Workspace', '### Mode 2: Paper2Workspace', content)

    # Replace file references
    content = content.replace('`01_shared_dockerfile_standard.md`', '`Part 1.4: Dockerfile Generation Standard`')
    content = content.replace('`01_shared_wdl_standard.md`', '`Part 1.3: WDL Generation Standard`')

    # Adjust headers
    # ## Core Directives -> #### Core Directives
    content = re.sub(r'^## ', '#### ', content, flags=re.MULTILINE)

    # ### JSON Schema Definition -> #### JSON Schema Definition
    content = re.sub(r'^### ', '#### ', content, flags=re.MULTILINE)

    # #### [Stage 1] -> ##### [Stage 1]
    content = re.sub(r'^#### ', '##### ', content, flags=re.MULTILINE)

    return content

def process_mode_t2w(content):
    header_block = """### Mode 3: Talk2Workspace
- **Description**: Index and understand the contents of an existing Bio-OS workspace for Q&A and operations.
- **Triggers**: User asks questions about a specific workspace (e.g., "What's in my 'RNA-Seq' workspace?"), or explicitly says "talk to my workspace".
- **Instructions**: """

    # Remove the original title line
    content = re.sub(r'^# Talk2Workspace Mode Prompt\n\n', '', content)

    # Prepend the header block
    content = header_block + content

    # Replace references
    content = content.replace('`@system_prompt/shared/principles.md`', 'Part 1: Core Principles and Standards')
    content = content.replace('`@system_prompt/modes/general/prompt.md`', 'Mode 1: General Mode logic')

    # Adjust headers
    # ## Overall Flow -> #### Overall Flow
    content = re.sub(r'^## ', '#### ', content, flags=re.MULTILINE)

    # ### -> #####
    content = re.sub(r'^### ', '##### ', content, flags=re.MULTILINE)
    # ## -> ####
    content = re.sub(r'^## ', '#### ', content, flags=re.MULTILINE)

    return content

def process_mode_w2p(content):
    header_block = """### Mode 4: Workspace2Paper
- **Description**: Generate a draft of a scientific paper based on the results from a completed Bio-OS workspace.
- **Triggers**: User expresses a desire to write a paper based on their workspace results, or explicitly says "workspace2paper".
- **Instructions**: """

    content = re.sub(r'^# Workspace2Paper Mode Prompt\n\n', '', content)
    content = header_block + content

    content = content.replace('`@system_prompt/shared/principles.md`', 'Part 1: Core Principles and Standards')

    # ## -> ####
    # ### -> #####
    # #### -> ###### (if any)

    content = re.sub(r'^#### ', '###### ', content, flags=re.MULTILINE)
    content = re.sub(r'^### ', '##### ', content, flags=re.MULTILINE)
    content = re.sub(r'^## ', '#### ', content, flags=re.MULTILINE)

    return content


def main():
    print(f"Compiling prompts from {SYSTEM_PROMPT_DIR} into {OUTPUT_FILE}...")

    full_content = GEMINI_HEADER + "\n"

    # Part 1: Shared Principles and Standards

    # 1. Principles
    principles = read_file('01_shared_principles.md')
    full_content += process_principles(principles) + "\n\n---\n\n"

    # 2. WDL Standard
    wdl = read_file('01_shared_wdl_standard.md')
    full_content += process_wdl(wdl) + "\n\n---\n\n"

    # 3. Dockerfile Standard
    docker = read_file('01_shared_dockerfile_standard.md')
    full_content += process_dockerfile(docker) + "\n\n---\n\n"

    # 4. Logging Standard
    logging = read_file('01_shared_logging_standard.md')
    full_content += process_logging(logging) + "\n\n---\n\n"

    # 5. Troubleshooting
    trouble = read_file('01_shared_troubleshooting_guide.md')
    full_content += process_troubleshooting(trouble) + "\n\n"

    # Part 2: Modes
    full_content += PART_2_HEADER

    # Mode 1
    m1 = read_file('02_mode_general.md')
    full_content += process_mode_general(m1) + "\n\n"

    # Mode 2
    m2 = read_file('02_mode_paper2workspace.md')
    full_content += process_mode_p2w(m2) + "\n\n"

    # Mode 3
    m3 = read_file('02_mode_talk2workspace.md')
    full_content += process_mode_t2w(m3) + "\n\n"

    # Mode 4
    m4 = read_file('02_mode_workspace2paper.md')
    full_content += process_mode_w2p(m4) + "\n"

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(full_content)

    print(f"Successfully generated {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
