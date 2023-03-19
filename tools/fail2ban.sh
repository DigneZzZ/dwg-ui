#!/bin/bash

# Выясняем, какая операционная система установлена на компьютере
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

# Проверяем, установлен ли fail2ban уже
if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 1 ] || [ $(rpm -qa | grep -c fail2ban) -eq 1 ];
then
    printf "{YELLOW}Fail2ban уже установлен.\n{YELLOW}"
else
    printf "{YELLOW}Fail2ban не установлен. Установить? (y/n) {YELLOW}"
    read -r response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        # Устанавливаем fail2ban в зависимости от операционной системы
        case "$OS" in
            ubuntu | debian)
                apt-get update
                apt-get install -y fail2ban
                ;;
            centos)
                yum install -y epel-release
                yum install -y fail2ban
                ;;
            *)
                printf "{RED}Неизвестная операционная система.\n{RED}"
                exit 1
                ;;
        esac
        printf "{GREEN}Установка fail2ban завершена.\n{GREEN}"
    else
        printf "{RED}Установка fail2ban была отменена.\n{RED}"
        exit 1
    fi
fi

# Проверяем, что скрипт запущен от имени sudo
if [[ $(id -u) -ne 0 ]]; then
   printf "{RED}Этот скрипт должен быть запущен от имени sudo.\n{RED}"
   exit 1
fi

# Определяем текущий порт SSH
ssh_port=$(sshd -T | grep "^port " | awk '{print $2}')

# Проверяем, что сервис для мониторинга доступа sshd уже добавлен
if fail2ban-client status sshd | grep -q "Status"; then
    printf "{YELLOW}Сервис для мониторинга доступа к SSH уже добавлен.\n{YELLOW}"
else
    # Предлагаем добавить сервис для мониторинга доступа sshd
    printf "{YELLOW}Хотите добавить сервис для мониторинга доступа к SSH (порт $ssh_port)? (y/n) {YELLOW}"
    read -r response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        # Добавляем сервис для мониторинга доступа sshd
        fail2ban-client -vvv set sshd enabled true
        fail2ban-client -vvv set sshd port $ssh_port
        fail2ban-client -vvv set sshd action iptables-allports[name=SSH, protocol=all]
        fail2ban-client -vvv set sshd logpath /var/log/auth.log
        fail2ban-client -vvv set sshd maxretry 3
        printf "{GREEN}Сервис для мониторинга доступа к SSH был добавлен.\n{GREEN}"
    fi
fi

# Проверяем, что правила для мониторинга доступа к веб-серверу не дублируются
if fail2ban-client status apache-badbots | grep -q "iptables-allports[name=BadBots]"; then
    printf "{YELLOW}Правило для мониторинга доступа к веб-серверу уже добавлено.\n{YELLOW}"
else
    # Предлагаем добавить сервис для мониторинга доступа к веб-серверу
    printf "{YELLOW}Хотите добавить сервис для мониторинга доступа к веб-серверу (порт 80)? (y/n) {YELLOW}"
    read -r response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        # Запрашиваем локальный путь к лог-файлу веб-сервера и настройки
        printf "{YELLOW}Введите локальный путь к лог-файлу веб-сервера (по умолчанию /var/log/apache2/access.log): {YELLOW}"
        read -r logpath
        if [ -z "$logpath" ]; then
            logpath=/var/log/apache2/access.log
        fi
        printf "{YELLOW}Введите время бана в минутах (по умолчанию 30): {YELLOW}"
        read -r bantime
        if [ -z "$bantime" ]; then
            bantime=30
        fi
        printf "{YELLOW}Введите количество попыток (по умолчанию 3): {YELLOW}"
        read -r maxretry
        if [ -z "$maxretry" ]; then
            maxretry=3
        fi

        # Проверяем, что сервис для мониторинга доступа к веб-серверу еще не добавлен
        if ! fail2ban-client status apache-badbots | grep -q "Status"; then
            # Добавляем сервис для мониторинга доступа к веб-серверу
            fail2ban-client -vvv set apache-badbots enabled true
            fail2ban-client -vvv set apache-badbots port 80
            fail2ban-client -vvv set apache-badbots logpath "$logpath"
            fail2ban-client -vvv set apache-badbots bantime $bantime
            fail2ban-client -vvv set apache-badbots maxretry $maxretry
            fail2ban-client -vvv set apache-badbots filter /etc/fail2ban/filter.d/apache-badbots.conf
            fail2ban-client -vvv set apache-badbots action iptables-allports[name=BadBots]
            printf "{GREEN}Сервис для мониторинга доступа к веб-серверу был добавлен.\n{GREEN}"
        else
            printf "{YELLOW}Сервис для мониторинга доступа к веб-серверу уже добавлен.\n{YELLOW}"
        fi
    fi
fi

# Обновляем настройки и правила fail2ban
printf "{YELLOW}Хотите обновить настройки и правила fail2ban? (y/n) {YELLOW}"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # Обновляем настройки и правила fail2ban
    fail2ban-client reload
    printf "{GREEN}Настройки и правила fail2ban были обновлены.\n{GREEN}"
fi

# Перезапускаем сервис fail2ban в зависимости от операционной системы
if [[ $(fail2ban-client ping) == "pong" ]]; then
    case "$OS" in
        ubuntu | debian)
            service fail2ban restart
            ;;
        centos)
            systemctl restart fail2ban
            ;;
    esac
    printf "{GREEN}Служба fail2ban была перезапущена.\n{GREEN}"
fi

printf "{GREEN}Установка fail2ban завершена.\n{GREEN}"
