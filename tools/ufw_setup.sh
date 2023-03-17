#!/bin/bash

# Определяем цвета для подсветки текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Проверяем наличие UFW на Debian или Ubuntu
if [ -x "$(command -v ufw)" ]; then
    echo -e "${GREEN}UFW уже установлен${NC}"
# Если UFW не установлен, проверяем, является ли операционная система Debian или Ubuntu
elif [ -x "$(command -v apt-get)" ]; then
    echo -e "${YELLOW}UFW не установлен${NC}"
    echo -e "${YELLOW}Установка UFW...${NC}"
    # Добавляем возможность установки на системах Ubuntu 20.04, Ubuntu 22.04, Debian 10, Debian 11
    if [ $(lsb_release -rs) == "20.04" ] || [ $(lsb_release -rs) == "22.04" ] || [ $(lsb_release -rs) == "10" ] || [ $(lsb_release -rs) == "11" ]; then
        sudo apt-get install ufw -y
        echo -e "${GREEN}Установка UFW завершена успешно${NC}"
    else
        echo -e "${RED}Неподдерживаемая версия операционной системы.${NC}"
    fi
# Проверяем наличие firewalld на CentOS
elif [ -x "$(command -v firewall-cmd)" ]; then
    echo -e "${GREEN}firewalld уже установлен${NC}"
# Если firewalld не установлен, проверяем, является ли операционная система CentOS
elif [ -x "$(command -v yum)" ]; then
    echo -e "${YELLOW}firewalld не установлен${NC}"
    echo -e "${YELLOW}Установка firewalld...${NC}"
    # Добавляем возможность установки на системах CentOS 7, CentOS 8, CentOS 9
    if [ $(cat /etc/redhat-release | grep -oE '[0-9]+' | head -1) == "7" ] || [ $(cat /etc/redhat-release | grep -oE '[0-9]+' | head -1) == "8" ] || [ $(cat /etc/redhat-release | grep -oE '[0-9]+' | head -1) == "9" ]; then
        sudo yum install firewalld -y
        echo -e "${GREEN}Установка firewalld завершена успешно${NC}"
    else
        echo -e "${RED}Неподдерживаемая версия операционной системы.${NC}"
    fi
else
    echo -e "${RED}Операционная система не поддерживается.${NC}"
fi

if [ -x "$(command -v firewall-cmd)" ]; then
    # Считываем ssh порт из файла sshd_config
    ssh_port=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshd_config)

    # Запрашиваем подтверждение на использование определенного ssh порта
    echo -e "Обнаружен ssh порт: ${YELLOW}$ssh_port${NC}. Использовать его? (y/n)"
    read use_default_port

    if [[ "$use_default_port" =~ ^(y|Y) ]]; then
      # Добавляем ssh порт в список разрешенных
      sudo firewall-cmd --add-port=$ssh_port/tcp --permanent
    else
      echo -e "Введите ssh порт:"
      read custom_ssh_port
      # Добавляем кастомный ssh порт в список разрешенных
      sudo firewall-cmd --add-port=$custom_ssh_port/tcp --permanent
    fi

    # Предлагаем пользователю добавить разрешенные порты для других сервисов
    echo -e "Добавить разрешенные порты для других сервисов? (y/n)"

    read add_additional_ports

    if [[ "$add_additional_ports" =~ ^(y|Y) ]]; then
      # Список популярных сервисов и портов
      services=("HTTP:80" "HTTPS:443" "FTP:20,21" "SMTP:25" "MySQL:3306")

      for service in "${services[@]}"
      do
        service_name=$(echo $service | cut -d':' -f1)
        ports=$(echo $service | cut -d':' -f2)

        echo -e "Разрешить доступ к портам ${YELLOW}$ports${NC} для сервиса ${YELLOW}$service_name${NC}? (y/n)"
        read allow_service

        if [[ "$allow_service" =~ ^(y|Y) ]]; then
          for port in $(echo $ports | sed "s/,/ /g")
          do
            sudo firewall-cmd --add-port=$port/tcp --permanent
          done
        fi
      done

      # Перезагружаем firewalld
      sudo systemctl restart firewalld

      echo -e "${GREEN}Разрешенные порты для сервисов добавлены.${NC}"
    else
      # Перезагружаем firewalld
      sudo systemctl restart firewalld

      echo -e "${GREEN}Настройка firewall завершена.${NC}"
    fi

    echo -e "${GREEN}Настройка firewalld завершена.${NC}"
else
    # Считываем ssh порт из файла sshd_config
    ssh_port=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshd_config)

    # Запрашиваем подтверждение на использование определенного ssh порта
    echo -e "Обнаружен ssh порт: ${YELLOW}$ssh_port${NC}. Использовать его? (y/n)"
    read use_default_port

    if [[ "$use_default_port" =~ ^(y|Y) ]]; then
      # Добавляем ssh порт в список разрешенных
      sudo ufw allow $ssh_port/tcp
    else
      echo -e "Введите ssh порт:"
      read custom_ssh_port
      # Добавляем кастомный ssh порт в список разрешенных
      sudo ufw allow $custom_ssh_port/tcp
    fi

    # Предлагаем пользователю добавить разрешенные порты для других сервисов
    echo -e "Добавить разрешенные порты для других сервисов? (y/n)"
    read add_additional_ports

    if [[ "$add_additional_ports" =~ ^(y|Y) ]]; then
      # Список популярных сервисов и портов
      services=("HTTP:80" "HTTPS:443" "FTP:20,21" "SMTP:25" "MySQL:3306")

      for service in "${services[@]}"
      do
        service_name=$(echo $service | cut -d':' -f1)
        ports=$(echo $service | cut -d':' -f2)

        echo -e "Разрешить доступ к портам ${YELLOW}$ports${NC} для сервиса ${YELLOW}$service_name${NC}? (y/n)"
        read allow_service

        if [[ "$allow_service" =~ ^(y|Y) ]]; then
          for port in $(echo $ports | sed "s/,/ /g")
          do
            sudo ufw allow $port/tcp
          done
        fi
      done

      # Включаем firewall
      sudo ufw enable

      echo -e "${GREEN}Разрешенные порты для сервисов добавлены.${NC}"
    else
      # Включаем firewall
      sudo ufw enable

      echo -e "${GREEN}Настройка firewall завершена.${NC}"
    fi

    echo -e "${GREEN}Настройка UFW завершена.${NC}"

fi
    echo -e "${YELLOW}Если вы используете docker - контейнеры, не забудьте обезопасить их через запуск ufw-docker.sh${NC}"
    echo -e "${GREEN}Заходите на мой форум: https://openode.ru${NC}"
