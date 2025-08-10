#!/bin/bash

# Dependency check
DEPS=("zenity" "python3")
for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        zenity --error --text="$dep is not installed. Please install it first." 2>/dev/null
        exit 1
    fi
done

# Try to import fuzzywuzzy, install if not present
python3 -c "import fuzzywuzzy" 2>/dev/null
if [ $? -ne 0 ]; then
    zenity --question --text="fuzzywuzzy library not found. Install now?" --width=300
    if [ $? -eq 0 ]; then
        if command -v pip3 &> /dev/null; then
            pip3 install fuzzywuzzy python-Levenshtein
        else
            zenity --error --text="pip3 not found. Please install pip3 and fuzzywuzzy manually." 2>/dev/null
            exit 1
        fi
    fi
fi

# Create temporary files
TEXT1=$(mktemp)
TEXT2=$(mktemp)
RESULTS=$(mktemp)

# Large text input dialogs
input1=$(zenity --text-info \
    --title="First Text" \
    --editable \
    --width=800 \
    --height=600 \
    --ok-label="Compare" \
    --cancel-label="Exit" 2>/dev/null)

# Check first input
if [ $? -ne 0 ]; then
    rm "$TEXT1" "$TEXT2" "$RESULTS"
    exit 0
fi

input2=$(zenity --text-info \
    --title="Second Text" \
    --editable \
    --width=800 \
    --height=600 \
    --ok-label="Compare" \
    --cancel-label="Exit" 2>/dev/null)

# Check second input
if [ $? -ne 0 ]; then
    rm "$TEXT1" "$TEXT2" "$RESULTS"
    exit 0
fi

# Write inputs to temp files
echo "$input1" > "$TEXT1"
echo "$input2" > "$TEXT2"

# Process and compare texts
python3 << EOF > "$RESULTS"
from fuzzywuzzy import fuzz
from collections import Counter

def process_text(filename):
    with open(filename, 'r') as f:
        text = f.read().lower()
    # Remove punctuation and split into words
    import re
    words = re.findall(r'\w+', text)
    return words

# Read and process texts
words1 = process_text('$TEXT1')
words2 = process_text('$TEXT2')

# Exact matches
exact_matches = set(words1) & set(words2)

# Similar words
similar_words = []
for w1 in set(words1):
    for w2 in set(words2):
        similarity = fuzz.ratio(w1, w2)
        if 70 <= similarity < 100:
            similar_words.append((w1, w2, similarity))

# Sort similar words by similarity
similar_words.sort(key=lambda x: x[2], reverse=True)

# Prepare output
print("Comparison Results:\n")
print(f"Total Words in Text 1: {len(words1)}")
print(f"Total Words in Text 2: {len(words2)}")
print(f"Unique Words in Text 1: {len(set(words1))}")
print(f"Unique Words in Text 2: {len(set(words2))}")
print("\n--- Exact Matches ---")
print(", ".join(sorted(exact_matches)) if exact_matches else "No exact matches")

print("\n--- Similar Words ---")
if similar_words:
    for w1, w2, sim in similar_words:
        print(f"{w1} ↔ {w2} (Similarity: {sim}%)")
else:
    print("No similar words found")

# Word frequency analysis
print("\n--- Word Frequency ---")
word_freq1 = Counter(words1)
word_freq2 = Counter(words2)

print("Top 5 Most Frequent Words in Text 1:")
for word, count in word_freq1.most_common(5):
    print(f"{word}: {count} times")

print("\nTop 5 Most Frequent Words in Text 2:")
for word, count in word_freq2.most_common(5):
    print(f"{word}: {count} times")

# Unique words in each text
unique_to_text1 = set(words1) - set(words2)
unique_to_text2 = set(words2) - set(words1)

print("\n--- Unique Words ---")
print("Words only in Text 1:")
print(", ".join(sorted(unique_to_text1)) if unique_to_text1 else "No unique words")

print("\nWords only in Text 2:")
print(", ".join(sorted(unique_to_text2)) if unique_to_text2 else "No unique words")
EOF

# Display results
cat "$RESULTS" | zenity --text-info \
    --title="Text Comparison Results" \
    --width=800 \
    --height=600 \
    2>/dev/null

# Clean up temporary files
rm "$TEXT1" "$TEXT2" "$RESULTS"
