#!/bin/bash

# Default values
DEFAULT_TEXT=""
DEFAULT_FONT="Ubuntu-Sans-Condensed-ExtraBold"  # System default
DEFAULT_FONT_SIZE=48
DEFAULT_BG_START="#4285F4"  # Google blue
DEFAULT_BG_END="#34A853"    # Google green
DEFAULT_TEXT_START="#FFFFFF" # White
DEFAULT_TEXT_END="#FBBC05"   # Google yellow
DEFAULT_WIDTH=800
DEFAULT_HEIGHT=400
DEFAULT_OUTPUT_DIR="output_images"
DEFAULT_COUNT=5
DEFAULT_NAME_PATTERN="%d.png"  # %d will be replaced with number

# Check dependencies
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    echo "On Ubuntu/Debian: sudo apt-get install imagemagick"
    echo "On macOS: brew install imagemagick"
    exit 1
fi

if ! command -v bc &> /dev/null; then
    echo "Error: bc calculator is not installed."
    exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--text)
            TEXT="$2"
            shift 2
            ;;
        -f|--font)
            FONT="$2"
            shift 2
            ;;
        -fs|--font-size)
            FONT_SIZE="$2"
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
        -w|--width)
            WIDTH="$2"
            shift 2
            ;;
        -h|--height)
            HEIGHT="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -c|--count)
            COUNT="$2"
            shift 2
            ;;
        -n|--name)
            NAME_PATTERN="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set defaults if not provided
TEXT="${TEXT:-$DEFAULT_TEXT}"
FONT="${FONT:-$DEFAULT_FONT}"
FONT_SIZE="${FONT_SIZE:-$DEFAULT_FONT_SIZE}"
BG_START="${BG_START:-$DEFAULT_BG_START}"
BG_END="${BG_END:-$DEFAULT_BG_END}"
TEXT_START="${TEXT_START:-$DEFAULT_TEXT_START}"
TEXT_END="${TEXT_END:-$DEFAULT_TEXT_END}"
WIDTH="${WIDTH:-$DEFAULT_WIDTH}"
HEIGHT="${HEIGHT:-$DEFAULT_HEIGHT}"
OUTPUT_DIR="${OUTPUT_DIR:-$DEFAULT_OUTPUT_DIR}"
COUNT="${COUNT:-$DEFAULT_COUNT}"
NAME_PATTERN="${NAME_PATTERN:-$DEFAULT_NAME_PATTERN}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to interpolate between two colors
interpolate_color() {
    local c1="$1"
    local c2="$2"
    local factor="$3"
    
    # Convert hex to RGB
    r1=$((16#${c1:1:2}))
    g1=$((16#${c1:3:2}))
    b1=$((16#${c1:5:2}))
    
    r2=$((16#${c2:1:2}))
    g2=$((16#${c2:3:2}))
    b2=$((16#${c2:5:2}))
    
    # Interpolate
    r=$(echo "scale=0; $r1 + ($r2 - $r1) * $factor" | bc)
    g=$(echo "scale=0; $g1 + ($g2 - $g1) * $factor" | bc)
    b=$(echo "scale=0; $b1 + ($b2 - $b1) * $factor" | bc)
    
    r=${r%.*}
    g=${g%.*}
    b=${b%.*}

    printf "#%02x%02x%02x" "$r" "$g" "$b"

}

for i in $(seq 0 $((COUNT - 1))); do
    # Calculate interpolation factor (0 to 1)
    # Handle COUNT=1 case to avoid division by zero
    if [[ $COUNT -eq 1 ]]; then
        factor=0
    else
        # Use bc for floating point division
        factor=$(echo "scale=10; $i / ($COUNT - 1)" | bc)
    fi

    # Interpolate colors
    bg_color=$(interpolate_color "$BG_START" "$BG_END" "$factor")
    text_color=$(interpolate_color "$TEXT_START" "$TEXT_END" "$factor")
    # Check if interpolation failed (returned original color and exit code 1)
    if [[ $? -ne 0 ]]; then
        echo "Warning: Color interpolation failed for image $i. Using start colors." >&2
        # Optionally fallback or exit
        bg_color="$BG_START"
        text_color="$TEXT_START"
        # exit 1 # Or continue with defaults
    fi


    # Format filename
    # Using printf for potentially safer formatting than direct substitution
    filename=$(printf "$NAME_PATTERN" "$((i+1))")

    # Build the convert command arguments in an array for safety
    cmd_args=() # Initialize empty array

    # Base command: Create the gradient background canvas
    # Use the interpolated bg_color for a smooth transition effect image-to-image
    # Or use "$BG_START"-"$BG_END" for a consistent gradient in every image
    # Let's use the interpolated color for a solid background that changes
    # cmd_args=(convert -size "${WIDTH}x${HEIGHT}" "canvas:${bg_color}")
    # -- OR -- for a gradient within each image:
    cmd_args=(convert -size "${WIDTH}x${HEIGHT}" "gradient:${BG_START}-${BG_END}")


    # Font settings (only if FONT is explicitly provided by user)
    # Check the variable FONT which holds the user input or the default
    if [[ "$FONT" != "$DEFAULT_FONT" ]] || [[ -n "$FONT" ]]; then # Add font if specified or not the default
         # Check if the font exists (basic check)
         if convert -list font | grep -q "Font: $FONT"; then
             cmd_args+=(-font "$FONT")
         else
             echo "Warning: Font '$FONT' not found by ImageMagick. Using system default." >&2
             # Optionally remove FONT variable here so it's not used later if needed
         fi
    fi
    # If no valid FONT specified, ImageMagick will use its default

    # Text settings
    cmd_args+=(-gravity center -pointsize "$FONT_SIZE" -fill "$text_color" -annotate +0+0 "$TEXT")

    # Output file
    cmd_args+=("$OUTPUT_DIR/$filename")

    # --- Debugging ---
    printf "\n--- Generating: %s ---\n" "$filename"
    printf "BG Color: %s, Text Color: %s\n" "$bg_color" "$text_color"
    printf "Executing command:\n"
    # Use printf to safely quote each argument
    printf "  Arg: %q\n" "${cmd_args[@]}"
    echo "----------------------"
    # --- End Debugging ---

    # Execute the command
    if ! "${cmd_args[@]}"; then
        echo "Error: convert command failed for '$filename'. See ImageMagick error above." >&2
        # Optional: exit here if one failure should stop the script
        # exit 1
    else
        # Use the previously problematic echo line - should work now
        echo "Created: $OUTPUT_DIR/$filename (BG: $bg_color, Text: $text_color, Font: ${FONT:-system default}, Size: $FONT_SIZE)"
    fi

done

echo "Image generation complete. Output in '$OUTPUT_DIR'."
