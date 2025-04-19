## Image Generator Script

A bash script to generate multiple images with customizable text, fonts, gradient backgrounds, and text colors using ImageMagick.

### Features
- Generate multiple images in one run
- Custom gradient backgrounds (start and end colors)
- Custom gradient text colors
- Flexible output naming patterns
- Automatic numbered output files
- Custom output directory
- Custom font selection
- Adjustable font size

### Requirements
- ImageMagick (`convert` command)
- `bc` calculator (for color interpolation)

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/media_scripts.git
cd media_scripts

# Make the script executable
chmod +x generate_images.sh
```

### Usage
```bash
./generate_images.sh [OPTIONS]
```

### Options
| Option | Description | Default |
|--------|-------------|---------|
| `-t`, `--text` | Text to display | "Sample Text" |
| `-f`, `--font` | Font to use (system must have font installed) | System default |
| `-fs`, `--font-size` | Font size in points | 48 |
| `-bs`, `--bg-start` | Background start color (hex) | "#4285F4" |
| `-be`, `--bg-end` | Background end color (hex) | "#34A853" |
| `-ts`, `--text-start` | Text start color (hex) | "white" |
| `-te`, `--text-end` | Text end color (hex) | "#FBBC05" |
| `-w`, `--width` | Image width | 800 |
| `-h`, `--height` | Image height | 400 |
| `-o`, `--output-dir` | Output directory | "output_images" |
| `-c`, `--count` | Number of images to generate | 5 |
| `-n`, `--name` | Filename pattern (use `%d` for number) | "image_%d.png" |

### Examples

**Basic example with custom font:**
```bash
./generate_images.sh -t "Hello World" -f "Arial" -fs 60 -c 5
```

**Custom colors and font size:**
```bash
./generate_images.sh -t "Gradient Demo" -fs 36 -bs "#FF0000" -be "#0000FF" \
  -ts "#FFFFFF" -te "#000000" -n "slide_%d.png" -c 10
```

### Font Selection Tips
1. To list available fonts on your system:
   ```bash
   convert -list font
   ```
2. For Google Fonts, ensure the font is installed system-wide
3. Font names are case-sensitive
4. For fonts with spaces, use quotes: `-f "Times New Roman"`

### Color Interpolation
The script automatically creates smooth gradients between:
- Background start and end colors
- Text start and end colors

Each image's colors are calculated based on its position in the sequence.

### Output Patterns
- Use `%d` in the name pattern for explicit number placement (e.g., `"image_%d.png"`)
- Without `%d`, numbers will be appended before the extension (e.g., `"output.png"` becomes `output1.png`)

### Notes
- All generated images will be saved in the specified output directory
- The output directory will be created if it doesn't exist
- Colors must be specified in hex format (e.g., "#RRGGBB")
- Font size is specified in points (1 point = 1/72 inch)