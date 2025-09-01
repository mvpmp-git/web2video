#!/bin/bash
trap "pkill ffmpeg ; pkill Xorg ; pkill google-chrome ; exit" INT TERM
# ENV URL="tagvs.com"
# ENV RESOLUTION="1920x1080"
# ENV FPS="30"
# ENV OUTPUT_FORMAT="flv"
WEIGHT=$(echo $RESOLUTION | cut -d'x' -f1)
HEIGHT=$(echo $RESOLUTION | cut -d'x' -f2)

mkdir -p /etc/X11 && cat <<EOF > /etc/X11/xorg.conf
Section "Monitor"
    Identifier "Monitor0"
    HorizSync 28.0-80.0
    VertRefresh 48.0-75.0
    Option "DPMS"
EndSection

Section "Device"
    Identifier "Card0"
    Driver "dummy"
    VideoRam 256000
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "Card0"
    Monitor "Monitor0"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Virtual ${WEIGHT} ${HEIGHT}
        Modes "${WEIGHT}x${HEIGHT}"
    EndSubSection
EndSection

Section "ServerLayout"
    Identifier "Layout0"
    Screen "Screen0"
EndSection
EOF
# Start virtual framebuffer
echo running virtual framebuffer
#Xvfb :1 -screen 1 1920x1080x24 &
export DISPLAY=":99"
Xorg $DISPLAY -config /etc/X11/xorg.conf &

sleep 5
# Start Chrome headless in kiosk mode
echo starting chrome headless
    
google-chrome \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --window-size=${WEIGHT},${HEIGHT} \
  --start-maximized \
  --kiosk "$URL" \
  --no-first-run \
  --no-default-browser-check \
  --autoplay-policy=no-user-gesture-required \
  --disable-infobars &

# Give Chrome some time to load
sleep 10

# Start streaming screen
if [[ $DUMMY_AUDIO == "true" || OUTPUT_FORMAT == "flv" ]]; then 
    AUDIO_CONFIG="-f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100"
fi
[[ -z "$OUTPUT_CONFIG" ]] && OUTPUT_CONFIG="-r $FPS -c:v libx264 -pix_fmt yuv420p -preset ultrafast -maxrate 2000k -bufsize 4000k \
    -c:a aac -b:a 128k \
    -f $OUTPUT_FORMAT $OUTPUT"
while true; do
    echo
    echo Starting ffmpeg
    echo -----------------------------------------------------------------------------------------
    echo Full ffmpeg command:
    echo "ffmpeg -thread_queue_size 1024 -probesize 42M -f x11grab -video_size ${WEIGHT}x${HEIGHT} -i $DISPLAY \
    $AUDIO_CONFIG \
    $OUTPUT_CONFIG"
    echo -----------------------------------------------------------------------------------------
    ffmpeg -thread_queue_size 1024 -probesize 42M -f x11grab -video_size ${WEIGHT}x${HEIGHT} -i $DISPLAY \
    $AUDIO_CONFIG \
    $OUTPUT_CONFIG
  echo "FFmpeg exited with status $?. Retrying in 5 seconds..."
  sleep 1
done