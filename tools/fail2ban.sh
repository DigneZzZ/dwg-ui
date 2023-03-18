#!/bin/bash

# Определяем цвета для подсветки текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Проверяем, запущен ли скрипт от имени пользователя sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Этот скрипт должен быть запущен от имени пользователя с правами sudo.${NC}" 2>&1
    echo -e "${YELLOW}Вы хотите запустить его с sudo?${NC}" 2>&1
    read -p "Введите 'y' для запуска с sudo или 'n' для выхода: " answer
    case $answer in
        y|Y )
            sudo "$0" "$@"
            exit $?
            ;;
        * )
            echo -e "${YELLOW}Установка fail2ban отменена.${NC}" 2>&1
            exit 1
            ;;
    esac
fi

# Проверяем, установлен ли fail2ban
if which fail2ban >/dev/null; then
    echo -e "${YELLOW}Fail2ban уже установлен на этой системе.${NC}"
    exit 1
fi

# Запрашиваем подтверждение начала установки
printf "${YELLOW}Вы уверены, что хотите установить fail2ban на эту систему? (y/n) ${NC}"
read answer
case $answer in
    y|Y )
        # Обновляем список пакетов и устанавливаем fail2ban
        if [[ $(lsb_release -rs) == "20.04" || $(lsb_release -rs) == "22.04" ]]; then
            sudo apt-get update
            sudo apt-get install -y fail2ban
        elif [[ $(cat /etc/os-release | grep "^ID=" | cut -d= -f2) == "debian" ]]; then
            if [[ $(cat /etc/os-release | grep "^VERSION_ID=" | cut -d= -f2) == "10" ]]; then
                su -c "apt-get update && apt-get install -y fail2ban"
            elif [[ $(cat /etc/os-release | grep "^VERSION_ID=" | cut -d= -f2) == "11" ]]; then
                su -c "apt-get update && apt-get install -y fail2ban"
            fi
        elif [[ $(cat /etc/os-release | grep "^ID=" | cut -d= -f2) == "centos" ]]; then
            if [[ $(cat /etc/os-release | grep "^VERSION_ID=" | cut -d= -f2) == "7" ]]; then
                sudo yum install -y epel-release
                sudo yum install -y fail2ban
            elif [[ $(cat /etc/os-release | grep "^VERSION_ID=" | cut -d= -f2) == "8" ]]; then
                sudo dnf install -y epel-release
                sudo dnf install -y fail2ban
            elif [[ $(cat /etc/os-release | grep "^VERSION_ID=" | cut -d= -f2) == "9" ]]; then
                sudo dnf install -y epel-release
                sudo dnf install -y fail2ban
            fi
        fi
        # Проверяем, была ли установка успешной
        if which fail2ban >/dev/null; then
            echo -e "${GREEN}Fail2ban успешно установлен на эту систему.${NC}"
        else
            echo -e "${RED}Возникла ошибка при установке fail2ban.${NC}"
            exit 1
        fi
        ;;
    n|N )
        echo -e "${YELLOW}Установка fail2ban отменена.${NC}"
        exit 1
        ;;
    * )
        echo -e "${RED}Неверный ввод. Установка fail2ban отменена.${NC}"
        exit 1
        ;;
esac

# Определяем текущий порт SSH
ssh_port=$(grep "^Port " /etc/ssh/sshd_config | awk '{print $2}')

# Предлагаем пользователю добавить сервис для мониторинга доступа к SSH
# Предлагаем пользователю добавить сервис для мониторинга доступа к SSH
printf "${YELLOW}Хотите добавить сервис для мониторинга доступа к SSH-серверу? (y/n) ${NC}"
read answer
case $answer in
    y|Y )
        # Создаем файл конфигурации для сервиса fail2ban-ssh
        sudo tee /etc/fail2ban/jail.d/sshd.conf > /dev/null <<EOF
[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7776000
EOF

        # Перезапускаем fail2ban
        sudo service fail2ban restart

        # Проверяем, был ли сервис успешно добавлен
        if [[ $(sudo fail2ban-client status sshd | grep "Status:") == "Status:   enabled" ]]; then
            echo -e "${GREEN}Сервис для мониторинга доступа к SSH-серверу успешно добавлен в fail2ban.${NC}"
        else
            echo -e "${RED}Возникла ошибка при добавлении сервиса для мониторинга доступа к SSH-серверу в fail2ban.${NC}"
        fi
        ;;
    n|N )
        echo -e "${YELLOW}Вы отказались от добавления сервиса для мониторинга доступа к SSH-серверу.${NC}"
        ;;
    * )
        echo -e "${RED}Неверный ввод. Вы отказались от добавления сервиса для мониторинга доступа к SSH-серверу.${NC}"
        ;;
