import os
import glob
import json
import re
import sys

def validate_json_in_file(filepath):
    """
    Extracts and validates JSON code blocks from a markdown file.
    Returns a list of errors found.
    """
    errors = []
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find JSON blocks
    # This regex matches ```json ... ``` content
    json_blocks = re.findall(r'```json\s+(.*?)```', content, re.DOTALL)

    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"Invalid JSON in block {i+1}: {e}")

    return errors

def check_placeholders(filepath):
    """
    Checks for TODO or FIXME placeholders.
    Returns a list of warnings.
    """
    warnings = []
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        if 'TODO' in line:
            warnings.append(f"Line {i+1}: Found 'TODO'")
        if 'FIXME' in line:
            warnings.append(f"Line {i+1}: Found 'FIXME'")

    return warnings

def main():
    prompt_dir = 'system_prompt'
    files = sorted(glob.glob(os.path.join(prompt_dir, '*.md')))

    if not files:
        print(f"No markdown files found in {prompt_dir}")
        return 0

    has_errors = False

    print(f"Validating {len(files)} files in '{prompt_dir}'...\n")

    for filepath in files:
        filename = os.path.basename(filepath)
        file_errors = validate_json_in_file(filepath)
        file_warnings = check_placeholders(filepath)

        if file_errors or file_warnings:
            print(f"Checking {filename}:")

            for err in file_errors:
                print(f"  [ERROR] {err}")
                has_errors = True

            for warn in file_warnings:
                print(f"  [WARNING] {warn}")

            print("")

    if has_errors:
        print("Validation failed with errors.")
        sys.exit(1)
    else:
        print("Validation successful! No errors found.")
        sys.exit(0)

if __name__ == "__main__":
    main()
