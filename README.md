# Raspberry Pi Camera Module + Audio Streaming to Web Browser

## Instructions

Flash a microSD card with RaspiOS-Lite using [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

Set up a DHCP reservation on your router so you know where to find your camera.

SSH into your pi or hook up a monitor and keyboard. Upon initial boot, change to autologin to console.

```
sudo raspi-config
```
```
sudo apt update && sudo apt upgrade -y && sudo apt install \
libcamera-apps npm nginx libnginx-mod-rtmp pulseaudio git -y \
&& sudo reboot
```

After the reboot:
```
sudo mkdir -p /var/www/stream/hls
sudo chown $USER:$USER -R /var/www/stream
cd /var/www/stream/
npm install video.js
cd
git clone 
```

vim index.html

vim style.css

sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

sudo vim /etc/nginx/nginx.conf
  change user to current user instead of www-data
  add rtmp block

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/stream

sudo vim /etc/nginx/sites-available/stream
  change root to /var/www/stream instead of /var/www/html

sudo ln -s /etc/nginx/sites-available/stream /etc/nginx/sites-enabled/stream

sudo rm /etc/nginx/sites-enabled/default

sudo systemctl reload nginx

pactl list sources | grep -e Name -e Source
  use desired source for "--audio-device" option in stream.sh

alsamixer
  set desired microphone volume on desired soundcard

sudo vim /usr/local/bin/stream.sh

vim ~/.profile
  stream.sh > /dev/null 2>&1 &

stream.sh

sudo reboot
