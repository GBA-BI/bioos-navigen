import glob
import json
import os
import re
import sys

def validate_prompts():
    """
    Validates markdown files in system_prompt/ by:
    1. Checking for valid JSON syntax in ```json blocks.
    2. Warning about TODO/FIXME placeholders.
    """
    source_dir = "system_prompt"
    files = sorted(glob.glob(os.path.join(source_dir, "*.md")))

    if not files:
        print(f"No markdown files found in {source_dir}/")
        return

    has_errors = False

    for filepath in files:
        filename = os.path.basename(filepath)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            lines = content.split('\n')

        # 1. Check for TODO/FIXME warnings
        for i, line in enumerate(lines):
            if "TODO" in line or "FIXME" in line:
                print(f"⚠️  [WARNING] {filename}:{i+1}: Found TODO/FIXME placeholder")

        # 2. Check for JSON syntax errors
        # Regex to find ```json content ```
        json_pattern = re.compile(r'```json\s*(.*?)\s*```', re.DOTALL)
        matches = list(json_pattern.finditer(content))

        for match in matches:
            json_str = match.group(1)

            # calculate line number of the start of the block
            start_index = match.start()
            line_number = content[:start_index].count('\n') + 1

            try:
                json.loads(json_str)
            except json.JSONDecodeError as e:
                print(f"❌ [ERROR] {filename}:{line_number}: Invalid JSON syntax")
                print(f"   Error: {e}")
                has_errors = True

    if has_errors:
        print("\nValidation failed with errors.")
        sys.exit(1)
    else:
        print("\nValidation passed successfully.")

if __name__ == "__main__":
    validate_prompts()
