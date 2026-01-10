import os
import re
import json

SYSTEM_PROMPT_DIR = "system_prompt"

def validate_markdown(content, filename):
    errors = []

    # Check for empty content
    if not content.strip():
        errors.append("File is empty.")

    # Check for unclosed code blocks
    code_block_count = content.count("```")
    if code_block_count % 2 != 0:
        errors.append(f"Unclosed code block detected (found {code_block_count} markers).")

    # Check for JSON blocks and validate them
    # Regex to find ```json ... ``` blocks
    json_blocks = re.findall(r'```json\s+(.*?)\s+```', content, re.DOTALL)
    for i, block in enumerate(json_blocks):
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"Invalid JSON in block {i+1}: {e}")

    return errors

def validate_prompts():
    if not os.path.exists(SYSTEM_PROMPT_DIR):
        print(f"Error: Directory '{SYSTEM_PROMPT_DIR}' not found.")
        return False

    files = [f for f in os.listdir(SYSTEM_PROMPT_DIR) if f.endswith(".md")]
    all_passed = True

    print(f"Validating {len(files)} files in '{SYSTEM_PROMPT_DIR}'...\n")

    for filename in files:
        filepath = os.path.join(SYSTEM_PROMPT_DIR, filename)
        with open(filepath, "r", encoding="utf-8") as infile:
            content = infile.read()

        errors = validate_markdown(content, filename)

        if errors:
            all_passed = False
            print(f"❌ {filename}: FAILED")
            for err in errors:
                print(f"   - {err}")
        else:
            print(f"✅ {filename}: PASSED")

    if all_passed:
        print("\n✨ All prompt files passed validation.")
        return True
    else:
        print("\n⚠️ Some files failed validation.")
        return False

if __name__ == "__main__":
    success = validate_prompts()
    if not success:
        exit(1)
