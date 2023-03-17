#!/bin/bash

# Определение операционной системы
if grep -q "Ubuntu 22.04" /etc/os-release; then
  echo "Установка UFW и NTP на Ubuntu 22.04"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "Ubuntu 20.04" /etc/os-release; then
  echo "Установка UFW и NTP на Ubuntu 20.04"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "Debian GNU/Linux 11" /etc/os-release; then
  echo "Установка UFW и NTP на Debian 11"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "Debian GNU/Linux 10" /etc/os-release; then
  echo "Установка UFW и NTP на Debian 10"
  sudo apt update
  sudo apt install ufw -y
  sudo apt install ntp -y
elif grep -q "CentOS Linux 8" /etc/os-release; then
  echo "Установка firewalld и chrony на CentOS 8"
  sudo dnf install firewalld -y
  sudo systemctl start firewalld
  sudo systemctl enable firewalld
  sudo dnf install chrony -y
  sudo systemctl start chronyd
  sudo systemctl enable chronyd
elif grep -q "CentOS Linux 9" /etc/os-release; then
  echo "Установка firewalld и chrony на CentOS 9"
  sudo dnf install firewalld -y
  sudo systemctl start firewalld
  sudo systemctl enable firewalld
  sudo dnf install chrony -y
  sudo systemctl start chronyd
  sudo systemctl enable chronyd
else
  echo "Не удалось определить операционную систему"
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

# Включаем firewall
if grep -q "Ubuntu" /etc/os-release; then
  sudo ufw enable
else
  sudo systemctl enable firewalld
fi
