#!/bin/bash

# Prompt user for the first text file
file1=$(zenity --file-selection --title="Select First Text File")

# Check if the user canceled the input
if [ $? -ne 0 ]; then
    exit
fi

# Prompt user for the second text file
file2=$(zenity --file-selection --title="Select Second Text File")  # Fixed missing closing parenthesis

# Check if the user canceled the input
if [ $? -ne 0 ]; then
    exit
fi

# Read and process the contents of the files
words1=$(cat "$file1" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '[\n*]' | sort -u)
words2=$(cat "$file2" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '[\n*]' | sort -u)

# Find common words
common_words=$(comm -12 <(echo "$words1") <(echo "$words2"))

# Calculate statistics
unique_words1=$(echo "$words1" | wc -l)
unique_words2=$(echo "$words2" | wc -l)
total_common_words=$(echo "$common_words" | wc -l)

# Calculate common word ratios
if [ $unique_words1 -gt 0 ]; then
    common_word_ratio1=$(echo "scale=4; ($total_common_words / $unique_words1) * 100" | bc)
else
    common_word_ratio1=0
fi

if [ $unique_words2 -gt 0 ]; then
    common_word_ratio2=$(echo "scale=4; ($total_common_words / $unique_words2) * 100" | bc)
else
    common_word_ratio2=0
fi

# Calculate average similarity percentage
average_similarity=$(echo "scale=2; ($common_word_ratio1 + $common_word_ratio2) / 2" | bc)

# Get the base names of the files for the output filename
base_file1=$(basename "$file1" .txt)
base_file2=$(basename "$file2" .txt)

# Create the output filename
#output_file="similarity_report.txt"
output_file="${base_file1}_${base_file2}_similarity_report.txt"


# Write results to the output file
{
    echo "Total unique words in $(basename "$file1"): $unique_words1"
    echo "Total unique words in $(basename "$file2"): $unique_words2"
    echo "Total common words: $total_common_words"
    echo "Common word ratio in $(basename "$file1"): $common_word_ratio1%"
    echo "Common word ratio in $(basename "$file2"): $common_word_ratio2%"
    echo "Average similarity percentage: $average_similarity%"
} > "$output_file"

# Notify the user of the output
zenity --info --text="Similarity report has been written to $output_file"
