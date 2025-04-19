#!/bin/bash

# Default values
DEFAULT_TEXT=""
DEFAULT_FONT="Ubuntu-Sans"  # System default
DEFAULT_FONT_SIZE=48
DEFAULT_BG_START="#4285F4"  # Google blue
DEFAULT_BG_END="#34A853"    # Google green
DEFAULT_TEXT_START="white"
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
    
    # Convert back to hex
    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# Generate images
for ((i=1; i<=COUNT; i++)); do
    # Calculate progress (0 to 1)
    progress=$(echo "scale=2; ($i-1)/($COUNT-1)" | bc)
    
    # Interpolate colors
    if [ "$COUNT" -eq 1 ]; then
        bg_color="$BG_START"
        text_color="$TEXT_START"
    else
        bg_color=$(interpolate_color "$BG_START" "$BG_END" "$progress")
        text_color=$(interpolate_color "$TEXT_START" "$TEXT_END" "$progress")
    fi
    
    # Generate filename
    if [[ "$NAME_PATTERN" == *"%d"* ]]; then
        filename=$(printf "$NAME_PATTERN" "$i")
    else
        filename="${NAME_PATTERN%.*}$i.${NAME_PATTERN##*.}"
    fi
    
    # Build convert command
    CMD="convert -size \"${WIDTH}x${HEIGHT}\" \"xc:$bg_color\" \
            -gravity Center \
            -pointsize \"$FONT_SIZE\" \
            -fill \"$text_color\" \
            -annotate 0 \"$TEXT\""
    
    # Add font if specified
    if [ -n "$FONT" ]; then
        CMD+=" -font \"$FONT\""
    fi
    
    # Complete command with output
    CMD+=" \"$OUTPUT_DIR/$filename\""
    
    # Execute command
    eval "$CMD"
    
    echo "Created: $OUTPUT_DIR/$filename (BG: $bg_color, Text: $text_color, Font: ${FONT:-system default}, Size: $FONT_SIZE)"
done

echo "Successfully created $COUNT images in $OUTPUT_DIR/"
