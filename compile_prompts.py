import glob
import os

def compile_prompts():
    """
    Concatenates all markdown files in the system_prompt/ directory
    into a single GEMINI.md file.
    """
    source_dir = "system_prompt"
    output_file = "GEMINI.md"

    # Get all .md files in the source directory, sorted alphabetically
    files = sorted(glob.glob(os.path.join(source_dir, "*.md")))

    if not files:
        print(f"No markdown files found in {source_dir}/")
        return

    print(f"Compiling {len(files)} files from {source_dir}/ into {output_file}...")

    with open(output_file, "w", encoding="utf-8") as outfile:
        # Add a warning header
        outfile.write("<!--\n")
        outfile.write("⚠️ WARNING: THIS FILE IS AUTO-GENERATED. DO NOT EDIT DIRECTLY.\n")
        outfile.write(f"To update this file, modify the files in the '{source_dir}/' directory\n")
        outfile.write("and run 'python3 compile_prompts.py'.\n")
        outfile.write("-->\n\n")

        for filepath in files:
            filename = os.path.basename(filepath)

            # Read the content of each file
            with open(filepath, "r", encoding="utf-8") as infile:
                content = infile.read()

            # Write a marker indicating the source file
            outfile.write(f"<!-- Source: {filename} -->\n")
            outfile.write(content.rstrip())
            outfile.write("\n\n")

    print("Compilation complete.")

if __name__ == "__main__":
    compile_prompts()
