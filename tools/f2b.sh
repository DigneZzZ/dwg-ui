#!/bin/bash

# Проверяем, запущен ли скрипт от имени суперпользователя
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт должен быть запущен от имени суперпользователя" 
   exit 1
fi

# Проверяем, установлен ли fail2ban
if ! [ -x "$(command -v fail2ban-client)" ]; then
  echo 'Fail2ban не установлен. Установить fail2ban? [y/n]'
  read -r install_fail2ban

  if [ "$install_fail2ban" = "y" ]; then
    # Устанавливаем fail2ban
    sudo apt-get update
    sudo apt-get install fail2ban -y
  else
    echo 'Выход из скрипта'
    exit 1
  fi
fi

# Получаем порт ssh
ssh_port=$(sudo grep "Port " /etc/ssh/sshd_config | awk '{print $2}')

# Создаем резервную копию конфигурационного файла fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Добавляем стандартные правила в конфигурационный файл fail2ban
sudo tee -a /etc/fail2ban/jail.local > /dev/null <<EOT

[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

EOT

# Открываем конфигурационный файл fail2ban для редактирования 
sudo nano /etc/fail2ban/jail.local

# В конфигурационном файле fail2ban настраиваем правила для защиты сервера
# После всех настроек сохраняем файл и закрываем редактор nano

# Перезапускаем службу fail2ban для применения изменений
sudo systemctl restart fail2ban
