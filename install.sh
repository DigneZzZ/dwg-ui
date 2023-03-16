#!/bin/bash

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

# Установка Docker CE на основе дистрибутива Linux и его версии
if [ $OS == "Ubuntu" ] && [ $VER == "20.04" ]; then
    # Установка Docker CE для Ubuntu 20.04
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release 
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
elif [ $OS == "Ubuntu" ] && [ $VER == "22.04" ]; then
    # Установка Docker CE для Ubuntu 22.04
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
elif [ $OS == "Debian" ] && [ $VER == "11" ]; then
    # Установка Docker CE для Debian 11
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
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

# Установка Docker Compose
curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

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

# Выводим текущие значения для подтверждения пользователя
echo ""
echo "Текущие значения:"
echo ""
echo "Пароль от веб-интерфейса: $CURRENT_PASSWORD"
echo "IP адрес сервера: $CURRENT_WG_HOST"
echo "Маска пользовательских IP: $CURRENT_WG_DEFAULT_ADDRESS"
echo ""
echo "Адрес входа в веб-интерфейс WireGuard после установки: http://$CURRENT_WG_HOST:51821"
echo "Адрес входа в веб-интерфейс AdGuardHome после установки (только когда подключитесь к сети WireGuard!!!): http://$CURRENT_WG_DEFAULT_DNS"
echo ""
echo ""

# Запрашиваем подтверждение пользователя
#read -p "У вас есть проблемы со входом в AdGuardHome или WireGuard UI? (Наблюдается на хостинге Aeza) (y/n) " RESPONSE

# Если пользователь подтвердил, запрашиваем новые значения и обновляем файл docker-compose.yml
#if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
#  read -p "Для устранения проблемы со входом необходимо поменять WG_MTU=1280. Мы сделаем это автоматически. Вы точно хотите это сделать?? (y/n) " PASSWORD_RESPONSE
  
#  if [[ "$PASSWORD_RESPONSE" =~ ^[Yy]$ ]]; then
#    sed -i "s/#- WG_MTU=.*/- WG_MTU=1280/g" docker-compose.yml
#  fi
#fi

# Запускаем docker-compose
docker-compose up -d

echo ""
echo "Адрес входа в веб-интерфейс WireGuard после установки: http://$CURRENT_WG_HOST:51821"
echo "Адрес входа в веб-интерфейс AdGuardHome после установки (только когда подключитесь к сети WireGuard!!!): http://$CURRENT_WG_DEFAULT_DNS"
echo ""
