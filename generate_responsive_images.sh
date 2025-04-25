#!/bin/bash

# --- Configuration ---
# Default values for generate_images.sh arguments if not provided
DEFAULT_TEXT_PATTERN="%s" # %s=name, %w=width, %h=height. Overridden by -t.
DEFAULT_FONT="Courier-10-Pitch-Bold"
DEFAULT_FONT_SIZE_BASE=48 # Base font size, used across breakpoints unless overridden
DEFAULT_BG_START="#AAAECA" # Default gradient start (light grey-blue)
DEFAULT_BG_END="#2A2B3A"   # Default gradient end (dark slate blue)
DEFAULT_TEXT_START="#3F3F3F"
DEFAULT_TEXT_END="#E0E0E0"  # Light grey
DEFAULT_BASE_HEIGHT=400     # Default height for all breakpoints, can be overridden by -h
DEFAULT_OUTPUT_DIR="output_images/responsive" # Default base output directory
DEFAULT_COUNT=1             # Default number of images *per breakpoint*
# Default name pattern *within* each breakpoint folder (%d = number). No extension here.
# generate_images.sh will add the correct extension based on format(s).
DEFAULT_NAME_PATTERN="%d"
DEFAULT_FORMATS="jpg" # Default output format(s) for generate_images.sh

# Breakpoints: Format "name width" (Common Bootstrap-like breakpoints)
# You can customize these sizes
BREAKPOINTS=(
  "xs 480 $((480 * 9 / 16))"
  "sm 640 $((640 * 9 / 16))"
  "md 768 $((768 * 9 / 16))"
  "lg 1024 $((1024 * 9 / 16))"
  "xl 1280 $((1280 * 9 / 16))"
  "xxl 1920 $((1920 * 9 / 16))"
)

# --- Dependencies Check ---
if ! command -v convert &> /dev/null; then
  echo "Error: ImageMagick (convert) is not installed. Please install it first."
  echo "On Ubuntu/Debian: sudo apt-get install imagemagick"
  echo "On macOS: brew install imagemagick"
  exit 1
fi
# bc is not strictly needed in this revised version unless adding complex scaling later
# if ! command -v bc &> /dev/null; then
#     echo "Error: bc calculator is not installed."
#     exit 1
# fi

if [ ! -f "./generate_images.sh"  ; then
  echo "Error: ./generate_images.sh not found in the current directory."
  exit 1
fi
if [ ! -x "./generate_images.sh" ]; then
  echo "Error: ./generate_images.sh is not executable. Run: chmod +x ./generate_images.sh"
  exit 1
fi

# --- Argument Parsing ---
# Initialize variables with defaults
TEXT="" # If set via -t, overrides TEXT_PATTERN
TEXT_PATTERN="$DEFAULT_TEXT_PATTERN"
FONT="$DEFAULT_FONT"
FONT_SIZE="$DEFAULT_FONT_SIZE_BASE" # Use FONT_SIZE directly now
BG_START="$DEFAULT_BG_START"
BG_END="$DEFAULT_BG_END"
TEXT_START="$DEFAULT_TEXT_START"
TEXT_END="$DEFAULT_TEXT_END"
HEIGHT="$DEFAULT_BASE_HEIGHT" # Use HEIGHT directly now
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
COUNT="$DEFAULT_COUNT"
NAME_PATTERN="$DEFAULT_NAME_PATTERN"
FORMATS="$DEFAULT_FORMATS" # Initialize formats with default

# Width is determined by breakpoints, not taken as input
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--text)
      TEXT="$2" # User provided text overrides pattern
      shift 2
      ;;
    --text-pattern)
      TEXT_PATTERN="$2" # Allow overriding the pattern
      shift 2
      ;;
    -f|--font)
      FONT="$2"
      shift 2
      ;;
    -fs|--font-size)
      FONT_SIZE="$2" # Set font size for all breakpoints
      shift 2
      ;;
    -bs|--bg-start)
      BG_START="$2"
      shift 2
      ;;
    -be|--bg-end)
      BG_END="$2"
      shift 2
      ;;
    -ts|--text-start)
      TEXT_START="$2"
      shift 2
      ;;
    -te|--text-end)
      TEXT_END="$2"
      shift 2
      ;;
    -h|--height) # Override the default height
      HEIGHT="$2"
      shift 2
      ;;
    -o|--output-dir) # Set the base output directory
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -c|--count) # Set count per breakpoint
      COUNT="$2"
      shift 2
      ;;
    -n|--name) # Set the name pattern format for generate_images.sh
      NAME_PATTERN="$2" # e.g., "%d", "img_%d" (no extension needed)
      shift 2
      ;;
    -fmt|--format|--formats) # Added format argument handling
      FORMATS="$2"
      shift 2
      ;;
    -w|--width) # Ignore width, it's set by breakpoint
      echo "Warning: -w/--width is ignored by $0. Width is determined by breakpoints."
      shift 2
      ;;
    *)
      echo "Unknown option for $0: $1"
      echo "Usage: $0 [options"
      # TODO: Add a more detailed help message if desired
      exit 1
      ;;
  esac
