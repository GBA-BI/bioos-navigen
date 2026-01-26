import os
import re
import json
import sys

SYSTEM_PROMPT_DIR = 'system_prompt'

def validate_json_blocks(content, filename):
    json_blocks = re.findall(r'```json\n(.*?)\n```', content, re.DOTALL)
    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            print(f"ERROR: Invalid JSON in {filename}, block {i+1}: {e}")
            return False
    return True

def check_placeholders(content, filename):
    for line_num, line in enumerate(content.splitlines(), 1):
        if 'TODO' in line or 'FIXME' in line:
            print(f"WARNING: Placeholder found in {filename}:{line_num}: {line.strip()}")

def main():
    if not os.path.isdir(SYSTEM_PROMPT_DIR):
        print(f"Error: Directory '{SYSTEM_PROMPT_DIR}' not found.")
        sys.exit(1)

    has_error = False
    for filename in sorted(os.listdir(SYSTEM_PROMPT_DIR)):
        if filename.endswith('.md'):
            filepath = os.path.join(SYSTEM_PROMPT_DIR, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            if not validate_json_blocks(content, filename):
                has_error = True

            check_placeholders(content, filename)

    if has_error:
        sys.exit(1)
    else:
        print("Validation passed.")

if __name__ == '__main__':
    main()
