import os
import glob

def main():
    prompt_dir = 'system_prompt'
    output_file = 'GEMINI.md'

    # Get all markdown files and sort them alphabetically
    files = sorted(glob.glob(os.path.join(prompt_dir, '*.md')))

    print(f"Compiling {len(files)} files from {prompt_dir} to {output_file}...")

    compiled_content = []

    # Add Auto-generation Header
    header = (
        "<!--\n"
        "WARNING: THIS FILE IS AUTO-GENERATED. DO NOT EDIT.\n"
        f"Source: {prompt_dir}/*.md\n"
        "-->\n\n"
    )
    compiled_content.append(header)

    for filepath in files:
        filename = os.path.basename(filepath)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Add Source Marker
        compiled_content.append(f"<!-- Source: {filename} -->\n")
        compiled_content.append(content)
        # Ensure newline between files
        if not content.endswith('\n'):
            compiled_content.append('\n')
        compiled_content.append('\n')

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("".join(compiled_content))

    print(f"Successfully generated {output_file}")

if __name__ == "__main__":
    main()
