#!/bin/bash

# Цвета текста
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# функция для установки fail2ban
install_fail2ban() {
    # установка fail2ban
    sudo apt-get update
    sudo apt-get install -y fail2ban

    # создание резервной копии конфигурационного файла
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # настройка конфигурационного файла
    sudo sed -i 's/^bantime  = 600/bantime  = 7776000/' /etc/fail2ban/jail.local
    sudo sed -i 's/^maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
    sudo sed -i 's/^destemail = root@localhost/destemail = admin@example.com/' /etc/fail2ban/jail.local
    sudo sed -i 's/^action = %(action_)s/action = %(action_mwl)s/' /etc/fail2ban/jail.local

    # добавление сервиса для мониторинга ssh
    sudo echo "[ssh]" >> /etc/fail2ban/jail.local
    sudo echo "enabled = true" >> /etc/fail2ban/jail.local
    sudo echo "port = ssh" >> /etc/fail2ban/jail.local
    sudo echo "filter = sshd" >> /etc/fail2ban/jail.local
    sudo echo "logpath = /var/log/auth.log" >> /etc/fail2ban/jail.local
    sudo echo "maxretry = 3" >> /etc/fail2ban/jail.local
}

# проверка установки fail2ban
if command -v fail2ban-client > /dev/null; then
    fail2ban_installed=true
else
    fail2ban_installed=false
fi

# вывод приветственного сообщения
echo -e "${YELLOW}Добро пожаловать в скрипт установки fail2ban!${NC}"

# запрос у пользователя о установке fail2ban
read -p $'\e[1;33m'"Хотите установить fail2ban? (y/n): "'\e[0m' install_fail2ban_response

# обработка ответа пользователя
if [[ "$install_fail2ban_response" =~ ^[Yy]$ ]]; then
    # установка fail2ban, если не установлен
    if [ "$fail2ban_installed" = false ]; then
        install_fail2ban
        echo -e "${GREEN}fail2ban установлен и настроен!${NC}"
    else
        echo "fail2ban уже установлен"
    fi
else
    echo "Установка fail2ban пропущена."
fi

echo -e "${YELLOW}Спасибо за использование скрипта установки fail2ban!${NC}"
