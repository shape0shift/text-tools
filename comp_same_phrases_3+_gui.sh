#!/bin/bash

# Function to display an error message
show_error() {
    zenity --error --text="$1"
}

# Function to find common phrases of a given length
find_common_phrases() {
    local n="$1"
    local file1="$2"
    local file2="$3"
    local output="$4"

    echo "Common phrases ($n words):" >> "$output"
    comm -12 <(awk -v n="$n" '{
        for (i=1; i<=NF-n+1; i++) {
            phrase = ""
            for (j=0; j<n; j++) {
                phrase = phrase (j == 0 ? "" : " ") $(i+j)
            }
            print tolower(phrase)
        }
    }' "$file1" | sort -u) \
          <(awk -v n="$n" '{
        for (i=1; i<=NF-n+1; i++) {
            phrase = ""
            for (j=0; j<n; j++) {
                phrase = phrase (j == 0 ? "" : " ") $(i+j)
            }
            print tolower(phrase)
        }
    }' "$file2" | sort -u) >> "$output"
}

# Get input files from the user
file1=$(zenity --file-selection --title="Select First Input File")
if [ -z "$file1" ]; then
    show_error "No file selected. Exiting."
    exit 1
fi

file2=$(zenity --file-selection --title="Select Second Input File")
if [ -z "$file2" ]; then
    show_error "No file selected. Exiting."
    exit 1
fi

# Generate output file name based on input files
base_name1=$(basename "$file1" .txt)
base_name2=$(basename "$file2" .txt)
output_file="${base_name1}_${base_name2}_phrases.txt"

# Check if the files exist
if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
    show_error "One or both files do not exist."
    exit 1
fi

# Clear the output file or create it if it doesn't exist
> "$output_file"

# Find common phrases for 3 and more words
for i in $(seq 3 10); do
    find_common_phrases "$i" "$file1" "$file2" "$output_file"
done

zenity --info --text="Common phrases have been written to $output_file."