done

# --- Generation Logic ---

echo "Generating $COUNT responsive image(s) for each breakpoint into subdirectories of '$OUTPUT_DIR'..."
echo "Requested format(s): $FORMATS" # Inform user about formats
echo "Breakpoints and target sizes:"
printf "  %-5s %-9s %-5s\n" "Name" "Width" "Height"
printf -- "---- ------- ------\n"
for bp_info in "${BREAKPOINTS[@]}"; do
  read -r bp_name bp_width bp_height <<< "$bp_info"
  printf "  %-5s %-7s %-5s\n" "$bp_name" "$bp_width" "$bp_height"
done
echo # Add a newline for better separation

# Create the base output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through breakpoints again to generate images
for bp_info in "${BREAKPOINTS[@]}"; do
  read -r bp_name bp_width bp_height <<< "$bp_info"

  bp_output_dir="${OUTPUT_DIR}/${bp_name}"
  mkdir -p "$bp_output_dir"

  if [ -n "$TEXT" ]; then
    current_text="$TEXT"
  else
    current_text=$(echo "$TEXT_PATTERN" | sed "s/%s/$bp_name/g; s/%w/${bp_width}/g; s/%h/${bp_height}/g")
  fi

  echo "--- Breakpoint: $bp_name (${bp_width}x${bp_height}) ---"
  # Pass all relevant arguments, including the new --formats argument
  ./generate_images.sh \
    -w "$bp_width" \
    -h "$bp_height" \
    -c "$COUNT" \
    -o "$bp_output_dir" \
    -t "$current_text" \
    -f "$FONT" \
    -fs "$FONT_SIZE" \
    -bs "$BG_START" \
    -be "$BG_END" \
    -ts "$TEXT_START" \
    -te "$TEXT_END" \
    -n "$NAME_PATTERN" \
    --formats "$FORMATS" # Pass the formats argument

  if [ $? -ne 0 ]; then
    echo "Error: generate_images.sh failed for breakpoint $bp_name."
    # Consider whether to exit or continue with other breakpoints
    # exit 1 # Uncomment to stop on first failure
  fi

  echo "--- Done for breakpoint: $bp_name ---"
  echo
done


# Process base64 ONLY for xs breakpoint images
# NOTE: This section assumes the *first* format specified in FORMATS exists
#       for the xs breakpoint, and generates a *jpeg* base64 string.
#       It might need adjustment if complex format handling is required here.
base64_dir="${OUTPUT_DIR}/base64"
xs_dir="${OUTPUT_DIR}/xs"

mkdir -p "$base64_dir"

# Extract the first format from the comma-separated list
first_format=$(echo "$FORMATS" | cut -d',' -f1 | xargs) # xargs trims whitespace
if [[ -z "$first_format" ]]; then
    echo "Warning: Cannot determine primary format for base64 generation from '$FORMATS'. Skipping."
else
    echo "Generating base64 previews (from xs breakpoint, .$first_format files)..."
    for ((i=1; i<=COUNT; i++)); do
      # Construct source filename using the name pattern and the *first* format
      base_filename=$(printf "$NAME_PATTERN" "$i")
      src_img="${xs_dir}/${base_filename}.${first_format}"

      tiny_img="${base64_dir}/base64_${i}.jpg" # Keep tiny preview as jpg for consistency
      base64_txt="${base64_dir}/base64_${i}.txt"

      if [ -f "$src_img" ]; then
        # Create 16x16 jpeg (output is always jpeg)
        if convert "$src_img" -resize 16x16\! "$tiny_img"; then
          # Encode to base64 (single line, no data uri)
          if base64 -w0 "$tiny_img" > "$base64_txt"; then
            echo "Generated base64 for: $src_img -> $base64_txt"
          else
            echo "Error: Failed to encode base64 for $tiny_img"
          fi
        else
            echo "Error: Failed to resize $src_img to $tiny_img"
        fi
      else
        echo "Warning: xs source image for base64 not found: $src_img"
      fi
    done
fi


echo "==================================="
echo "Responsive image generation complete!"
echo "Images generated in subdirectories under: $OUTPUT_DIR"
echo "Base64 previews (if generated) in: $base64_dir"
echo "==================================="

exit 0