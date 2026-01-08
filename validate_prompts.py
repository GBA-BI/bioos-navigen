#!/usr/bin/env python3
import os
import re
import sys

SYSTEM_PROMPT_DIR = 'system_prompt'
GEMINI_FILE = 'GEMINI.md'

REQUIRED_SECTIONS = [
    'Core Identity: Bio-OS Navigen',
    'Part 1: Core Principles and Standards',
    '1.1. Persona: The Tripartite Expert',
    '1.2. Core Operational Principles',
    '1.3. WDL Generation Standard',
    '1.4. Dockerfile Generation Standard',
    '1.5. Global Logging Standard',
    '1.6. Troubleshooting Guide',
    'Part 2: Modes of Operation',
    'Mode 1: General Mode',
    'Mode 2: Paper2Workspace',
    'Mode 3: Talk2Workspace',
    'Mode 4: Workspace2Paper'
]

def validate_gemini():
    if not os.path.exists(GEMINI_FILE):
        print(f"Error: {GEMINI_FILE} does not exist.")
        return False

    with open(GEMINI_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    missing_sections = []
    for section in REQUIRED_SECTIONS:
        if section not in content:
            missing_sections.append(section)

    if missing_sections:
        print("Validation Failed. Missing the following sections:")
        for s in missing_sections:
            print(f"- {s}")
        return False

    # Check for unresolved file references
    unresolved_refs = re.findall(r'`0[0-9]_.*?\.md`', content)
    if unresolved_refs:
        print("Validation Failed. Found unresolved file references:")
        for ref in unresolved_refs:
            print(f"- {ref}")
        return False

    print(f"Validation Passed: {GEMINI_FILE} contains all required sections and no unresolved file references.")
    return True

if __name__ == "__main__":
    if not validate_gemini():
        sys.exit(1)
