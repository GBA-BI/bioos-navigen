import os
import re
import json
import sys

SYSTEM_PROMPT_DIR = "system_prompt"

def validate_file(filepath):
    print(f"Validating {filepath}...")
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error: Could not read file {filepath}: {e}")
        return False

    if not content.strip():
        print(f"Error: File {filepath} is empty.")
        return False

    # Check for unclosed code blocks
    code_block_count = content.count("```")
    if code_block_count % 2 != 0:
        print(f"Error: File {filepath} has unclosed code blocks (count: {code_block_count}).")
        return False

    # Check for JSON syntax in json blocks
    # Regex to find ```json ... ``` blocks
    # Using non-greedy match .*?
    json_blocks = re.findall(r'```json\s*(.*?)\s*```', content, re.DOTALL)

    file_valid = True
    for i, block in enumerate(json_blocks):
        # Skip if block is empty or just comments (basic check)
        if not block.strip():
            continue

        try:
            data = json.loads(block)
            # Check for $schema format
            if "$schema" in data:
                schema_val = data["$schema"]
                # Check if it looks like a markdown link [text](url)
                if re.match(r'\[.*\]\(.*\)', schema_val):
                     print(f"Error: File {filepath} JSON block {i+1} has Markdown-formatted $schema. Use plain URL.")
                     file_valid = False
        except json.JSONDecodeError as e:
            # Sometimes json blocks in markdown are just examples and not strict JSON.
            # But the requirement says "JSON syntax errors within json blocks".
            # I'll treat it as an error.
            print(f"Error: File {filepath} has invalid JSON in block {i+1}: {e}")
            file_valid = False

    return file_valid

def main():
    if not os.path.exists(SYSTEM_PROMPT_DIR):
        print(f"Error: Directory {SYSTEM_PROMPT_DIR} not found.")
        sys.exit(1)

    all_valid = True
    for filename in sorted(os.listdir(SYSTEM_PROMPT_DIR)):
        if filename.endswith(".md"):
            filepath = os.path.join(SYSTEM_PROMPT_DIR, filename)
            if not validate_file(filepath):
                all_valid = False

    if not all_valid:
        print("Validation failed.")
        sys.exit(1)

    print("All system prompts validated successfully.")

if __name__ == "__main__":
    main()
