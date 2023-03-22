#!/bin/bash
export LC_CTYPE=en_US.UTF-8
# переменные для изменения цвета текста
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
NC='\e[0m'

# Считываем значение Address из файла
#  printf "${GREEN}Получили значение адреса${NC}\n"
#address=$(grep -oP 'Address\s*=\s*\K\S+' ~/ad-wireguard/wg.conf)

# Удаляем все после 3-ой точки в IP-адресе

#address=${address%.*}.0/24
#  printf "${GREEN}Исправили адрес${NC}\n"
  
# Скачиваем ufw-docker
sudo wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
  printf "${GREEN}Скачали ufw-docker${NC}\n"
  
# Даем права на выполнение
sudo chmod +x /usr/local/bin/ufw-docker
  printf "${GREEN}Дали права на исполнение${NC}\n"
# Устанавливаем ufw-docker
ufw-docker install
  printf "${GREEN}Ставим ufw-docker${NC}\n"
# Разрешаем трафик на порт 51821 для сети 10.10.10.0/24
sudo ufw route allow proto tcp from 10.10.10.0/24 to any port 51821
  printf "${GREEN}Разрешаем трафик на порт 51821 только для внутренней сети докера${NC}\n"
# Отключаем ufw
sudo ufw disable
  printf "${GREEN}Выключили...${NC}\n"
# Включаем ufw и пропускаем все запросы подтверждения
sudo ufw --force enable

  printf "${GREEN}Включили....${NC}\n"
  printf "${YELLOW}***********************${NC}\n"
    printf "${RED}Теперь веб-интерфейс будет доступен только адресу (ТОЛЬКО ПРИ ПОДКЛЮЧЕНИИ ЧЕРЕЗ WIREGUARD!):${NC}\n"
      printf "${BLUE}http://10.2.0.3:51821${NC}\n"
        printf "${YELLOW}***********************${NC}\n"
