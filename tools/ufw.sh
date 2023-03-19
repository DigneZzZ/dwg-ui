#!/bin/bash

# Определяем цвета для подсветки текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Проверяем права администратора
if [ $(id -u) != 0 ]; then
    echo -e "${RED}Необходимы права администратора.${NC}"
    exit 1
fi

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
        exit 1
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
        exit 1
    fi
else
    echo -e "${RED}Операционная система не поддерживается.${NC}"
    exit 1
fi

if  -x "$(command -v firewall-cmd)" ; then
    # Проверяем наличие файла /etc/ssh/sshdconfig
    if [ ! -f "/etc/ssh/sshdconfig" ]; then
        echo -e "${RED}Файл /etc/ssh/sshdconfig не найден.${NC}"
        exit 1
    fi

    # Считываем ssh порт из файла sshdconfig
    sshport=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshdconfig)

    # Запрашиваем подтверждение на использование определенного ssh порта
    echo -e "Обнаружен ssh порт: ${YELLOW}$sshport${NC}. Использовать его? (y/n)"
    read usedefaultport

    if [[ "$usedefaultport" =~ ^(y|Y) ]]; then
      # Добавляем ssh порт в список разрешенных
      firewall-cmd --add-port=$sshport/tcp --permanent
    else
      echo -e "Введите ssh порт:"
      read customsshport
      # Добавляем кастомный ssh порт в список разрешенных
      firewall-cmd --add-port=$customsshport/tcp --permanent
    fi

   # Предлагаем пользователю добавить разрешенные порты для других сервисов
echo -e "Добавить разрешенные порты для других сервисов? (y/n)"
read add_additional_ports

if [[ "$add_additional_ports" =~ ^(y|Y) ]]; then
  # Список популярных сервисов и портов
  services=("HTTP:80" "HTTPS:443" "FTP:20,21" "SMTP:25" "MySQL:3306")

  for service in "${services[@]}"
  do
    servicename=$(echo $service | cut -d':' -f1)
    ports=$(echo $service | cut -d':' -f2)

    echo -e "Разрешить доступ к портам ${YELLOW}$ports${NC} для сервиса ${YELLOW}$servicename${NC}? (y/n)"
    read allowservice

    if [[ "$allowservice" =~ ^(y|Y) ]]; then
      for port in $(echo $ports | sed "s/,/ /g")
      do
        firewall-cmd --add-port=$port/tcp --permanent
      done
    fi
  done

      # Перезагружаем firewalld
      systemctl restart firewalld

      echo -e "${GREEN}Разрешенные порты для сервисов добавлены.${NC}"
    else
      # Перезагружаем firewalld
      systemctl restart firewalld

      echo -e "${GREEN}Настройка firewall завершена.${NC}"
    fi

    echo -e "${GREEN}Настройка firewalld завершена.${NC}"
else
    # Проверяем наличие файла /etc/ssh/sshdconfig
    if [ ! -f "/etc/ssh/sshdconfig" ]; then
        echo -e "${RED}Файл /etc/ssh/sshdconfig не найден.${NC}"
        exit 1
    fi

    # Считываем ssh порт из файла sshdconfig
    sshport=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshdconfig)

    # Запрашиваем подтверждение на использование определенного ssh порта
    echo -e "Обнаружен ssh порт: ${YELLOW}$sshport${NC}. Использовать его? (y/n)"
    read usedefaultport

    if [[ "$usedefaultport" =~ ^(y|Y) ]]; then
      # Добавляем ssh порт в список разрешенных
      ufw allow $sshport/tcp
    else
      echo -e "Введите ssh порт:"
      read customsshport
      # Добавляем кастомный ssh порт в список разрешенных
      ufw allow $customsshport/tcp
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
            ufw allow $port/tcp
          done
        fi
      done

      echo -e "${GREEN}Разрешенные порты для сервисов добавлены.${NC}"
    else
      echo -e "${GREEN}Настройка ufw завершена.${NC}"
    fi

    echo -e "${GREEN}Настройка ufw завершена.${NC}"
fi
    echo -e "${YELLOW}Регистрируйтесь на моём форуме: https://openode.ru${NC}"
exit 0
