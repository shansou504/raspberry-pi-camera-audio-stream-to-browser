#!/bin/bash

pkill -f libcamera
libcamera-vid --nopreview -t 0 --inline --codec libav --libav-format flv --libav-audio --audio-device "alsa_input.usb-C-Media_Electronics_Inc._USB_Ear-Microphone-00.mono-fallback" -o "rtmp://localhost:1935/hls/camera"