esac

# Предлагаем пользователю добавить настройки для веб-сервера Apache
printf "${YELLOW}Хотите добавить настройки для веб-сервера Apache? (y/n) ${NC}"
read answer
case $answer in
    y|Y )
        # Создаем файл конфигурации для сервиса fail2ban-apache
        sudo tee /etc/fail2ban/jail.d/apache.conf > /dev/null <<EOF
[apache]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache*/*error.log
maxretry = 3
bantime = 7776000
EOF

        # Перезапускаем fail2ban
        sudo service fail2ban restart

        # Проверяем, были ли настройки Apache успешно добавлены
        if [[ $(sudo fail2ban-client status apache | grep "Status:") == "Status:   enabled" ]]; then
            echo -e "${GREEN}Настройки для веб-сервера Apache успешно добавлены.${NC}"
        else
            echo -e "${RED}Возникла ошибка при добавлении настроек для веб-сервера Apache.${NC}"
        fi
        ;;
    n|N )
        echo -e "${YELLOW}Вы отказались от добавления настроек для веб-сервера Apache.${NC}"
        ;;
    * )
        echo -e "${RED}Неверный ввод. Вы отказались от добавления настроек для веб-сервера Apache.${NC}"
        ;;
esac

# Предлагаем пользователю добавить настройки для веб-сервера Nginx
printf "${YELLOW}Хотите добавить настройки для веб-сервера Nginx? (y/n) ${NC}"
read answer
case $answer in
    y|Y )
        # Создаем файл конфигурации для сервиса fail2ban-nginx
        sudo tee /etc/fail2ban/jail.d/nginx.conf > /dev/null <<EOF
[nginx]
enabled = true
port = http,https
filter = nginx-auth
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 7776000
EOF

        # Перезапускаем fail2ban
        sudo service fail2ban restart

        # Проверяем, были ли настройки Nginx успешно добавлены
        if [[ $(sudo fail2ban-client status nginx | grep "Status:") == "Status:   enabled" ]]; then
            echo -e "${GREEN}Настройки для веб-сервера Nginx успешно добавлены.${NC}"
        else
            echo -e "${RED}Возникла ошибка при добавлении настроек для веб-сервера Nginx.${NC}"
        fi
        ;;
    n|N )
        echo -e "${YELLOW}Вы отказались от добавления настроек для веб-сервера Nginx.${NC}"
        ;;
    * )
        echo -e "${RED}Неверный ввод. Вы отказались от добавления настроек для веб-сервера Nginx.${NC}"
        ;;
esac

# Предлагаем пользователю добавить мониторинг портов FTP и SMTP
printf "${YELLOW}Хотите добавить мониторинг портов FTP и SMTP? (y/n) ${NC}"
read answer
case $answer in
    y|Y )
        # Создаем файл конфигурации для сервиса fail2ban-ftp
        sudo tee /etc/fail2ban/jail.d/ftp.conf > /dev/null <<EOF
[ftp]
enabled = true
port = ftp,ftp-data,ftps,ftps-data
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 3
bantime = 7776000
EOF

        # Создаем файл конфигурации для сервиса fail2ban-smtp
        sudo tee /etc/fail2ban/jail.d/smtp.conf > /dev/null <<EOF
[smtp]
enabled = true
port = smtp,ssmtp
filter = postfix
logpath = /var/log/mail.log
maxretry = 3
bantime = 7776000
EOF

        # Перезапускаем fail2ban
        sudo service fail2ban restart

        # Проверяем, был ли мониторинг портов FTP и SMTP успешно добавлен
        if [[ $(sudo fail2ban-client status ftp | grep "Status:") == "Status:   enabled" && $(sudo fail2ban-client status smtp | grep "Status:") == "Status:   enabled" ]]; then
            echo -e "${GREEN}Мониторинг портов FTP и SMTP успешно добавлен в fail2ban.${NC}"
        else
            echo -e "${RED}Возникла ошибка при добавлении мониторинга портов FTP и SMTP в fail2ban.${NC}"
        fi
        ;;
    n|N )
        echo -e "${YELLOW}Вы отказались от добавления мониторинга портов FTP и SMTP в fail2ban.${NC}"
        ;;
    * )
        echo -e "${RED}Неверный ввод. Вы отказались от добавления мониторинга портов FTP и SMTP в fail2ban.${NC}"
        ;;
esac

echo -e "${GREEN}Установка и настройка fail2ban завершена.${NC}"

    echo -e "${GREEN}Заходите на мой форум: https://openode.ru${NC}"
