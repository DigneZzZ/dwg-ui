#!/bin/bash

# функция для установки ufw-docker
install_ufw_docker() {
    # установка ufw-docker
    sudo apt-get update
    sudo apt-get install ufw
    sudo apt-get install docker.io
    sudo apt-get install curl
    curl https://raw.githubusercontent.com/chaifeng/ufw-docker/master/ufw-docker.sh | sudo tee /usr/local/bin/ufw-docker > /dev/null
    sudo chmod +x /usr/local/bin/ufw-docker

    # добавление правил для ufw-docker
    sudo ufw allow in on docker0
    sudo ufw allow out on docker0
    sudo ufw allow in on docker_gwbridge
    sudo ufw allow out on docker_gwbridge
    sudo ufw default allow routed
}

# вывод приветственного сообщения
echo "Добро пожаловать в скрипт установки ufw-docker!"

# запрос у пользователя о установке ufw-docker
read -p "Хотите установить ufw-docker? (y/n): " install_ufw_docker_response

# обработка ответа пользователя
if [[ "$install_ufw_docker_response" =~ ^[Yy]$ ]]; then
    install_ufw_docker
    echo "ufw-docker установлен и настроен!"
else
    echo "Установка ufw-docker пропущена."
fi

# формирование настроек по-умолчанию на основе используемых портов
echo "Формирование настроек по-умолчанию на основе используемых портов..."

# получение списка открытых портов и используемых служб
port_services=$(netstat -tulpn | awk '{print $4,$NF}' | grep -E ":[0-9]+" | awk -F '[ :]+' '{print $2,$NF}' | sort -n | uniq)

# создание списка портов для разрешения входящих подключений
allow_ports=()

while read -r port service; do
    case "$service" in
        "ssh") allow_ports+=("$port/tcp");;
        "http"|"httpd"|"apache2") allow_ports+=("$port/tcp");;
        "https") allow_ports+=("$port/tcp");;
        *) :;;
    esac
done <<< "$port_services"

# создание списка портов для разрешения исходящих подключений
allow_out_ports=()

while read -r port service; do
    allow_out_ports+=("$port/tcp")
done <<< "$port_services"

# вывод настроек по-умолчанию
echo "Вот настройки по-умолчанию для ufw:"
echo "  allow ${allow_ports[@]}"
echo "  allow ${allow_out_ports[@]}"
echo "  deny incoming"
echo "  allow outgoing"

# запрос у пользователя о применении настроек по-умолчанию
read -p "Хотите применить эти настройки для ufw? (y/n): " default_settings_response

# обработка ответа пользователя
if [[ "$default_settings_response" =~ ^[Yy]$ ]]; then
    # применение настроек по-умолчанию
    sudo ufw allow ${allow_ports[@]}
    sudo ufw allow ${allow_out_ports[@]}
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw enable
    echo "Настройки по-умолчанию применены!"
else
    echo "Применение настроек по-умолчанию пропущено."
fi

echo "Спасибо за использование скрипта установки ufw-docker!"
