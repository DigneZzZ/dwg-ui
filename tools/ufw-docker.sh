#!/bin/bash
# Считываем значение Address из файла
address=$(grep -oP 'Address\s*=\s*\K\S+' ~/ad-wireguard/wg.conf)

# Удаляем все после 3-ой точки в IP-адресе
address=${address%.*}.0/24

# Скачиваем ufw-docker
sudo wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker

# Даем права на выполнение
sudo chmod +x /usr/local/bin/ufw-docker

# Устанавливаем ufw-docker
ufw-docker install

# Разрешаем трафик на порт 51821 для сети 10.10.10.0/24
sudo ufw route allow proto tcp from $address to any port 51821

# Отключаем ufw
sudo ufw disable

# Включаем ufw и пропускаем все запросы подтверждения
sudo ufw --force enable
