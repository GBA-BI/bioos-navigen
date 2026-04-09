#!/usr/bin/env python3
import sys
import argparse
import csv
import os
import re

def extract_sample_id(outputs_list):
    """
    Attempts to generically extract a Sample ID from the output file paths.
    It takes the basename of the first output file and extracts the prefix
    before the first underscore or dot.
    """
    if not outputs_list or not outputs_list[0]:
        return "Unknown"
        
    first_output = outputs_list[0]
    basename = os.path.basename(first_output)
    
    # Match alphanumeric sequences containing dashes, up to the first underscore or dot 
    # Example: SRR11804718_1.fastq -> SRR11804718, GSE150728_RAW.tar -> GSE150728
    # sample-123_Aligned.bam -> sample-123
    match = re.match(r'^([A-Za-z0-9\-]+)', basename)
    if match:
        return match.group(1)
        
    return "Unknown"

def main():
    parser = argparse.ArgumentParser(description="Format single Bio-OS submission output to a CSV file.")
    parser.add_argument('-i', '--input', required=True, help="Input txt file from check_workflow_run_status")
    parser.add_argument('-o', '--output', required=True, help="Output CSV file path")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: Input file {args.input} not found.")
        sys.exit(1)

    with open(args.input, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    runs_data = []
    start_idx = -1
    
    # Locate the start of the table corresponding to successful runs
    for i, line in enumerate(lines):
        if "Succeeded" in line and not line.startswith("---") and not line.startswith("Run ID"):
            if start_idx == -1:
                start_idx = i
                break
                
    if start_idx == -1:
        print("No successful runs found in the input.")
        sys.exit(0)
        
    max_outputs = 0
    for line in lines[start_idx:]:
        if line.startswith("---") or not line.strip():
            continue
            
        parts = line.split(maxsplit=3)
        if len(parts) >= 4 and parts[1] == "Succeeded":
            run_id = parts[0]
            outputs_str = parts[3]
            
            # Clean up repetitive prefix if somehow it got carried over 
            if outputs_str.startswith("Succeeded"):
                outputs_str = outputs_str[9:].strip()
                
            outputs_list = [o.strip() for o in outputs_str.split(',') if o.strip()]
            sample_id = extract_sample_id(outputs_list)
            
            row = {
                "Run ID": run_id,
                "Sample ID": sample_id
            }
            
            for idx, out_path in enumerate(outputs_list):
                row[f"Output {idx+1}"] = out_path
                
            max_outputs = max(max_outputs, len(outputs_list))
            runs_data.append(row)
            
    if not runs_data:
        print("No parsable data found.")
        sys.exit(0)
        
    # Dynamically generate fieldnames based on max outputs found
    fieldnames = ["Run ID", "Sample ID"] + [f"Output {i}" for i in range(1, max_outputs + 1)]
    
    with open(args.output, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in runs_data:
            writer.writerow(row)
            
    print(f"Successfully extracted {len(runs_data)} runs. CSV formatted and saved to {args.output}")

if __name__ == "__main__":
    main()
