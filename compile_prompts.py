import os

def compile_prompts():
    prompt_dir = "system_prompt"
    output_file = "GEMINI.md"

    # Get all markdown files in the directory
    files = [f for f in os.listdir(prompt_dir) if f.endswith(".md")]
    files.sort()  # Sort alphabetically

    with open(output_file, "w") as outfile:
        # Write the header
        outfile.write("# Bio-OS Navigen - Unified System Prompt\n\n")
        outfile.write("## Overview\n")
        outfile.write("This file is a complete, self-contained system prompt for the Bio-OS Navigen agent.\n\n")

        for filename in files:
            filepath = os.path.join(prompt_dir, filename)
            with open(filepath, "r") as infile:
                content = infile.read()
                # Optional: Add a comment indicating source file
                outfile.write(f"<!-- Source: {filename} -->\n\n")
                outfile.write(content)
                outfile.write("\n\n---\n\n")

    print(f"Successfully compiled {len(files)} files into {output_file}")

if __name__ == "__main__":
    compile_prompts()
