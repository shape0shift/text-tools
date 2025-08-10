#!/bin/bash

# Prompt user for the first text file
file1=$(zenity --file-selection --title="Select First Text File")

# Check if the user canceled the input
if [ $? -ne 0 ]; then
    exit
fi

# Prompt user for the second text file
file2=$(zenity --file-selection --title="Select Second Text File")

# Check if the user canceled the input
if [ $? -ne 0 ]; then
    exit
fi

# Read and process the contents of the files
words1=$(cat "$file1" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '[\n*]' | sort -u)
words2=$(cat "$file2" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '[\n*]' | sort -u)

# Find common words
common_words=$(comm -12 <(echo "$words1") <(echo "$words2"))

# Get the base names of the files for the output filename
base_file1=$(basename "$file1" .txt)
base_file2=$(basename "$file2" .txt)

# Create the output filename
output_file="${base_file1}_${base_file2}_samewords.txt"

# Write common words to the output file
if [ -z "$common_words" ]; then
    echo "No common words found." > "$output_file"
else
    echo "$common_words" > "$output_file"
fi

# Calculate statistics
total_words1=$(wc -w < "$file1")
total_words2=$(wc -w < "$file2")
unique_words1=$(echo "$words1" | wc -l)
unique_words2=$(echo "$words2" | wc -l)
total_common_words=$(echo "$common_words" | wc -l)

# Calculate relative percentages
if [ $total_words1 -gt 0 ]; then
    percent_common_in_text1=$(echo "scale=2; ($total_common_words / $total_words1) * 100" | bc)
else
    percent_common_in_text1=0
fi

if [ $total_words2 -gt 0 ]; then
    percent_common_in_text2=$(echo "scale=2; ($total_common_words / $total_words2) * 100" | bc)
else
    percent_common_in_text2=0
fi

# Calculate relative unique word comparison
if [ $unique_words1 -gt 0 ]; then
    relative_unique_comparison1=$(echo "scale=2; ($unique_words1 / $unique_words2) * 100" | bc)
else
    relative_unique_comparison1=0
fi

if [ $unique_words2 -gt 0 ]; then
    relative_unique_comparison2=$(echo "scale=2; ($unique_words2 / $unique_words1) * 100" | bc)
else
    relative_unique_comparison2=0
fi

# Write statistics to the output file
{
    echo "Common words:"
    echo "$common_words"
    echo ""
    echo "Statistics:"
    echo "- Total words in $base_file1: $total_words1"
    echo "- Total words in $base_file2: $total_words2"
    echo "- Total common words: $total_common_words"
} >> "$output_file"

# Notify the user of the output and statistics
zenity --info --text="Common words and statistics have been written to $output_file"
