#!/bin/bash
export LC_CTYPE=en_US.UTF-8
# переменные для изменения цвета текста
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
NC='\e[0m'
BG_RED='\e[41m'
# Проверяем установлен ли UFW
if ! command -v ufw &> /dev/null
then
    echo "UFW не установлен. Выходим..."
    exit
fi

echo "UFW установлен. Продолжаем работу..."

# Проверяем наличие клиентов в файле ~/ad-wireguard/wg0.conf
if grep -q "^\[Peer\]" ~/ad-wireguard/wg0.conf; then
  printf "${GREEN}В файле ~/ad-wireguard/wg0.conf есть клиенты. Можно продолжать работу.${NC}\n"
else
  printf "${BG_RED}В файле ~/ad-wireguard/wg0.conf нет клиентов. Нельзя продолжать работу.${NC}\n"
  printf "${BG_RED}Если бы вы сейчас установили ufw-docker, вы не смогли бы подключиться к WireGuard!${NC}\n"
  printf "${BG_RED}Создайте Peer'a и повторите заново!${NC}\n"
  printf "${BG_RED}Если скрипт отработал не правильно, напишите мне на форуме: http://openode.ru${NC}\n"
  exit
fi
  
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
    printf "${RED}Теперь веб-интерфейс будет доступен только по адресу (ТОЛЬКО ПРИ ПОДКЛЮЧЕНИИ ЧЕРЕЗ WIREGUARD!):${NC}\n"
      printf "${BLUE}http://10.2.0.3:51821${NC}\n"
        printf "${YELLOW}***********************${NC}\n"
