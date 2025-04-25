# Media Processing Shell Scripts

This repository contains a collection of shell scripts designed for common media processing tasks, such as audio conversion, image generation, image resizing, and video conversion.

## Important Rules (For Development)

Always include the language and file name in the info string when you write code blocks. If you are editing "src/main.py" for example, your code block should start with '```python src/main.py'.

## Dependencies

These scripts rely on several common command-line tools. Ensure you have them installed:

*   **bash**: The shell environment itself.
*   **ffmpeg**: For audio and video processing (`audio_dir_to_wav.sh`, `video_convert.sh`).
*   **ImageMagick**: For image manipulation (`generate_images.sh`, `generate_responsive_images.sh`, `image_resize.sh`). Specifically, the `convert` and `identify` commands.
*   **bc**: An arbitrary precision calculator, used for potential future color interpolation or calculations (used in `generate_images.sh`).
*   **coreutils**: Basic tools like `find`, `mkdir`, `dirname`, `basename`, `tr`, `sed`, `stat`, `touch`.
*   **iconv**: For character set conversion in `video_convert.sh` filenames.

Installation commands (examples):

*   **Debian/Ubuntu:** `sudo apt update && sudo apt install ffmpeg imagemagick bc coreutils findutils`
*   **macOS (using Homebrew):** `brew install ffmpeg imagemagick bc coreutils findutils gnu-sed gnu-stat` (Note: You might need to adjust paths or use `gsed`, `gstat` etc. if using GNU versions on macOS).

## Making Scripts Executable

Before running any script, make it executable:

```bash
chmod +x audio_dir_to_wav.sh generate_images.sh generate_responsive_images.sh image_resize.sh video_convert.sh
# Or individually:
chmod +x <script_name.sh>
```

## Scripts

### 1. audio_dir_to_wav.sh
Converts audio files (M4A, MP3) within a specified directory tree to WAV format, preserving the directory structure and original modification times.

Purpose: Useful for standardizing audio files into uncompressed WAV format (PCM S16 LE, 44.1kHz, Stereo) for further processing or compatibility.

Usage:

```bash
./audio_dir_to_wav.sh <input_directory> <output_directory>
```

Arguments:

- `<input_directory>`: The root directory containing the source audio files (searches recursively).
- `<output_directory>`: The directory where the converted WAV files will be saved, mirroring the input directory structure.

Features:

- Recursively finds .m4a and .mp3 files (case-insensitive).
- Creates the corresponding directory structure in the output directory.
- Converts audio to 16-bit PCM WAV, 44.1kHz sample rate, 2 channels (stereo).
- Uses ffmpeg for conversion.
- Attempts to preserve the original file modification timestamp on the new WAV file.
- Provides progress output via ffmpeg -stats.

Dependencies: bash, find, mkdir, ffmpeg, stat, touch, dirname.

### 2. generate_images.sh
Generates a series of images featuring specified text centered on a gradient background. Allows customization of dimensions, fonts, colors, and output.

Purpose: Create placeholder images, test image galleries, or generate simple graphical elements programmatically.

Usage:

```bash
./generate_images.sh [options]
```

Example:

```bash
# Generate 10 PNG images (800x600) with text "Example", output to 'generated_pics'
./generate_images.sh -t "Example" -w 800 -h 600 -c 10 -o generated_pics \
    -bs "#FF0000" -be "#0000FF" -ts "#FFFFFF" -te "#FFFF00"

# Generate 3 JPG images (600x300)
./generate_images.sh -w 600 -h 300 -c 3 -o generated_jpgs --format jpg -n "%d_image"
```

Options:

