#!/bin/bash

# функция для установки fail2ban
install_fail2ban() {
    # установка fail2ban
    sudo apt-get update
    sudo apt-get install -y fail2ban

    # создание резервной копии конфигурационного файла
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # настройка конфигурационного файла
    sudo sed -i 's/^bantime  = 600/bantime  = 3600/' /etc/fail2ban/jail.local
    sudo sed -i 's/^maxretry = 3/maxretry = 5/' /etc/fail2ban/jail.local
    sudo sed -i 's/^destemail = root@localhost/destemail = admin@example.com/' /etc/fail2ban/jail.local
    sudo sed -i 's/^action = %(action_)s/action = %(action_mwl)s/' /etc/fail2ban/jail.local
}

# проверка установки fail2ban
if command -v fail2ban-client > /dev/null; then
    fail2ban_installed=true
else
    fail2ban_installed=false
fi

# вывод приветственного сообщения
echo "Добро пожаловать в скрипт установки fail2ban!"

# запрос у пользователя о установке fail2ban
read -p "Хотите установить fail2ban? (y/n): " install_fail2ban_response

# обработка ответа пользователя
if [[ "$install_fail2ban_response" =~ ^[Yy]$ ]]; then
    # установка fail2ban, если не установлен
    if [ "$fail2ban_installed" = false ]; then
        install_fail2ban
        echo "fail2ban установлен и настроен!"
    else
        echo "fail2ban уже установлен"
    fi
else
    echo "Установка fail2ban пропущена."
fi

echo "Спасибо за использование скрипта установки fail2ban!"
