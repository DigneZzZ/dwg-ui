#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Определение дистрибутива Linux и его версии
if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    OS=Debian
    VER=$(cat /etc/debian_version)
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

# Проверка наличия Docker
if ! command -v docker &> /dev/null
then
    read -p "Docker не найден. Установить Docker? (y/n) " INSTALL_DOCKER
    if [ "$INSTALL_DOCKER" == "y" ]; then
        # Установка Docker CE на основе дистрибутива Linux и его версии
        if [ $OS == "Ubuntu" ] && [ $VER == "20.04" ]; then
            # Установка Docker CE для Ubuntu 20.04
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release 
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -у -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo \
              "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
        elif [ $OS == "Ubuntu" ] && [ $VER == "22.04" ]; then
            # Установка Docker CE для Ubuntu 22.04
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -у -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo \
              "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
        elif [ $OS == "Debian" ] && [ $VER == "11" ]; then
            # Установка Docker CE для Debian 11
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -у -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo \
              "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
              $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
        elif [ $OS == "Debian" ] && [ $VER == "10" ]; then
            # Установка Docker CE для Debian 10
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
            curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -y -
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
        else
            echo "Дистрибутив Linux и/или его версия не поддерживается."
            exit 1
        fi
    fi
else
    echo "Docker уже установлен."
fi

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null
then
    read -p "Docker Compose не найден. Установить Docker Compose? (y/n) " INSTALL_COMPOSE
    if [ "$INSTALL_COMPOSE" == "y" ]; then
        # Установка Docker Compose
        curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    fi
else
    read -p "Docker Compose уже установлен. Хотите переустановить? (y/n) " REINSTALL_COMPOSE
    if [ "$REINSTALL_COMPOSE" == "y" ]; then
        # Удаление Docker Compose
        rm /usr/local/bin/docker-compose
        # Установка Docker Compose
        curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    fi
fi

if ! command -v nano &> /dev/null
then
    read -p "Хотите установить текстовый редактор Nano? (y/n) " INSTALL_NANO
    if [ "$INSTALL_NANO" == "y" ]; then
        apt-get update
        apt-get install -y nano
    fi
else
    echo "Текстовый редактор Nano уже установлен."
fi

# Получаем внешний IP-адрес
MYHOST_IP=$(hostname -I | cut -d' ' -f1)

# Записываем IP-адрес в файл docker-compose.yml с меткой MYHOSTIP
sed -i -E  "s/- WG_HOST=.*/- WG_HOST=$MYHOST_IP/g" docker-compose.yml

# Запросите у пользователя пароль
echo ""
echo ""
while true; do
  read -p "Введите пароль для веб-интерфейса: " WEBPASSWORD
  echo ""

  if [[ "$WEBPASSWORD" =~ ^[[:alnum:]]+$ ]]; then
    # Записываем в файл новый пароль в кодировке UTF-8
    sed -i -E "s/- PASSWORD=.*/- PASSWORD=$WEBPASSWORD/g" docker-compose.yml
    break
  else
    echo "Пароль должен состоять только из английских букв и цифр, без пробелов и специальных символов."
  fi
done

# Даем пользователю информацию по установке
# Читаем текущие значения из файла docker-compose.yml
CURRENT_PASSWORD=$(grep PASSWORD docker-compose.yml | cut -d= -f2)
CURRENT_WG_HOST=$(grep WG_HOST docker-compose.yml | cut -d= -f2)
CURRENT_WG_DEFAULT_ADDRESS=$(grep WG_DEFAULT_ADDRESS docker-compose.yml | cut -d= -f2)
CURRENT_WG_DEFAULT_DNS=$(grep WG_DEFAULT_DNS docker-compose.yml | cut -d= -f2)


# Выводим текущие значения
echo ""
echo -e "${BLUE}Текущие значения:${NC}"
echo ""
echo -e "Пароль от веб-интерфейса: ${BLUE}$CURRENT_PASSWORD${NC}"
echo -e "IP адрес сервера: ${BLUE}$CURRENT_WG_HOST${NC}"
echo -e "Маска пользовательских IP: ${BLUE}$CURRENT_WG_DEFAULT_ADDRESS${NC}"
echo ""
echo -e "Адрес входа в веб-интерфейс WireGuard после установки: ${YELLOW}http://$CURRENT_WG_HOST:51821${NC}"
echo -e "Адрес входа в веб-интерфейс AdGuardHome после установки (только когда подключитесь к сети WireGuard!!!): ${YELLOW}http://$CURRENT_WG_DEFAULT_DNS${NC}"
echo ""
echo ""



# Устанавливаем apache2-utils, если она не установлена
if ! [ -x "$(command -v htpasswd)" ]; then
  echo -e "${RED}Установка apache2-utils...${NC}" >&2
  sudo apt-get update
  sudo apt-get install apache2-utils -y
fi

# Запрашиваем у пользователя логин
echo -e "${YELLOW}Введите логин (по умолчанию admin):${NC}"
read username

# Если логин не введен, устанавливаем логин по умолчанию "admin"
if [ -z "$username" ]; then
  username="admin"
fi

