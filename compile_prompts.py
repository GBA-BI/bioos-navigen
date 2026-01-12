import os

SYSTEM_PROMPT_DIR = "system_prompt"
OUTPUT_FILE = "GEMINI.md"

def compile_prompts():
    if not os.path.exists(SYSTEM_PROMPT_DIR):
        print(f"Error: Directory {SYSTEM_PROMPT_DIR} not found.")
        return

    filenames = sorted([f for f in os.listdir(SYSTEM_PROMPT_DIR) if f.endswith(".md")])

    full_content = ""
    for filename in filenames:
        filepath = os.path.join(SYSTEM_PROMPT_DIR, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read().strip()
            # Add a newline at the end if not present to separate from next file
            full_content += content + "\n\n"

    # Remove the trailing newlines
    full_content = full_content.strip() + "\n"

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(full_content)

    print(f"Successfully compiled {len(filenames)} files into {OUTPUT_FILE}.")

if __name__ == "__main__":
    compile_prompts()
