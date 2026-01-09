import os
import sys
from compile_prompts import generate_content, OUTPUT_FILE, SYSTEM_PROMPT_DIR

def validate_prompts():
    """
    Checks if GEMINI.md matches the compiled content from system_prompt/.
    Uses generate_content from compile_prompts.py to ensure logic is identical.
    """
    print("Validating system prompts...")

    if not os.path.exists(OUTPUT_FILE):
        print(f"Error: {OUTPUT_FILE} does not exist. Run compile_prompts.py first.")
        sys.exit(1)

    compiled_content = generate_content(verbose=False)
    if compiled_content is None:
        sys.exit(1)

    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        existing_content = f.read()

    # Normalize line endings just in case
    compiled_content = compiled_content.replace('\r\n', '\n')
    existing_content = existing_content.replace('\r\n', '\n')

    if compiled_content == existing_content:
        print(f"Validation Successful: {OUTPUT_FILE} is up to date.")
        sys.exit(0)
    else:
        print(f"Validation Failed: {OUTPUT_FILE} is out of sync with {SYSTEM_PROMPT_DIR}/.")
        print("Please run 'python3 compile_prompts.py' to update it.")
        sys.exit(1)

if __name__ == "__main__":
    validate_prompts()
