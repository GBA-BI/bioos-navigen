import os

SYSTEM_PROMPT_DIR = "system_prompt"
OUTPUT_FILE = "GEMINI.md"

def compile_prompts():
    """
    Concatenates all markdown files in the system_prompt directory into a single GEMINI.md file.
    Files are processed in alphabetical order.
    """
    if not os.path.exists(SYSTEM_PROMPT_DIR):
        print(f"Error: Directory '{SYSTEM_PROMPT_DIR}' not found.")
        return

    # Get list of .md files and sort them to ensure correct order (00_, 01_, 02_, etc.)
    files = [f for f in os.listdir(SYSTEM_PROMPT_DIR) if f.endswith(".md")]
    files.sort()

    try:
        with open(OUTPUT_FILE, "w", encoding="utf-8") as outfile:
            # Add Warning Header
            outfile.write("<!--\n")
            outfile.write("⚠️ WARNING: THIS FILE IS AUTO-GENERATED. DO NOT EDIT DIRECTLY.\n")
            outfile.write(f"   Source files are located in '{SYSTEM_PROMPT_DIR}/'.\n")
            outfile.write("   Run 'python3 compile_prompts.py' to update this file.\n")
            outfile.write("-->\n\n")

            for filename in files:
                filepath = os.path.join(SYSTEM_PROMPT_DIR, filename)
                print(f"Processing {filename}...")
                with open(filepath, "r", encoding="utf-8") as infile:
                    content = infile.read().strip()
                    outfile.write(content)
                    outfile.write("\n\n") # Ensure separation between modules

        print(f"✅ Successfully compiled {len(files)} files into {OUTPUT_FILE}")
    except Exception as e:
        print(f"❌ Error compiling prompts: {e}")

if __name__ == "__main__":
    compile_prompts()
