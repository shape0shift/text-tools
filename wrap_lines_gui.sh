#!/bin/bash

# Zenity GUI to select input file
input_file=$(zenity --file-selection --title="Select Input File")
if [ -z "$input_file" ]; then
    zenity --error --text="No input file selected. Exiting."
    exit 1
fi

# Derive the output file name by appending "_wrapped" to the input file name
base_name=$(basename "$input_file" .txt)
output_file="${base_name}_wrapped.txt"

# Remove line breaks, concatenate words, and preserve headlines and paragraphs
awk '{
    if (toupper($0) == $0 && length($0) > 0) {
        if (NR > 1) {
            print "";  # Print a newline before the headline
        }
        print $0;  # Output the headline
    } else if (length($0) > 0) {
        if (substr($0, length($0), 1) == "-") {
            printf "%s", substr($0, 1, length($0) - 1);  # Remove dash
        } else {
            if (NR > 1) {
                printf " ";  # Add space between lines
            }
            printf "%s", $0;  # Output line content
        }
    } else {
        print "";  # Print a newline for empty lines to preserve paragraphs
    }
}' "$input_file" > "$output_file"

# Remove last space and save file
sed -i 's/ $//' "$output_file"

zenity --info --text="The line breaks have been removed and saved to $output_file."
