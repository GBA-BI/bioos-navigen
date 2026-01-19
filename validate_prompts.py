import os
import sys
import json
import re

def validate_markdown_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    errors = []

    # Check for TODOs
    if 'TODO' in content or 'FIXME' in content:
        print(f"WARNING: 'TODO' or 'FIXME' found in {filepath}")

    # Extract JSON blocks
    # Pattern: ```json\n(content)\n```
    json_blocks = re.findall(r'```json\n(.*?)\n```', content, re.DOTALL)

    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"Invalid JSON in block {i+1}: {str(e)}")

    return errors

def main():
    system_prompt_dir = 'system_prompt'
    if not os.path.exists(system_prompt_dir):
        print(f"Directory {system_prompt_dir} not found.")
        sys.exit(1)

    all_errors = {}

    for filename in sorted(os.listdir(system_prompt_dir)):
        if filename.endswith('.md'):
            filepath = os.path.join(system_prompt_dir, filename)
            errors = validate_markdown_file(filepath)
            if errors:
                all_errors[filename] = errors

    if all_errors:
        print("Validation failed with the following errors:")
        for filename, errs in all_errors.items():
            print(f"\nFile: {filename}")
            for err in errs:
                print(f"  - {err}")
        sys.exit(1)
    else:
        print("All system prompts validated successfully.")

if __name__ == "__main__":
    main()
