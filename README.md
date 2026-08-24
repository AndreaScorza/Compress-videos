# Compress-videos

```
sudo apt-get update
sudo apt-get install ffmpeg
```

```
chmod +x compress_videos.sh
```

```
./compress_videos.sh [input_folder] [output_folder]
```

- `input_folder` defaults to the current directory.
- `output_folder` defaults to a `compressed` subfolder inside `input_folder`.

Example: `./compress_videos.sh ~/Desktop/gopro` compresses every `.mp4`/`.MP4` in
`~/Desktop/gopro` into `~/Desktop/gopro/compressed`, preserving resolution and metadata.


```
exiftool -overwrite_original -GPSLatitude=59.3293 -GPSLatitudeRef=N -GPSLongitude=18.0686 -GPSLongitudeRef=E ~/Desktop/1.jpg
```