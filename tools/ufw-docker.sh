#!/bin/bash

sudo wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
sudo chmod +x /usr/local/bin/ufw-docker
ufw-docker install
sudo systemctl restart ufw
ufw route allow proto tcp from 10.10.10.0/24 to any port 51821
ufw disable
ufw enable -y
sudo systemctl restart ufw
