import glob
import os

SYSTEM_PROMPT_DIR = "system_prompt"
OUTPUT_FILE = "GEMINI.md"

def generate_content(verbose=False):
    """
    Generates the full content string from the modular markdown files.
    """
    if not os.path.isdir(SYSTEM_PROMPT_DIR):
        if verbose:
            print(f"Error: Directory '{SYSTEM_PROMPT_DIR}' not found.")
        return None

    files = sorted(glob.glob(os.path.join(SYSTEM_PROMPT_DIR, "*.md")))

    if not files:
        if verbose:
            print(f"No markdown files found in {SYSTEM_PROMPT_DIR}")
        return None

    full_content = []

    # Add an auto-generated warning
    warning = "<!-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY. -->\n"
    warning += "<!-- Modify files in system_prompt/ and run python3 compile_prompts.py -->\n\n"
    full_content.append(warning)

    if verbose:
        print(f"Found {len(files)} files to compile:")

    for f in files:
        if verbose:
            print(f" - {os.path.basename(f)}")
        with open(f, 'r', encoding='utf-8') as infile:
            content = infile.read().strip()
            full_content.append(content)

    # Join with double newlines to ensure clean separation between sections
    result = "\n\n".join(full_content)

    # Ensure the file ends with a newline
    if not result.endswith('\n'):
        result += '\n'

    return result

def compile_prompts():
    """
    Writes the generated content to GEMINI.md
    """
    content = generate_content(verbose=True)
    if content:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as outfile:
            outfile.write(content)
        print(f"\nSuccessfully compiled into {OUTPUT_FILE}")

if __name__ == "__main__":
    compile_prompts()
