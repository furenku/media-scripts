#!/bin/bash

# Check if source directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi

# Get the source directory
SRC_DIR="$1"

# Get the script's directory and create output directory as a sibling
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Process each .mov file in the source directory
for file in "$SRC_DIR"/*.mov; do
    # Skip if no .mov files are found
    [ -e "$file" ] || continue
    
    # Convert filename to lowercase, replace spaces with underscores, remove special symbols
    base_name=$(basename "$file" .mov)
    clean_name=$(echo "$base_name" | iconv -f UTF-8 -t ASCII//TRANSLIT | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/_/g' -e 's/__*/_/g' -e 's/^_//' -e 's/_$//')

    
    echo "Processing: $file -> $clean_name"
    
    # Create MP4 version using your optimized preset
    ffmpeg -i "$file" -vf "scale=-2:720,format=yuv420p" -c:v libx264 \
        -profile:v main -preset slow -crf 23 -movflags +faststart \
        -g 60 -keyint_min 60 -an "$OUTPUT_DIR/${clean_name}.mp4"
    
    # Create WebM version
    ffmpeg -i "$file" -c:v libvpx-vp9 -b:v 0 -crf 30 -vf "scale=-2:720" \
        -an "$OUTPUT_DIR/${clean_name}.webm"
    
    # Extract first frame as JPEG
    ffmpeg -i "$file" -frames:v 1 "$OUTPUT_DIR/${clean_name}.jpg"
    
    echo "Completed: $clean_name"
done

echo "All conversions complete!"