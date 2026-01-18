import os
import glob
import sys

def compile_prompts():
    output_file = "GEMINI.md"
    source_dir = "system_prompt"

    # Check if directory exists
    if not os.path.isdir(source_dir):
        print(f"Error: Directory '{source_dir}' not found.")
        sys.exit(1)

    try:
        with open(output_file, "w", encoding="utf-8") as outfile:
            # Write Warning Header
            outfile.write("<!-- \n")
            outfile.write("WARNING: This file is auto-generated. Do not edit it directly.\n")
            outfile.write("Edit the source files in the 'system_prompt/' directory instead.\n")
            outfile.write("Run 'python3 compile_prompts.py' to update this file.\n")
            outfile.write("-->\n\n")

            # Get list of files
            files = sorted(glob.glob(os.path.join(source_dir, "*.md")))

            if not files:
                print(f"Warning: No markdown files found in {source_dir}")

            for filepath in files:
                filename = os.path.basename(filepath)
                try:
                    with open(filepath, "r", encoding="utf-8") as infile:
                        content = infile.read()

                    outfile.write(f"<!-- Source: {filename} -->\n")
                    outfile.write(content)
                    outfile.write("\n\n") # Add spacing between files
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
                    sys.exit(1)

        print(f"Successfully compiled {len(files)} files to {output_file}")
    except Exception as e:
        print(f"Error writing to {output_file}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    compile_prompts()
