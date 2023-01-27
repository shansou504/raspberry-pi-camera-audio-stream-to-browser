# Raspberry Pi Audio + Video Stream to Web Browser

## Instructions

Flash a microSD card with RaspiOS-Lite using [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

Set up a DHCP reservation or static IP address on your router. Connect to pi via ssh.

Setup auto login to console through raspi-config.

```
sudo raspi-config
```

Update the system, install the required applications, and reboot.

```
sudo apt update && sudo apt upgrade -y && sudo apt install \
libcamera-apps npm nginx libnginx-mod-rtmp pulseaudio git \
vim -y && sudo reboot
```

Create the directory for the web server. Install [video.js](https://github.com/videojs/video.js)
in web directory. Clone this repository for the main html page and stylesheet.
Backup the default nginx.conf

```
sudo mkdir -p /var/www/stream/hls
sudo chown $USER:$USER -R /var/www/stream
cd /var/www/stream/
npm install video.js
cd
git clone https://github.com/shansou504/raspberry-pi-camera-audio-stream-to-browser.git
cd src
sudo cp src/var/www/stream/* /var/www/stream/
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
```

Update the nginx.conf to include the rtmp application server.
Change the _user_ from _www-data_ to the current user.

```
sudo vim /etc/nginx/nginx.conf
```
```

Add the rtmp server block (above the html block) with the hls application (below) to receive the stream.

```
rtmp {
	server {
		listen 1935;

		application hls {
			live on;
			hls on;
			hls_path /var/www/stream/hls;
		}
	}
}
```

Create the available site in nginx.

```
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/stream
```

Change the location to stream instead of html

```
sudo vim /etc/nginx/sites-available/stream
```

Create a link to enable the site and disable the default site.

```
sudo ln -s /etc/nginx/sites-available/stream /etc/nginx/sites-enabled/stream
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl reload nginx
```

Adjust the microphone volume of the desired audio device.

```
alsamixer
```

Find the name of the audio device for the libcamera command. It ends in ".mono-fallback" for me.

```
pactl list sources | grep -e Name -e Source
```

Create the stream command to push to the nginx server.

```
sudo vim /usr/local/bin/stream.sh
```
```
vim ~/.profile
  stream.sh > /dev/null 2>&1 &

stream.sh

sudo reboot
