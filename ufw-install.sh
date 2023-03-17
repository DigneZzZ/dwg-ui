#!/bin/bash

# Цвета текста
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверка наличия установленного ufw и net-tools
if [ -x "$(command -v ufw)" ] && [ "$(dpkg-query -W -f='${Status}' net-tools 2>/dev/null | grep -c "ok installed")" -eq 1 ]; then
  echo "UFW и net-tools уже установлены."
  read -p $'\e[1;33m'"Хотите обновить список портов на основе используемых сервисов? (y/n): "'\e[0m' update_ports
  if [ "$update_ports" = "y" ]; then
    # Получить список открытых портов с помощью netstat и фильтрацией через awk и sort
    ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

    # Очистка текущих правил и настройка новых правил
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    for port in $ports
    do
      sudo ufw allow $port/tcp
    done

    # Сохранение правил и включение ufw
    sudo ufw enable
    echo -e "${GREEN}Список портов был успешно обновлен.${NC}"
  else
    echo "Установка завершена без изменений."
  fi
else
  read -p $'\e[1;33m'"UFW или net-tools не установлены, хотите установить их? (y/n): "'\e[0m' install_ufw
  if [ "$install_ufw" = "y" ]; then
    # Установка ufw и net-tools
    sudo apt-get update
    sudo apt-get install ufw net-tools

    # Получить список открытых портов с помощью netstat и фильтрацией через awk и sort
    ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

    # Очистка текущих правил и настройка новых правил
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    for port in $ports
    do
      sudo ufw allow $port/tcp
    done

    # Сохранение правил и включение ufw
    sudo ufw enable
    echo -e "${GREEN}UFW и net-tools были успешно установлены и настроены на открытие используемых портов.${NC}"
  else
    echo "Установка завершена без изменений."
  fi
fi
