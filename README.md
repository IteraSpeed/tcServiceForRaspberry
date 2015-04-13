# tcServiceForRaspberry

The code and configuration files in this repository enable a raspberry pi to open a wlan which can be throttled by REST API calls.
We use raspberry pis with traffic shaper to measure the performance of web applications with mobile devices and [WebPagetest](http://www.webpagetest.org).

# Installation

As WLAN adapter we use an "Edimax EW-7811Un".

## Installation Raspbian

1. Download Raspbian from [here](http://www.raspberrypi.org/downloads/)
2. Install Raspbian like described [here](http://www.raspberrypi.org/documentation/installation/installing-images/README.md) on SD card.

## Configure User

1. Add a user _trafficshaper_

        sudo useradd trafficshaper

2. Grant sudo rights by adding to _/etc/sudoers_

        trafficshaper ALL=(ALL) NOPASSWD: ALL

## Install Python module

1. Download module

        cd ~
        wget http://webpy.org/static/web.py-0.37.tar.gz

2. Install

        tar -zxvf web.py-0.37.tar.gz
        cd web.py-0.37
        sudo python setup.py install

## Install and configure hostapd

1. Install hostapd

        sudo apt-get install hostapd

2. Replace binary _/usr/sbin/hostapd_ with _hostapd_ file from this repository (usr/sbin/hostapd)

3. Replace line

        #DAEMON_CONF
in file _/etc/Default/hostapd_ with

        DAEMON_CONF="/etc/hostapd/hostapd.conf"

4. Config file _/etc/hostpad/hostapd.conf_ should contain the folllowing:

        interface=wlan0
        driver=rtl871xdrv
        ssid=[SSID-of-your-wlan]
        hw_mode=g
        channel=6
        macaddr_acl=0
        auth_algs=1
        ignore_broadcast_ssid=0
        wpa=2
        wpa_passphrase=[ssid-pasword]
        wpa_key_mgmt=WPA-PSK
        wpa_pairwise=TKIP
        rsn_pairwise=CCMP
Adapt "ssid" and "wpa_passphrase" if necessary.

Service hostapd should be started with each reboot now.

## Install dnsmasq

1. Install dnsmasq

        sudo apt-get install dnsmasq

2. Copy files _etc/resolv.conf_ und _etc/dnsmasq.conf_ of this repository to _/etc/_-Folder

3. Restart service

        sudo service dnsmasq restart

Service dnsmasq should be started with each reboot now.

## Install traffic shaping REST API

1. Copy the following files from this repository to _/opt/trafficshaper_

        rest.py
        trafficshaper_init.sh
        configure_traffic_control.sh

2. Add trafficshaper scripts to autostart
    1. Copy template _trafficshaper_ from this repository to _/etc/init.d/_
    2. Make scripts executable (chmod +x)

            chmod +x /opt/trafficshaper/*.*

    3. Add scripts to run-level

            update-rc.d trafficshaper defaults

# Configuration and usage

## Configure default throttling

With each start of raspberry pi throttling starts with default values for the following parameters:

* **bwdown** download bandwidth (kbit/s)
* **bwup** upload bandwidth (kbit/s)
* **latencydown** latency delay download (ms)
* **latencyup** latency delay upload (ms)
* **plrdown** Packet loss rate download
* **plrup** Packet loss rate upload

One can change default throttling in last three lines of file _/opt/trafficshaper/rest.py_

## Set throttling via HTTP GET request

Parameters of REST API call get explained if you call

    http://<IP adress-of-raspberry-pi>:8080/

Example call:

    http://localhost:8080/set_shaping?bwdown=4000&bwup=2000&latencydown=40&latencyup=50&plrdown=0.0&plrup=1

This call would set...

* a bandwidth of 4.000 kBit/s downstream, 
* a bandwidth of 2.000 kBit/s upstream,
* 40ms latency delay for downstream,
* 50ms latency delay for upstream,
* 0,0% packet loss rate downstream and
* 1,0% packet loss rate upstream.

So round trip time of single tcp packets would get extended by 90ms. One percent of packets get lost on this round trip.