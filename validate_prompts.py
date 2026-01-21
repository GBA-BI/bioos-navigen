import os
import glob
import re
import json
import sys

def validate_file(filepath):
    print(f"Validating {filepath}...")
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    errors = []
    warnings = []

    # 1. Check for TODO/FIXME
    if "TODO" in content:
        warnings.append("Found 'TODO'")
    if "FIXME" in content:
        warnings.append("Found 'FIXME'")

    # 2. Extract and validate JSON blocks
    # Regex to find ```json ... ``` blocks
    # We use DOTALL to match across lines, and non-greedy *? for the content
    json_blocks = re.findall(r'```json\s*(.*?)```', content, re.DOTALL)

    for i, block in enumerate(json_blocks):
        try:
            data = json.loads(block)

            # 3. Specific check for $schema markdown link
            if isinstance(data, dict) and "$schema" in data:
                schema = data["$schema"]
                # Check if it looks like a markdown link [url](url)
                if re.match(r'\[.*\]\(.*\)', schema):
                    errors.append(f"JSON block {i+1}: '$schema' field contains a Markdown link. It must be a plain URL string.")

        except json.JSONDecodeError as e:
            errors.append(f"JSON block {i+1}: Invalid JSON syntax. {e}")

    return errors, warnings

def main():
    prompt_dir = "system_prompt"
    if not os.path.exists(prompt_dir):
        print(f"Error: Directory '{prompt_dir}' not found.")
        sys.exit(1)

    files = sorted(glob.glob(os.path.join(prompt_dir, "*.md")))
    if not files:
        print(f"No markdown files found in {prompt_dir}")
        sys.exit(0)

    has_errors = False

    for filepath in files:
        errors, warnings = validate_file(filepath)

        for w in warnings:
            print(f"  WARNING: {w}")

        for e in errors:
            print(f"  ERROR: {e}")
            has_errors = True

    if has_errors:
        print("\nValidation FAILED.")
        sys.exit(1)
    else:
        print("\nValidation PASSED.")
        sys.exit(0)

if __name__ == "__main__":
    main()
