# media-scripts

scripts for converting media to web formats

### Images:

Resizes images to 1080px on the longest side, maintaining aspect ratio.

```
chmod +x .sh
./imageresize.sh /path/to/images
```


### Videos:

Takes a .mov and outputs .webm and .mp4, as well as a .jpg thumbnail.


```
chmod +x videoconvert.sh
./videoconvert.sh /path/to/videos
```


## Audio File Converter

This script recursively converts all `.m4a` and `.mp3` files in an input directory to `.wav` format in an output directory, preserving the directory structure.

### Requirements
- `ffmpeg` must be installed on your system

### Usage
```bash
./convert_to_wav.sh <input_directory> <output_directory>
```

### Features
- Preserves original directory structure
- Converts both `.m4a` and `.mp3` files
- Outputs standard WAV format (16-bit PCM, 44100Hz, stereo)
- Quiet operation with progress stats

### Example
```bash
./convert_to_wav.sh ~/Music/input_files ~/Music/wav_files
```

This will convert all audio files in `~/Music/input_files` and its subdirectories to WAV format in `~/Music/wav_files`, keeping the original file dates.