import os

SYSTEM_PROMPT_DIR = 'system_prompt'
OUTPUT_FILE = 'GEMINI.md'
HEADER = '<!-- This file is auto-generated. Do not edit directly. -->\n\n'

def main():
    if not os.path.isdir(SYSTEM_PROMPT_DIR):
        print(f"Error: Directory '{SYSTEM_PROMPT_DIR}' not found.")
        return

    compiled_content = HEADER

    for filename in sorted(os.listdir(SYSTEM_PROMPT_DIR)):
        if filename.endswith('.md'):
            filepath = os.path.join(SYSTEM_PROMPT_DIR, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            compiled_content += f"<!-- Source: {filename} -->\n"
            compiled_content += content + "\n\n"

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(compiled_content)

    print(f"Successfully compiled prompts to {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
