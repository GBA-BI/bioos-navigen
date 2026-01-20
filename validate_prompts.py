import os
import re
import json
import sys

def validate_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    errors = []
    warnings = []

    # Check for TODO/FIXME
    if 'TODO' in content:
        warnings.append(f"Warning: 'TODO' found in {filepath}")
    if 'FIXME' in content:
        warnings.append(f"Warning: 'FIXME' found in {filepath}")

    # Check JSON blocks
    # Regex to find ```json ... ``` blocks
    json_blocks = re.findall(r'```json\s*(.*?)\s*```', content, re.DOTALL)

    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"Error: Invalid JSON in {filepath} (Block {i+1}): {e}")

    return errors, warnings

def main():
    prompt_dir = 'system_prompt'
    if not os.path.exists(prompt_dir):
        print(f"Error: Directory '{prompt_dir}' not found.")
        sys.exit(1)

    all_errors = []

    for root, dirs, files in os.walk(prompt_dir):
        for file in files:
            if file.endswith('.md'):
                filepath = os.path.join(root, file)
                errors, warnings = validate_file(filepath)

                for w in warnings:
                    print(w)

                if errors:
                    all_errors.extend(errors)

    if all_errors:
        print("\nValidation Failed:")
        for e in all_errors:
            print(e)
        sys.exit(1)
    else:
        print("Validation Passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
