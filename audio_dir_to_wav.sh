#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

input_dir="$1"
output_dir="$2"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Find all m4a and mp3 files recursively and process them
find "$input_dir" -type f \( -iname "*.m4a" -o -iname "*.mp3" \) | while read -r file; do
    # Get relative path
    rel_path="${file#$input_dir}"
    rel_path="${rel_path#/}"  # Remove leading slash if present
    
    # Create output path
    wav_file="${rel_path%.*}.wav"  # Change extension to .wav
    output_path="$output_dir/$wav_file"
    
    # Create directory structure in output
    mkdir -p "$(dirname "$output_path")"
    
    # Get original timestamps
    original_mtime=$(stat -c %y "$file")
    
    # Convert to wav using ffmpeg
    echo "Converting $file to $output_path"
    ffmpeg -i "$file" -acodec pcm_s16le -ar 44100 -ac 2 "$output_path" -v quiet -stats
    
    # Restore original timestamps
    touch -d "$original_mtime" "$output_path"
done

echo "Conversion complete"