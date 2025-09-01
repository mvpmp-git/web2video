FROM ubuntu:22.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests wget ca-certificates && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
    ffmpeg  xserver-xorg-video-dummy ./google-chrome-stable_current_amd64.deb && \
    rm ./google-chrome-stable_current_amd64.deb && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/*

ENV URL="weather.com"
ENV OUTPUT="srt://:2000?mode=listener&latency=200000"
ENV RESOLUTION="1920x1080"
ENV FPS="29.97"
ENV DUMMY_AUDIO="false"
ENV OUTPUT_FORMAT="mpegts"
ENV OUTPUT_CONFIG=""

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