# Запрашиваем у пользователя пароль
while true; do
  echo -e "${YELLOW}Введите пароль:${NC}"
  read -s password
  if [ -z "$password" ]; then
    password="a1234"
    break
  fi
  if [[ "$password" =~ [^a-zA-Z0-9\!\@\#\$\%\^\&\*\(\)\-\+\.\,\;\:\<\>\?\[\]\{\}\_\=\|\\\/] ]]; then
    break
  else
    echo -e "${RED}Пароль должен содержать латинские буквы верхнего и нижнего регистра, цифры и специальные символы.${NC}"
  fi
done

# Генерируем хеш пароля с помощью htpasswd из пакета apache2-utils
hashed_password=$(htpasswd -bnB $username $password | cut -d ":" -f 2)

# Записываем связку логина и зашифрованного пароля в файл conf/AdGuardHome.yaml
sed -i "s/\(name: $username\).*\(password: \).*/\1\n\2$hashed_password/" conf/AdGuardHome.yaml

# Выводим сообщение об успешной записи связки логина и пароля в файл
echo -e "${GREEN}Связка логина и пароля успешно записана в файл conf/AdGuardHome.yaml${NC}"


# Выводим связку логина и пароля в консоль
echo "Ниже представлены логин и пароль для входа в AdGuardHome"
echo -e "${GREEN}Логин: $username${NC}"
echo -e "${GREEN}Пароль: $password${NC}"

# Запускаем docker-compose
docker-compose up -d

echo ""
echo -e "Адрес входа в веб-интерфейс WireGuard после установки: ${YELLOW}http://$CURRENT_WG_HOST:51821${NC}"
echo -e "Адрес входа в веб-интерфейс AdGuardHome после установки (только когда подключитесь к сети WireGuard!!!): ${YELLOW}http://$CURRENT_WG_DEFAULT_DNS${NC}"
echo ""

# РАЗДЕЛ ИЗМЕНЕНИЯ ПОРТА SSH для подключения пользователя
# Проверяем наличие файла конфигурации SSH
if [ ! -f /etc/ssh/sshd_config ]; then
    echo -e "\e[91mОшибка: файл конфигурации SSH (/etc/ssh/sshd_config) не найден.\e[0m"
    exit 1
fi

# Запрос текущего порта SSH
current_port=$(grep -oP "(?<=Port ).+" /etc/ssh/sshd_config)

# Если порт не указан в конфигурационном файле, то присваиваем ему значение по умолчанию
if [ -z "$current_port" ]; then
    current_port=22
fi

# Определяем, хочет ли пользователь изменить порт
read -p $'\e[93m'"Текущий порт SSH: $current_port. Хотите изменить порт? (y/n): "'\e[0m' change_port

if [ "$change_port" == "y" ]; then
    # Запрос нового порта
    read -p $'\e[93m'"Введите новый порт (допустимый диапазон: 1024-65535): "'\e[0m' new_port

    # Проверка, что введено число
    if ! [[ "$new_port" =~ ^[0-9]+$ ]]; then
        echo -e "\e[91mОшибка: порт должен быть числом.\e[0m"
        exit 1
    fi

    # Проверка, что порт в допустимом диапазоне
    if [ "$new_port" -lt 1024 ] || [ "$new_port" -gt 65535 ]; then
        echo -e "\e[91mОшибка: порт должен быть в диапазоне от 1024 до 65535.\e[0m"
        exit 1
    fi

    # Проверка, что порт не используется другим сервисом
    if ss -tnlp | grep -q ":$new_port "; then
        echo -e "\e[91mОшибка: порт $new_port уже используется другим сервисом.\e[0m"
        exit 1
    fi

    # Изменяем порт
    if grep -q "^#*Port $current_port$" /etc/ssh/sshd_config; then
        sed -i "s/^#*Port $current_port$/Port $new_port/g" /etc/ssh/sshd_config
    else
        echo "Port $new_port" >> /etc/ssh/sshd_config
    fi

    systemctl restart sshd

    echo -e "\e[32mПорт SSH успешно изменен на $new_port.\e[0m"
elif [ "$change_port" == "n" ]; then
    echo -e "\e[32mПорт SSH останется неизменным.\e[0m"
else
    echo -e "\e[91mНеверный ответ. Пожалуйста, введите 'y' или 'n'.\e[0m"
    exit 1
fi


# Проверка наличия установленного ufw
if [ -x "$(command -v ufw)" ]; then
  echo "UFW уже установлен."
  read -p "Хотите обновить список портов на основе используемых сервисов? (y/n): " update_ports
  if [ "$update_ports" = "y" ]; then
    # Получить список открытых портов с помощью netstat и фильтрацией через awk и sort
    ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

    # Очистка текущих правил и настройка новых правил
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    for port in $ports
    do
      sudo ufw allow $port/tcp
    done

    # Сохранение правил и включение ufw
    sudo ufw enable
    echo "Список портов был успешно обновлен."
  else
    echo "Установка завершена без изменений."
  fi
else
  read -p "UFW не установлен, хотите установить его? (y/n): " install_ufw
  if [ "$install_ufw" = "y" ]; then
    # Установка ufw
    sudo apt-get update
    sudo apt-get install ufw

    # Получить список открытых портов с помощью netstat и фильтрацией через awk и sort
    ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

    # Очистка текущих правил и настройка новых правил
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    for port in $ports
    do
      sudo ufw allow $port/tcp
    done

    # Сохранение правил и включение ufw
    sudo ufw enable
    echo "UFW был успешно установлен и настроен на открытие используемых портов."
  else
    echo "Установка завершена без изменений."
  fi
fi
