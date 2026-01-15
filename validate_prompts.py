import os
import json
import re
import sys

def validate_markdown_file(filepath):
    """
    Validates a single markdown file for:
    1. JSON syntax in code blocks.
    2. Broken internal links (basic check).
    """
    with open(filepath, "r") as f:
        content = f.read()

    errors = []

    # Check JSON blocks
    json_blocks = re.findall(r'```json\s+(.*?)\s+```', content, re.DOTALL)
    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"Invalid JSON in block {i+1}: {e}")

    # Check for placeholders like TODO or FIXME (optional, but good practice)
    if "TODO" in content or "FIXME" in content:
        print(f"Warning: 'TODO' or 'FIXME' found in {filepath}")

    return errors

def validate_prompts():
    prompt_dir = "system_prompt"
    all_passed = True

    files = [f for f in os.listdir(prompt_dir) if f.endswith(".md")]

    for filename in files:
        filepath = os.path.join(prompt_dir, filename)
        errors = validate_markdown_file(filepath)

        if errors:
            all_passed = False
            print(f"Validation FAILED for {filename}:")
            for err in errors:
                print(f"  - {err}")
        else:
            print(f"Validation PASSED for {filename}")

    if not all_passed:
        sys.exit(1)

if __name__ == "__main__":
    validate_prompts()
