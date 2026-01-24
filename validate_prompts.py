import glob
import json
import sys
import re
import os

def validate_prompts():
    files = sorted(glob.glob("system_prompt/*.md"))
    has_error = False

    for filepath in files:
        print(f"Validating {filepath}...")
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
            has_error = True
            continue

        # Check for placeholders
        if "TODO" in content or "FIXME" in content:
            print(f"WARNING: 'TODO' or 'FIXME' found in {filepath}")

        # Extract JSON blocks
        # This regex looks for ```json followed by content and ending with ```
        # We use non-greedy matching for the content just in case, but usually code blocks are well delimited
        json_blocks = re.findall(r'```json(.*?)```', content, re.DOTALL)

        for i, block in enumerate(json_blocks):
            try:
                json.loads(block)
            except json.JSONDecodeError as e:
                print(f"ERROR: Invalid JSON in {filepath}, block {i+1}: {e}")
                # Print a snippet of the block for context
                snippet = block.strip()[:50].replace('\n', ' ')
                print(f"  Snippet: {snippet}...")
                has_error = True

    if has_error:
        sys.exit(1)
    else:
        print("All prompts validated successfully.")

if __name__ == "__main__":
    validate_prompts()
