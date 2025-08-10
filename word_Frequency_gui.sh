#!/bin/bash

# Zenity GUI to select input file
input_file=$(zenity --file-selection --title="Select Input File" --file-filter="*.txt")
if [ -z "$input_file" ]; then
    zenity --error --text="No input file selected. Exiting."
    exit 1
fi

# Derive the output file name by appending "_wordfrequency" to the input file name
base_name=$(basename "$input_file" .txt)
output_file="${base_name}_wordfrequency.txt"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    zenity --error --text="Error: File '$input_file' not found!"
    exit 1
fi

# Process the input file to calculate word frequency
# Convert to lowercase, remove punctuation, split into words, sort, count unique occurrences, and format the output
tr '[:upper:]' '[:lower:]' < "$input_file" | \
tr -c '[:alnum:]' '[\n*]' | \
awk 'NF' | \
sort | \
uniq -c | \
sort -nr | \
awk '{printf "%-15s %d\n", $2, $1}' > "$output_file"

# Add a header to the output file
echo "Word Frequency" > temp_file.txt
cat "$output_file" >> temp_file.txt
mv temp_file.txt "$output_file"

# Notify the user of completion
zenity --info --text="Word frequency has been calculated and saved to '$output_file'."
