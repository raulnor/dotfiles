#!/usr/bin/env zsh
: "${YT_MP3_DIR:=${HOME}/Documents/Music/yt-dlp}"


if [[ -z "$1" ]]; then
    echo "Usage: $(basename $0) <video_id>"
    return 1
fi


if [[ ! -d "$YT_MP3_DIR" ]]; then
    read "reply?Create ${YT_MP3_DIR}? [y/N] "
    [[ "$reply" =~ ^[Yy]$ ]] || return 2
    mkdir -p "$YT_MP3_DIR"
fi


yt-dlp -x --audio-format mp3 \
    --embed-metadata --embed-thumbnail \
    --parse-metadata "%(title)s:%(artist)s - %(track)s" \
    -o "${YT_MP3_DIR}/%(title)s.%(ext)s" \
    "https://www.youtube.com/watch?v=$1"