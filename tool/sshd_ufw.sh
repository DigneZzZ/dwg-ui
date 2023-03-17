#!/bin/bash

# Цвета текста
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# РАЗДЕЛ ИЗМЕНЕНИЯ ПОРТА SSH для подключения пользователя
# Проверяем наличие файла конфигурации SSH
if [ ! -f /etc/ssh/sshd_config ]; then
    echo -e "${RED}Ошибка: файл конфигурации SSH (/etc/ssh/sshd_config) не найден.${NC}"
    exit 1
fi

# Запрос текущего порта SSH
current_port=$(grep -oP "(?<=Port ).+" /etc/ssh/sshd_config)

# Если порт не указан в конфигурационном файле, то присваиваем ему значение по умолчанию
if [ -z "$current_port" ]; then
    current_port=22
fi

# Определяем, хочет ли пользователь изменить порт
read -p "Текущий порт SSH: $current_port. Хотите изменить порт? (y/n): " change_port

if [ "$change_port" == "y" ]; then
    # Запрос нового порта
    read -p "Введите новый порт (допустимый диапазон: 1024-65535):$'\e[0m' " new_port

    # Проверка, что введено число
    if ! [[ "$new_port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Ошибка: порт должен быть числом.${NC}"
        exit 1
    fi

    # Проверка, что порт в допустимом диапазоне
    if [ "$new_port" -lt 1024 ] || [ "$new_port" -gt 65535 ]; then
        echo -e "${RED}Ошибка: порт должен быть в диапазоне от 1024 до 65535.${NC}"
        exit 1
    fi

    # Проверка, что порт не используется другим сервисом
    if ss -tnlp | grep -q ":$new_port "; then
        echo -e "${RED}Ошибка: порт $new_port уже используется другим сервисом.${NC}"
        exit 1
    fi

    # Изменяем порт
    if grep -q "^#*Port $current_port$" /etc/ssh/sshd_config; then
        sed -i "s/^#*Port $current_port$/Port $new_port/g" /etc/ssh/sshd_config
    else
        echo "Port $new_port" >> /etc/ssh/sshd_config
    fi

    systemctl restart sshd

    echo -e "${GREEN}Порт SSH успешно изменен на $new_port.${NC}"
elif [ "$change_port" == "n" ]; then
    echo -e "${GREEN}Порт SSH останется неизменным.${NC}"
else
    echo -e "${RED}Неверный ответ. Пожалуйста, введите 'y' или 'n'.${NC}"
    exit 1
fi


# Проверка наличия установленного ufw
if [ -x "$(command -v ufw)" ]; then
  echo "UFW уже установлен."
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
  read -p $'\e[1;33m'"UFW не установлен, хотите установить его? (y/n): "'\e[0m' install_ufw
  if [ "$install_ufw" = "y" ]; then
    # Установка ufw
    sudo apt-get update
    sudo apt-get install ufw -y

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
    sudo ufw enable -y
    echo -e "${GREEN}UFW был успешно установлен и настроен на открытие используемых портов.${NC}"
  else
    echo "Установка завершена без изменений."
  fi
fi
