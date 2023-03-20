#!/bin/bash

# Скачиваем ufw-docker
sudo wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker

# Даем права на выполнение
sudo chmod +x /usr/local/bin/ufw-docker

# Устанавливаем ufw-docker
ufw-docker install

# Разрешаем трафик на порт 51821 для сети 10.10.10.0/24
sudo ufw route allow proto tcp from 10.10.10.0/24 to any port 51821

# Отключаем ufw
sudo ufw disable

# Включаем ufw и пропускаем все запросы подтверждения
sudo ufw --force enable
