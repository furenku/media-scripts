#!/bin/bash

# Check if the target directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <target_directory>"
    exit 1
fi

# Target directory
target_dir="$1"

# Create output directory
output_dir="./output/images"
mkdir -p "$output_dir"

# Loop through all image files in the target directory
for file in "$target_dir"/*.jpg "$target_dir"/*.jpeg "$target_dir"/*.png; do
    # Get the dimensions of the image
    width=$(identify -format "%w" "$file")
    height=$(identify -format "%h" "$file")

    # Check if the width is greater than the height
    if [ $width -gt $height ]; then
        # Resize the image to 1080 width while maintaining aspect ratio and save in output directory
        convert "$file" -resize 1080x "${output_dir}/${file##*/}"
    else
        # Resize the image to 1080 height while maintaining aspect ratio and save in output directory
        convert "$file" -resize x1080 "${output_dir}/${file##*/}"
    fi
done

echo "Images resized and saved in ${output_dir}"