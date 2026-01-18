import os
import glob
import json
import re
import sys

def validate_json_blocks(content, filename):
    """Finds ```json blocks and validates them."""
    # Matches ```json ... ``` blocks. Use re.DOTALL to match across newlines.
    pattern = r"```json\s+(.*?)\s+```"
    matches = re.finditer(pattern, content, re.DOTALL)
    errors = []

    for i, match in enumerate(matches):
        json_str = match.group(1)
        # Remove comments if any (standard JSON doesn't support them, but prompts might have them)
        # For strict validation, we keep it as is.
        try:
            json.loads(json_str)
        except json.JSONDecodeError as e:
            # Get line number context if possible (approximate)
            start_pos = match.start()
            line_num = content[:start_pos].count('\n') + 1
            errors.append(f"Invalid JSON in {filename} (Block starting at line {line_num}): {e}")

    return errors

def validate_placeholders(content, filename):
    """Checks for TODO or FIXME."""
    errors = []
    lines = content.split('\n')
    for i, line in enumerate(lines):
        # Ignore case for these keywords? Usually capitalized in code.
        if 'TODO' in line or 'FIXME' in line:
            # Check if it's inside the warning header of this script itself or similar context
            # But here we are validating MD files.
            errors.append(f"Placeholder found in {filename}:{i+1}: {line.strip()}")
    return errors

def main():
    source_dir = "system_prompt"
    if not os.path.isdir(source_dir):
        print(f"Error: Directory '{source_dir}' not found.")
        sys.exit(1)

    files = sorted(glob.glob(os.path.join(source_dir, "*.md")))
    all_errors = []

    for filepath in files:
        filename = os.path.basename(filepath)
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()

            all_errors.extend(validate_json_blocks(content, filename))
            all_errors.extend(validate_placeholders(content, filename))
        except Exception as e:
            all_errors.append(f"Could not read {filename}: {e}")

    if all_errors:
        print("Validation Failed:")
        for err in all_errors:
            print(f"  - {err}")
        sys.exit(1)
    else:
        print("Validation Passed.")

if __name__ == "__main__":
    main()
