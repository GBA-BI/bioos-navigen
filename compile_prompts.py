import os
import glob

def main():
    prompt_dir = 'system_prompt'
    output_file = 'GEMINI.md'

    files = sorted(glob.glob(os.path.join(prompt_dir, '*.md')))

    if not files:
        print(f"No markdown files found in {prompt_dir}")
        return

    print(f"Compiling {len(files)} files from '{prompt_dir}' into '{output_file}'...")

    with open(output_file, 'w', encoding='utf-8') as outfile:
        # Add a header to GEMINI.md explaining it's auto-generated
        outfile.write("<!-- This file is auto-generated. Do not edit directly. -->\n")
        outfile.write("<!-- Modify files in system_prompt/ and run compile_prompts.py instead. -->\n\n")

        for filepath in files:
            filename = os.path.basename(filepath)
            print(f"  Adding {filename}...")

            outfile.write(f"<!-- Source: {filename} -->\n")

            with open(filepath, 'r', encoding='utf-8') as infile:
                content = infile.read()
                outfile.write(content)

            # Ensure proper separation between files
            outfile.write("\n\n")

    print(f"Successfully generated {output_file}")

if __name__ == "__main__":
    main()
