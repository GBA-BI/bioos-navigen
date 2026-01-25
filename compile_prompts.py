import glob
import os

OUTPUT_FILE = "GEMINI.md"
SOURCE_DIR = "system_prompt"

def main():
    if not os.path.exists(SOURCE_DIR):
        print(f"Directory {SOURCE_DIR} not found.")
        return

    files = sorted(glob.glob(os.path.join(SOURCE_DIR, "*.md")))
    with open(OUTPUT_FILE, "w", encoding="utf-8") as out:
        out.write("<!-- This file is auto-generated. Do not edit directly. -->\n")
        out.write("<!-- Update files in system_prompt/ and run compile_prompts.py -->\n\n")

        for file_path in files:
            filename = os.path.basename(file_path)
            out.write(f"<!-- Source: {filename} -->\n")
            with open(file_path, "r", encoding="utf-8") as f:
                out.write(f.read())
            out.write("\n\n")
    print(f"Compiled {len(files)} files into {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
