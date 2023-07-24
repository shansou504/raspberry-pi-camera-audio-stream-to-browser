# Raspberry Pi 3/4 Camera Module and USB Microphone HLS Stream to Web Browser

Flash a microSD card with RaspiOS-Lite 64-bit using [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

Ssh into your pi once it's up and running on your network. Update the system, install the required applications, set a static IP address and reboot.

```
sudo su
```
```
apt update
apt upgrade -y
apt install -y libcamera-apps npm nginx libnginx-mod-rtmp git vim
```

Set a static IP address, following the example provided in ___/etc/dhcpcd.conf___, for your local network.

```
vim /etc/dhcpcd.conf
```

Reboot

```
reboot
```

Ssh back into the pi and set a default alsa input.

```
sudo su
```
```
arecord -l
```

Use the output of the above command to set the __<NAME>__ in the ___/etc/asound.conf___ file that will need to be created.

```
vim /etc/asound.conf
```

```
pcm.!default {
  type hw
  card "<NAME>"
}

ctl.!default {
  type hw
  card "<NAME>"
}
```
If you are using a stand-alone microphone you may need to use the ___aplay -l___ to find the name of a desired audio output and adjust the file to this format. Which output you pick does not matter unless you plan to use the speaker to play music or white noise.

```
pcm.!default {
  type asym
  playback.pcm "hw:<NAME-OF-OUTPUT>"
  capture.pcm "hw:<NAME-OF-INPUT>"
}

ctl.!default {
  type hw
  card "<NAME-OF-OUTPUT>"
}
```

Adjust the microphone volume of the desired audio device.

```
alsamixer
```

Create the directory for the web server

```
mkdir -p /var/www/stream/hls
cd /var/www/stream/
```

Install [video.js](https://github.com/videojs/video.js) in your web directory. 

```
npm install video.js
```

Clone this repository and copy its contents into your web directory.

```
cd /opt/
git clone https://github.com/shansou504/raspberry-pi-camera-audio-stream-to-browser.git
cd raspberry-pi-camera-audio-stream-to-browser
cp src/var/www/stream/* /var/www/stream/
```

Make a backup of the default ___/etc/nginx/nginx.conf___

```
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
```

Update the nginx.conf to include the rtmp application server.

```
vim /etc/nginx/nginx.conf
```

Add the rtmp server block with the src and hls applications.
Reference the [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module) documentation.

```
rtmp {
	server {
		listen 1935;

		application src {
			live on;
			exec_static /usr/bin/libcamera-vid --timeout 0 --inline --nopreview --awbgains 1,1 --codec libav --libav-audio --audio-source alsa --audio-channels 1 --libav-format flv --output rtmp://localhost:1935/hls/stream;
		}

		application hls {
			live on;
			hls on;
			hls_path /var/www/stream/hls;
		}
	}
}
```

Create the new stream site in ___/etc/nginx/sites-available___.

```
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/stream
```

Change the web root from ___/var/www/html___ to ___/var/www/stream___

```
vim /etc/nginx/sites-available/stream
```

Create a symbolic link to enable the _stream_ site and then disable the _default_ site.

```
ln -s /etc/nginx/sites-available/stream /etc/nginx/sites-enabled/stream
rm /etc/nginx/sites-enabled/default
```

Change ownership and add the ___www-data___ user to the ___audio___ and ___video___ groups so the webapp can use the microphone and camera.

```
chown www-data:www-data -R /var/www/stream
adduser www-data audio
adduser www-data video
```

Enable and restart nginx.

```
systemctl enable nginx
systemctl restart nginx
```

Point a web browser from any device on the network to the local IP address of the pi. There is about a 20-30 second delay.

```
reboot
```

Confirm everything is still working.
## Allow Private Access to Your Camera from Anywhere

Set up a WireGuard VPN and port forwarding on your router.
