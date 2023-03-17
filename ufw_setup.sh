#!/bin/bash

# Определение цветов
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Определение операционной системы
if grep -q "Ubuntu 22.04" /etc/os-release; then
  echo -e "${GREEN}Установка UFW и NTP на Ubuntu 22.04${NC}"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "Ubuntu 20.04" /etc/os-release; then
  echo -e "${GREEN}Установка UFW и NTP на Ubuntu 20.04${NC}"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "Debian GNU/Linux 11" /etc/os-release; then
  echo -e "${GREEN}Установка UFW и NTP на Debian 11${NC}"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "Debian GNU/Linux 10" /etc/os-release; then
  echo -e "${GREEN}Установка UFW и NTP на Debian 10${NC}"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "CentOS Linux 8" /etc/os-release; then
  echo -e "${GREEN}Установка firewalld и chrony на CentOS 8${NC}"
  sudo dnf install firewalld -y
  sudo systemctl start firewalld
  sudo systemctl enable firewalld
  sudo dnf install chrony -y
  sudo systemctl start chronyd
  sudo systemctl enable chronyd
elif grep -q "CentOS Linux 9" /etc/os-release; then
  echo -e "${GREEN}Установка firewalld и chrony на CentOS 9${NC}"
  sudo dnf install firewalld -y
  sudo systemctl start firewalld
  sudo systemctl enable firewalld
  sudo dnf install chrony -y
  sudo systemctl start chronyd
  sudo systemctl enable chronyd
else
  echo -e "${RED}Не удалось определить операционную систему${NC}"
  exit 1
fi

# Считываем ssh порт из файла sshd_config
ssh_port=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshd_config)

# Запрашиваем подтверждение на использование определенного ssh порта
echo "Обнаружен ssh порт: $ssh_port. Использовать его? (y/n)"
read use_default_port

if [[ "$use_default_port" =~ ^(y|Y) ]]; then
  # Добавляем ssh порт в список разрешенных
  if grep -q "Ubuntu" /etc/os-release; then
    sudo ufw allow $ssh_port/tcp
  else
    sudo firewall-cmd --add-port=$ssh_port/tcp --permanent
    sudo firewall-cmd --reload
  fi
else
  echo "Введите ssh порт:"
  read custom_ssh_port
  # Добавляем кастомный ssh порт в список разрешенных
  if grep -q "Ubuntu" /etc/os-release; then
    sudo ufw allow $custom_ssh_port/tcp
  else
    sudo firewall-cmd --add-port=$custom_ssh_port/tcp --permanent
    sudo firewall-cmd --reload
  fi
fi

# Предлагаем пользователю добавить разрешенные порты для других сервисов
echo "Добавить разрешенные порты для других сервисов? (y/n)"
read add_additional_ports

if [[ "$add_additional_ports" =~ ^(y|Y) ]]; then
  # Список популярных сервисов
  services=("HTTP" "HTTPS" "FTP" "SMTP" "MySQL")

  for service in "${services[@]}"
  do
    echo "Введите порт для сервиса $service:"
    read port
    if grep -q "Ubuntu" /etc/os-release; then
      sudo ufw allow $port/tcp
    else
      sudo firewall-cmd --add-port=$port/tcp --permanent
      sudo firewall-cmd --reload
    fi
  done

  echo -e "${GREEN}Разрешенные порты для сервисов добавлены.${NC}"
else
  echo -e "${GREEN}Настройка firewall завершена.${NC}"
fi

# Включаем firewall
if grep -q "Ubuntu" /etc/os-release; then
  sudo ufw enable
  echo -e "${GREEN}Настройка UFW завершена.${NC}"
else
  sudo systemctl enable firewalld
  echo -e "${GREEN}Настройка firewalld завершена.${NC}"
fi
