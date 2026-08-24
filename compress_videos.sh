#!/bin/bash

# Usage: ./compress_videos.sh [input_folder] [output_folder]
# input_folder defaults to the current directory.
# output_folder defaults to a "compressed" subfolder inside input_folder.
input_folder="${1:-.}"
output_folder="${2:-$input_folder/compressed}"

# Create output folder if it doesn't exist
mkdir -p "$output_folder"

# Match .MP4/.mp4 case-insensitively, and don't error if none match
shopt -s nocaseglob nullglob

video_files=("$input_folder"/*.MP4)
total=${#video_files[@]}
count=0

# Convert an ffmpeg out_time timestamp (HH:MM:SS.ffffff) to whole seconds
to_seconds() {
    local h m s
    IFS=: read -r h m s <<< "$1"
    s=${s%.*}
    echo $((10#${h:-0} * 3600 + 10#${m:-0} * 60 + 10#${s:-0}))
}

# Iterate through each video file in the input folder
for video_file in "${video_files[@]}"; do
    count=$((count + 1))

    # Get the filename without extension
    filename=$(basename -- "$video_file")
    filename_no_ext="${filename%.*}"

    # Compressed video output path
    compressed_video="$output_folder/${filename_no_ext}_compressed.mp4"

    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_file")
    duration=${duration%.*}

    echo "[$count/$total] Compressing '$filename'..."

    # Execute FFmpeg command to compress and resize the video,
    # reporting machine-readable progress on stdout for the bar below
    ffmpeg -y -i "$video_file" -c:v libx265 -crf 20 -preset ultrafast -vf "scale=1920:1080" -x265-params log-level=none -map_metadata 0 \
        -progress pipe:1 -nostats -loglevel error "$compressed_video" |
    while IFS='=' read -r key value; do
        case "$key" in
            out_time)
                [ -z "$duration" ] || [ "$duration" -le 0 ] && continue
                current=$(to_seconds "$value")
                percent=$((current * 100 / duration))
                [ "$percent" -gt 100 ] && percent=100
                filled=$((percent / 2))
                bar=$(printf '%*s' "$filled" '' | tr ' ' '#')
                printf '\r  [%d/%d] [%-50s] %3d%%' "$count" "$total" "$bar" "$percent"
                ;;
            progress)
                if [ "$value" = "end" ]; then
                    bar=$(printf '%*s' 50 '' | tr ' ' '#')
                    printf '\r  [%d/%d] [%-50s] 100%%\n' "$count" "$total" "$bar"
                fi
                ;;
        esac
    done

    # Output status message
    echo "Compressed video '$filename' saved as '$compressed_video'"
done

echo "All videos compressed and saved in '$output_folder'"
