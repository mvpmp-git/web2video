# web2video

[![Docker Hub](https://img.shields.io/docker/pulls/mvpmp/web2video?logo=docker)](https://hub.docker.com/r/mvpmp/web2video)

## Description

Convert any web page into a video stream and send it to your ip based video player

## Features

* Capture and stream browser content (e.g. web pages, Dashboards) in real-time using FFmpeg and Chrome headless mode
* Support for multiple resolutions, frame rates, and output formats 

## Getting Started

1. Clone the repository: `git clone https://github.com/mvpmp-git/web2video.git`
2. Build the Docker image: `docker build -t web2video .`
3. Run the container: `docker run -d --network=host --name website1 web2video`
4. Check the resulted stream: `ffplay -i srt://localhost:2000`

## Usage

* To change the output URL, resolution, frame rate, output format, or provide the full ffmpeg output configline , modify the corresponding environment variables 
* The default values are as follows: 

  `URL="weather.com"`

  `OUTPUT="srt://:2000?mode=listener&latency=200000"`

  `RESOLUTION="1920x1080"`

  `FPS="29.97"`

  `OUTPUT_FORMAT="mpegts"`

  `DUMMY_AUDIO="false"`

  `OUTPUT_CONFIG="-r $FPS -c:v libx264 -pix_fmt yuv420p -preset ultrafast -maxrate 2000k -bufsize 4000k -c:a aac -b:a 128k -f $OUTPUT_FORMAT $OUTPUT"`

## Usage examples

srt in listener mode on port 2000 (--network=host is required):

`docker run -d --network=host --name website1 -e URL="some-website.com" web2video`

mpegts udp unicast:

`docker run -d --name website1 -e URL="some-website.com" -e OUTPUT="udp://192.168.55.18:3333" web2video`

mpegts udp multicast:

`docker run -d --network=host  --name website1  -e URL="some-website.com"  -e OUTPUT="udp://225.55.55.55:5000" web2video`

rtmp output SD Resolution:

`docker run -d --name website1 -e URL="some-website.com" -e RESOLUTION="720x576" -e OUTPUT_FORMAT="flv" -e OUTPUT="rtmp://192.168.55.18:1935/live/website1" web2video`

custom output configuration:

`docker run -d --name website1 -e URL="some-website.com" -e OUTPUT_CONFIG=-c:v libx265 -b:v 1000k -pix_fmt yuv420p -pcr_period 20 -f mpegts srt://192.168.70.35:5000" web2video`

## Limitations
* There is no Audio capture device - the stream will not have any sound from the website
* host network mode is required for the container in case of "listener mode"

## Contributing

* Contributions are welcome!
* Please submit pull requests or issues through this repository
* Follow standard professional guidelines when contributing code

## License

* This project is licensed under the MIT License.
* Legal implications - make sure it's allowed to capture and stream the content of a website you intend to use
