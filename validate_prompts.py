import os
import re
import json
import sys

def validate_prompts():
    source_dir = "system_prompt"
    files = [f for f in os.listdir(source_dir) if f.endswith(".md")]
    has_errors = False

    for filename in files:
        filepath = os.path.join(source_dir, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        # Check for placeholders
        if "TODO" in content or "FIXME" in content:
            print(f"WARNING: {filename} contains TODO or FIXME placeholders.")
            # We treat this as a warning, not necessarily an error that breaks the build,
            # but for strict validation we could set has_errors = True.
            # Let's keep it as warning for now unless requested otherwise.

        # Check for JSON blocks
        json_blocks = re.findall(r'```json\n(.*?)\n```', content, re.DOTALL)
        for i, block in enumerate(json_blocks):
            try:
                json.loads(block)
            except json.JSONDecodeError as e:
                print(f"ERROR: {filename} contains invalid JSON in block {i+1}: {e}")
                has_errors = True

    if has_errors:
        sys.exit(1)
    else:
        print("All prompts validated successfully.")

if __name__ == "__main__":
    validate_prompts()
