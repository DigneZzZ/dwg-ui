#!/bin/bash
export LC_CTYPE=en_US.UTF-8
# переменные для изменения цвета текста
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
NC='\e[0m'


# Проверяем, установлен ли пакет sudo
if ! command -v sudo &> /dev/null; then
    # Проверяем версию Debian
    if [[ $(lsb_release -rs) == "10" || $(lsb_release -rs) == "11" ]]; then
        printf "${YELLOW}Мы определили что у вас Debian, для скрипта нужен пакет SUDO, он будет установлен.${NC}\n"
        # Устанавливаем пакет sudo
        apt-get update
        apt-get install sudo -y
    printf "${GREEN}***********${NC}\n"
    printf "${GREEN}Sudo установлен. Продолжаем установку.${NC}\n"
    printf "${GREEN}***********${NC}\n"
    else
        # Продолжаем работу скрипта без завершения
        exit 0
    fi
else
    printf "${GREEN}SUDO уже установлен. Пропускаем установку.${NC}\n"
fi

# проверка на запуск от суперпользователя
if [[ $EUID -ne 0 ]]; then
   printf "${RED}Этот скрипт должен быть запущен с правами суперпользователя${NC}\n" 
   exit 1
fi

# проверка на наличие установленного ufw
if dpkg --get-selections | grep -q "^ufw[[:space:]]*install$" >/dev/null; then
    printf "${GREEN}UFW уже установлен. Пропускаем установку.${NC}\n"
else
    # установка ufw
    sudo apt update
    sudo apt install ufw -y
fi
 # Считываем ssh порт из файла sshd_config
SSH_PORT=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshd_config)

# Проверяем, существует ли уже правило для порта SSH
if sudo ufw status | grep -q $SSH_PORT/tcp; then
    printf "${GREEN}Правило для SSH-порта уже существует. Пропускаем добавление.${NC}\n"
else
    # настройка правил фаервола
    sudo ufw default deny incoming # отклонять все входящие соединения
    sudo ufw default allow outgoing # разрешать все исходящие соединения
    sudo ufw allow $SSH_PORT/tcp # разрешать ssh-соединения
    printf "${GREEN}Автоматически был считан из файла sshd_config и добавлен в исключения порт SSH : $SSH_PORT/tcp ${NC}\n"
fi
# вывод доступных сервисов
printf "${YELLOW}Выберите сервисы, к которым нужно открыть доступ:${NC}\n"
printf "${YELLOW}1. HTTP (порт 80)\n2. HTTPS (порт 443)\n3. MySQL (порт 3306)\n4. PostgreSQL (порт 5432)\n5. FTP (порты 20 и 21)\n6. SMTP (порты 25 и 587)\n7. DNS (порты 53/tcp и 53/udp)\n8. NFS (порты 111 и 2049)\n9. Samba (порты 139 и 445)\n10. Все вышеперечисленные сервисы${NC}\n\n"

# запрос выбора сервисов
printf "${YELLOW}Введите номера сервисов через запятую (например, рекомендую: 1,2,3,7): ${NC}"
read SERVICES

# разрешение соединений для выбранных сервисов
if [[ $SERVICES == *"1"* ]]; then
    sudo ufw allow 80/tcp # разрешать http-соединения
fi

if [[ $SERVICES == *"2"* ]]; then
    sudo ufw allow 443/tcp # разрешать https-соединения
fi

if [[ $SERVICES == *"3"* ]]; then
    sudo ufw allow 3306/tcp # разрешать mysql-соединения
fi

if [[ $SERVICES == *"4"* ]]; then
    sudo ufw allow 5432/tcp # разрешать postgresql-соединения
fi

if [[ $SERVICES == *"5"* ]]; then
    sudo ufw allow 20/tcp # разрешать ftp-соединения
    sudo ufw allow 21/tcp # разрешать ftp-соединения
fi

if [[ $SERVICES == *"6"* ]]; then
    sudo ufw allow 25/tcp # разрешать smtp-соединения
    sudo ufw allow 587/tcp # разрешать smtp-соединения
fi

if [[ $SERVICES == *"7"* ]]; then
    sudo ufw allow 53/tcp # разрешать dns-соединения
    sudo ufw allow 53/udp # разрешать dns-соединения
fi

if [[ $SERVICES == *"8"* ]]; then
    sudo ufw allow 111/tcp # разрешать nfs-соединения
    sudo ufw allow 111/udp # разрешать nfs-соединения
    sudo ufw allow 2049/tcp # разрешать nfs-соединения
    sudo ufw allow 2049/udp # разрешать nfs-соединения
fi

if [[ $SERVICES == *"9"* ]]; then
    sudo ufw allow 139/tcp # разрешать samba-соединения
    sudo ufw allow 445/tcp # разрешать samba-соединения
fi

if [[ $SERVICES == *"10"* ]]; then
    sudo ufw allow 80/tcp # разрешать http-соединения
    sudo ufw allow 443/tcp # разрешать https-соединения
    sudo ufw allow 3306/tcp # разрешать mysql-соединения
    sudo ufw allow 5432/tcp # разрешать postgresql-соединения
    sudo ufw allow 20/tcp # разрешать ftp-соединения
    sudo ufw allow 21/tcp # разрешать ftp-соединения
    sudo ufw allow 25/tcp # разрешать smtp-соединения
    sudo ufw allow 587/tcp # разрешать smtp-соединения
    sudo ufw allow 53/tcp # разрешать dns-соединения
    sudo ufw allow 53/udp # разрешать dns-соединения
    sudo ufw allow 111/tcp # разрешать nfs-соединения
    sudo ufw allow 111/udp # разрешать nfs-соединения
    sudo ufw allow 2049/tcp # разрешать nfs-соединения
    sudo ufw allow 2049/udp # разрешать nfs-соединения
    sudo ufw allow 139/tcp # разрешать samba-соединения
    sudo ufw allow 445/tcp # разрешать samba-соединения
fi

# включение фаервола
sudo ufw enable

# вывод информации об открытых портах
printf "${GREEN}\nОткрытые порты:${NC}\n"
sudo ufw status #numbered | grep -Eo "([0-9]+/[a-z]+).+?ALLOW.+?Anywhere" | sed -E "s/([0-9]+\/[a-z]+).+?ALLOW.+?Anywhere/\1/g"



    printf "${GREEN}Заходите на мой форум: https://openode.ru${NC}\n"
