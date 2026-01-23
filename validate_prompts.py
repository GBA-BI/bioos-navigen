import os
import glob
import json
import re
import sys

def validate_json_in_markdown(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all JSON blocks: ```json ... ```
    # Using non-greedy match for content
    json_blocks = re.findall(r'```json\s*(.*?)```', content, re.DOTALL)

    errors = []
    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"JSON error in block {i+1}: {str(e)}")

    return errors

def check_placeholders(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    warnings = []
    for i, line in enumerate(lines):
        if 'TODO' in line or 'FIXME' in line:
            warnings.append(f"Line {i+1}: Found TODO/FIXME")
    return warnings

def main():
    prompt_dir = 'system_prompt'
    files = glob.glob(os.path.join(prompt_dir, '*.md'))

    has_error = False

    print(f"Validating {len(files)} files in {prompt_dir}...")

    for filepath in files:
        # 1. Validate JSON
        json_errors = validate_json_in_markdown(filepath)
        if json_errors:
            has_error = True
            print(f"\n❌ Error in {filepath}:")
            for err in json_errors:
                print(f"  - {err}")

        # 2. Check Placeholders (Warning only)
        warnings = check_placeholders(filepath)
        if warnings:
            print(f"\n⚠️  Warning in {filepath}:")
            for warn in warnings:
                print(f"  - {warn}")

    if has_error:
        print("\nValidation failed due to JSON errors.")
        sys.exit(1)
    else:
        print("\nValidation passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
