# Raspberry Pi 3/4 Camera Module and USB Microphone HLS Stream to Web Browser

Flash a microSD card with RaspiOS-Lite using [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

Set up a DHCP reservation or static IP address on your router. Connect to your pi via ssh. This will
make the setup significantly easier.

Setup auto login to console through raspi-config so the stream starts automatically.

```
sudo raspi-config
```

Update the system, install the required applications, and reboot.

```
sudo apt update && sudo apt upgrade -y && sudo apt install \
libcamera-apps npm nginx libnginx-mod-rtmp pulseaudio git \
vim -y && sudo reboot
```

Create the directory for the web server. __Ssh back into the pi__.

```
sudo mkdir -p /var/www/stream/hls
sudo chown $USER:$USER -R /var/www/stream
```

Install [video.js](https://github.com/videojs/video.js) in your web directory. 

```
cd /var/www/stream/
npm install video.js
```

Clone this repository and copy the html page and stylesheet into your web directory.

```
cd
git clone https://github.com/shansou504/raspberry-pi-camera-audio-stream-to-browser.git
cd raspberry-pi-camera-audio-stream-to-browser
cp src/var/www/stream/* /var/www/stream/
```

Make a backup of the default nginx.conf

```
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
```

Update the nginx.conf to include the rtmp application server.
Change the _user_ from _www-data_ to the current user.

```
sudo vim /etc/nginx/nginx.conf
```

Add the rtmp server block with the hls application (above the html block).
Reference the [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module) documentation.

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

Create the new stream site in /etc/nginx/sites-available.

```
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/stream
```

Change the web root from _/var/www/html_ to _/var/www/stream_

```
sudo vim /etc/nginx/sites-available/stream
```

Create a symbolic link to enable the _stream_ site and then disable the _default_ site.

```
sudo ln -s /etc/nginx/sites-available/stream /etc/nginx/sites-enabled/stream
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl reload nginx
```

Adjust the microphone volume of the desired audio device.

```
alsamixer
```

Copy the stream command to a directory within $PATH.

```
sudo cp src/usr/local/bin/stream.sh /usr/local/bin/stream.sh
```

Find the name of the audio device for the stream command.
Reference Raspberry Pi's [camera documentation](https://www.raspberrypi.com/documentation/computers/camera_software.html)

```
pactl list sources | grep -e Name -e Source
```

Replace the _--audio-device_ with the results from pactl.

```
sudo vim /usr/local/bin/stream.sh
```

Add the stream command at the bottom of your .profile so runs on login (or at boot since we set up auto login to console).

```
echo -e "\nstream.sh > /dev/null 2>&1 &" >> ~/.profile
```

To test the stream, run the command below and point a web browser from any device on the network to the local IP address of the pi. There is about a 20-30 second delay.

```
stream.sh
```

If all goes well, reboot and make sure everything is running smoothly. 

## Allow Private Access to Your Camera from Anywhere

Set up [pivpn](https://pivpn.io/) and port forwarding on your router.
