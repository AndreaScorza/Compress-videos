#!/bin/bash

# Input folder containing videos
input_folder="Downloads/my_video"

# Output folder for compressed videos
output_folder="Desktop/compressed_videos"

# Create output folder if it doesn't exist
mkdir -p "$output_folder"

# Iterate through each video file in the input folder
for video_file in "$input_folder"/*.mp4; do
    # Get the filename without extension
    filename=$(basename -- "$video_file")
    filename_no_ext="${filename%.*}"
    
    # Compressed video output path
    compressed_video="$output_folder/${filename_no_ext}_compressed.mp4"
    
    # Execute FFmpeg command to compress and resize the video
    ffmpeg -i "$video_file" -c:v libx265 -crf 20 -preset ultrafast -vf "scale=1920:1080" -map_metadata 0 "$compressed_video"
    
    # Output status message
    echo "Compressed video '$filename' saved as '$compressed_video'"
done

echo "All videos compressed and saved in '$output_folder'"
