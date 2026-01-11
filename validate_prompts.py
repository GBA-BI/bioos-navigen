import os
import glob
import json
import re

def validate_markdown_file(filepath):
    """
    Validates a single markdown file for:
    1. Not empty.
    2. Closed code blocks.
    3. Valid JSON syntax in json code blocks.
    """
    issues = []

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except Exception as e:
        return [f"Could not read file: {e}"]

    # 1. Check if empty
    if not content.strip():
        return ["File is empty"]

    # 2. Check for unclosed code blocks
    # Count occurrences of triple backticks
    # This is a naive check; it assumes backticks are always used for code blocks
    backtick_count = content.count("```")
    if backtick_count % 2 != 0:
        issues.append("Unclosed code block (odd number of triple backticks)")

    # 3. Check JSON blocks
    # Regex to find ```json ... ``` blocks
    # DOTALL makes . match newlines
    json_blocks = re.finditer(r"```json\s*(.*?)```", content, re.DOTALL)

    for i, match in enumerate(json_blocks):
        json_content = match.group(1).strip()
        try:
            json.loads(json_content)
        except json.JSONDecodeError as e:
            # Get line number approximation
            line_offset = content[:match.start()].count('\n') + 1
            issues.append(f"Invalid JSON in block {i+1} (approx line {line_offset}): {e}")

    return issues

def validate_prompts():
    source_dir = "system_prompt"
    files = sorted(glob.glob(os.path.join(source_dir, "*.md")))

    has_errors = False

    print(f"Validating {len(files)} files in {source_dir}/...")

    for filepath in files:
        issues = validate_markdown_file(filepath)
        if issues:
            has_errors = True
            print(f"\n❌ {filepath}:")
            for issue in issues:
                print(f"  - {issue}")
        else:
            # Optional: print success for each file or just stay silent
            pass

    if has_errors:
        print("\nValidation FAILED.")
        exit(1)
    else:
        print("\nValidation PASSED.")
        exit(0)

if __name__ == "__main__":
    validate_prompts()