- `-t, --text <string>`: Text to display on the image (Default: "").
- `-f, --font <font_name>`: Font name (must be known to ImageMagick) (Default: Ubuntu-Sans).
- `-fs, --font-size <number>`: Font size in points (Default: 48).
- `-bs, --bg-start <hex_color>`: Background gradient start color (e.g., #RRGGBB) (Default: #4285F4).
- `-be, --bg-end <hex_color>`: Background gradient end color (Default: #34A853).
- `-ts, --text-start <hex_color>`: Text gradient start color (Default: white).
- `-te, --text-end <hex_color>`: Text gradient end color (Default: #FBBC05).
- `-w, --width <number>`: Image width in pixels (Default: 800).
- `-h, --height <number>`: Image height in pixels (Default: 400).
- `-o, --output-dir <path>`: Directory to save generated images (Default: output_images).
- `-c, --count <number>`: Number of images to generate (Default: 5).
- `-n, --name <pattern>`: Output filename pattern (base name). Use %d for sequence number (Default: %d). The file extension is determined by --format.
- `-fmt, --format, --formats <format>`: Output image format (Default: png). Supported: png, jpg, gif, webp. This option determines the actual format and file extension.

Features:

- Creates images with a smooth gradient background.
- Overlays centered text, also with an optional gradient fill.
- Interpolates colors between the start and end values across the generated sequence (when count > 1).
- Allows specifying the output format (PNG, JPG, GIF, WebP).
- Highly customizable via command-line options.

Dependencies: bash, ImageMagick (convert), bc, mkdir, printf.

### 3. generate_responsive_images.sh
Generates sets of images sized for common responsive web design breakpoints (e.g., xs, sm, md, lg, xl, xxl) by repeatedly calling `generate_images.sh` with varying widths.

Purpose: Streamline the creation of placeholder or test images for different screen sizes in responsive web layouts.

Usage:

```bash
./generate_responsive_images.sh [options]
```

Example:

```bash
# Generate 5 PNG images for each breakpoint into 'responsive_placeholders' directory
# Use custom height, colors, and font size
./generate_responsive_images.sh -c 5 -o responsive_placeholders -h 300 \
    -bs "#E0C3FC" -be "#8ECAE6" -ts "#023047" -te "#023047" -fs 36

# Generate 2 WebP images per breakpoint
./generate_responsive_images.sh -c 2 -o responsive_webp --format webp
```

Options:

- `-t, --text <string>`: Set specific text for all images. Overrides --text-pattern.
- `--text-pattern <pattern>`: Format string for text. Use %s for breakpoint name, %w for width, %h for height. (Default: "Breakpoint %s (%wx%h)").
- `-f, --font <font_name>`: Font name (passed to `generate_images.sh`) (Default: Ubuntu-Sans).
- `-fs, --font-size <number>`: Base font size used across all breakpoints (Default: 48).
- `-bs, --bg-start <hex_color>`: Background gradient start color (Default: #AAAECA).
- `-be, --bg-end <hex_color>`: Background gradient end color (Default: #2A2B3A).
- `-ts, --text-start <hex_color>`: Text gradient start color (Default: white).
- `-te, --text-end <hex_color>`: Text gradient end color (Default: #E0E0E0).
- `-h, --height <number>`: Height in pixels, used for all breakpoints (Default: 400).
- `-o, --output-dir <path>`: Base directory to save images. Subdirectories named after breakpoints (xs, sm, etc.) will be created here (Default: output_images/responsive).
- `-c, --count <number>`: Number of images to generate per breakpoint (Default: 1).
- `-n, --name <pattern>`: Filename pattern (base name) for images within each breakpoint directory (passed to `generate_images.sh`). Use %d for sequence number (Default: %d). Extension determined by --format.
- `-fmt, --format, --formats <format>`: Output image format for all generated images (Default: png). Supported: png, jpg, gif, webp. Passed to `generate_images.sh`.
- `-w, --width`: This option is ignored by `generate_responsive_images.sh` as width is determined by the predefined breakpoints.

Features:

- Defines standard breakpoints (xs, sm, md, lg, xl, xxl) with corresponding widths.
- Calls `generate_images.sh` for each defined breakpoint.
- Generates images into organized subdirectories within the specified output path (e.g., output_dir/xs/, output_dir/sm/, etc.).
- Allows customization of most visual parameters (colors, font, text, height, font size, format) which are applied consistently across all breakpoints.
- Text can be static or dynamic using the --text-pattern option.

Breakpoints (Default):

| Name | Width |
| :--- | ----: |
| xs | 480px |
| sm | 640px |
| md | 768px |
| lg | 1024px |
| xl | 1280px |
| xxl | 1400px |

(These can be modified directly within the script if needed)

Dependencies: bash, ./generate_images.sh (must be in the same directory and executable), ImageMagick (convert).

### 4. image_resize.sh
Resizes images (JPG, JPEG, PNG) in a specified directory to a maximum dimension (1080px) while preserving their aspect ratio.

Purpose: Useful for preparing images for web use or standardizing dimensions without distortion.

Usage:

```bash
./image_resize.sh <target_directory>
```

Arguments:

- `<target_directory>`: The directory containing the source images (.jpg, .jpeg, .png) to resize.

Features:

- Checks if the image is wider than tall (landscape) or taller than wide (portrait).
- Resizes landscape images to 1080 pixels wide.
- Resizes portrait images to 1080 pixels tall.
- Maintains the original aspect ratio during resizing.
- Uses ImageMagick's identify to get dimensions and convert to resize.
- Saves the resized images to a subdirectory named ./output/images (relative to where the script is run).

Dependencies: bash, ImageMagick (identify, convert), mkdir.

### 5. video_convert.sh
Converts .mov video files from a source directory into web-optimized MP4 (H.264) and WebM (VP9) formats, and extracts the first frame as a JPEG thumbnail.

Purpose: Prepare video files for efficient web delivery across different browsers.

Usage:

```bash
./video_convert.sh <source_directory>
```

Arguments:

- `<source_directory>`: The directory containing the .mov files to convert.

Features:

- Processes all .mov files in the specified source directory.
- Cleans filenames: converts to lowercase, replaces spaces and special characters with underscores.
- Creates MP4 version:
  - H.264 codec (libx264).
  - 720p resolution (scale=-2:720).
  - yuv420p pixel format for broad compatibility.
  - main profile, slow preset, CRF 23 for good quality/size balance.
  - +faststart for progressive loading/streaming.
  - Keyframes every 60 frames (-g 60 -keyint_min 60).
  - Removes audio (-an).
- Creates WebM version:
  - VP9 codec (libvpx-vp9).
  - 720p resolution.
  - CRF 30 for quality.
  - Removes audio (-an).
- Extracts the first frame as a JPEG thumbnail (.jpg).
- Saves all output files (MP4, WebM, JPG) to a subdirectory named ./output (relative to the script's location).
- Uses ffmpeg for all video operations and iconv for filename sanitization.

Dependencies: bash, ffmpeg, mkdir, basename, dirname, iconv, tr, sed.