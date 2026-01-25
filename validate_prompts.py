import glob
import os
import re
import json
import sys

SOURCE_DIR = "system_prompt"

def validate_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    errors = []
    warnings = []

    if "TODO" in content:
        warnings.append("Found TODO")
    if "FIXME" in content:
        warnings.append("Found FIXME")

    # Extract JSON blocks
    json_blocks = re.findall(r'```json\s*\n(.*?)\n\s*```', content, re.DOTALL)
    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"Invalid JSON in block {i+1}: {e}")

    if warnings:
        print(f"WARNING: {file_path} - {', '.join(warnings)}")

    if errors:
        print(f"ERROR: {file_path}")
        for e in errors:
            print(f"  - {e}")
        return False

    return True

def main():
    if not os.path.exists(SOURCE_DIR):
        print(f"Directory {SOURCE_DIR} not found.")
        sys.exit(1)

    files = sorted(glob.glob(os.path.join(SOURCE_DIR, "*.md")))
    failed = False
    for file_path in files:
        if not validate_file(file_path):
            failed = True

    if failed:
        sys.exit(1)
    print("All files validated successfully.")

if __name__ == "__main__":
    main()
