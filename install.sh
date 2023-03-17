#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Проверяем, выполняется ли скрипт от имени пользователя root
if [ "$EUID" -ne 0 ]
  then echo -e "${RED}Запустите скрипт с правами root${NC}"
  exit
fi

# Проверяем, установлен ли Docker
if [ -x "$(command -v docker)" ]; then
    echo -e "${GREEN}Docker уже установлен${NC}"
else
    # Проверяем, какое распределение используется, и устанавливаем необходимые зависимости
    if [ -f /etc/debian_version ]; then
        apt-get update
        apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    elif [ -f /etc/redhat-release ]; then
        dnf install -y dnf-plugins-core
        dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        dnf install -y curl
    else
        echo -e "${RED}Неподдерживаемое распределение${NC}"
        exit
    fi

    # Устанавливаем Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh

    # Запускаем и включаем службу Docker
    systemctl start docker
    systemctl enable docker

    echo -e "${GREEN}Docker успешно установлен${NC}"
fi

# Устанавливаем Docker Compose
LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d '"' -f 4)
if [ -x "$(command -v docker-compose)" ]; then
    INSTALLED_VERSION=$(docker-compose version --short)
    if [ "$LATEST_VERSION" == "$INSTALLED_VERSION" ]; then
        echo -e "${GREEN}Установлена последняя версия Docker Compose${NC}"
    else
        echo -e "${YELLOW}Обнаружена устаревшая версия Docker Compose${NC}"
        read -p "Хотите обновить Docker Compose? (y/n) " update_docker_compose
        case $update_docker_compose in
            [Yy]* ) sudo rm /usr/local/bin/docker-compose && sudo curl -L "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose && echo -e "${GREEN}Docker Compose успешно обновлен${NC}";;
            [Nn]* ) exit;;
        esac
    fi
else
    sudo curl -L "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose && echo -e "${GREEN}Docker Compose успешно установлен${NC}"
fi

# Устанавливаем редактор Nano
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
  echo -e "${YELLOW}Введите пароль (если нажать Enter, пароль будет задан по умолчанию a1234):${NC}"  
  read password
  if [ -z "$password" ]; then
    password="a1234"
    break
  fi
  if ! [[ "$password" =~ [^a-zA-Z0-9] ]]; then
    break
  else
    echo -e "${RED}Пароль должен содержать латинские буквы верхнего и нижнего регистра, цифры.${NC}"
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
echo -e "Адрес входа в веб-интерфейс WireGuard после установки: ${BLUE}http://$CURRENT_WG_HOST:51821${NC}"
echo -e "Пароль от веб-интерфейса: ${BLUE}$CURRENT_PASSWORD${NC}"
echo ""
echo -e "Адрес входа в веб-интерфейс AdGuardHome после установки (только когда подключитесь к сети WireGuard!!!): ${BLUE}http://$CURRENT_WG_DEFAULT_DNS${NC}"
echo "Ниже представлены логин и пароль для входа в AdGuardHome"
echo -e "Логин:${BLUE} $username${NC}"
echo -e "Пароль:${BLUE} $password${NC}"
echo ""


