#!/bin/bash

# --- Configuration ---
# Default values for generate_images.sh arguments if not provided
DEFAULT_TEXT_PATTERN="%s" # %s=name, %w=width, %h=height. Overridden by -t.
DEFAULT_FONT="Ubuntu-Sans-Condensed-ExtraBold"
DEFAULT_FONT_SIZE_BASE=48 # Base font size, used across breakpoints unless overridden
DEFAULT_BG_START="#AAAECA" # Default gradient start (light grey-blue)
DEFAULT_BG_END="#2A2B3A"   # Default gradient end (dark slate blue)
DEFAULT_TEXT_START="#FFFFFF"
DEFAULT_TEXT_END="#E0E0E0"  # Light grey
DEFAULT_BASE_HEIGHT=400     # Default height for all breakpoints, can be overridden by -h
DEFAULT_OUTPUT_DIR="output_images/responsive" # Default base output directory
DEFAULT_COUNT=1             # Default number of images *per breakpoint*
DEFAULT_NAME_PATTERN="%d.png" # Default name pattern *within* each breakpoint folder (%d = number)

# Breakpoints: Format "name width" (Common Bootstrap-like breakpoints)
# You can customize these sizes
BREAKPOINTS=(
  "xs 480"
  "sm 640"
  "md 768"
  "lg 1024"
  "xl 1280"
  "xxl 1400"
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

if [ ! -f "./generate_images.sh" ; then
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
      NAME_PATTERN="$2" # e.g., "%d.jpg", "img_%d.png"
      shift 2
      ;;
    -w|--width) # Ignore width, it's set by breakpoint
      echo "Warning: -w/--width is ignored by $0. Width is determined by breakpoints."
      shift 2
      ;;
    *)
      echo "Unknown option for $0: $1"
      echo "Usage: $0 [options]"
      # TODO: Add a more detailed help message if desired
      exit 1
      ;;
  esac
done

# --- Generation Logic ---

echo "Generating $COUNT responsive image(s) for each breakpoint into subdirectories of '$OUTPUT_DIR'..."
echo "Using base height: ${HEIGHT}px"
echo "Breakpoints and target sizes:"
printf "  %-5s %-5s\n" "Name" "Width"
printf -- "---- -------\n"
for bp_info in "${BREAKPOINTS[@]}"; do
  read -r bp_name bp_width <<< "$bp_info"
  printf "  %-5s %-5s\n" "$bp_name" "${bp_width}px"
done
echo # Add a newline for better separation

# Create the base output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through breakpoints again to generate images
for bp_info in "${BREAKPOINTS[@]}"; do
  read -r bp_name bp_width <<< "$bp_info"

  # Create specific output directory for this breakpoint
  bp_output_dir="${OUTPUT_DIR}/${bp_name}"
  mkdir -p "$bp_output_dir"

  # Determine the text for this specific image
  if [ -n "$TEXT" ]; then
    # Use the user-provided text directly
    current_text="$TEXT"
  else
    # Substitute values into the text pattern
    # Using sed for substitution as printf can be tricky with '%'
    current_text=$(echo "$TEXT_PATTERN" | sed "s/%s/$bp_name/g; s/%w/${bp_width}/g; s/%h/${HEIGHT}/g")
  fi

  echo "--- Generating for breakpoint: $bp_name (${bp_width}x${HEIGHT}) ---"
  echo "Outputting to: $bp_output_dir"
  echo "Text: '$current_text'"

  # Call generate_images.sh for the current breakpoint
  # Pass arguments explicitly to the sub-script
  ./generate_images.sh \
    -w "$bp_width" \
    -h "$HEIGHT" \
    -c "$COUNT" \
    -o "$bp_output_dir" \
    -t "$current_text" \
    -f "$FONT" \
    -fs "$FONT_SIZE" \
    -bs "$BG_START" \
    -be "$BG_END" \
    -ts "$TEXT_START" \
    -te "$TEXT_END" \
    -n "$NAME_PATTERN"
    # Note: We let generate_images.sh handle the specific file naming
    # within its directory using the -n pattern it receives.

  # Check the exit status of the sub-script (optional but good practice)
  if [ $? -ne 0 ]; then
    echo "Error: generate_images.sh failed for breakpoint $bp_name."
    # Decide whether to continue or exit
    # exit 1 # Uncomment to stop on first error
  fi

  echo "--- Done for breakpoint: $bp_name ---"
  echo # Add a newline for better separation

done # End of breakpoint loop

echo "==================================="
echo "Responsive image generation complete!"
echo "Images generated in subdirectories under: $OUTPUT_DIR"
echo "==================================="

exit 0