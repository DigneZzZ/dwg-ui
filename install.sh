#!/bin/bash

# функция для удаления Docker Compose
uninstall_docker_compose() {
  echo "Удаляем Docker Compose..."
  sudo rm /usr/local/bin/docker-compose
  echo "Docker Compose успешно удален."
}

# определение дистрибутива Linux и его версии
if [ -f /etc/lsb-release ]; then
  . /etc/lsb-release
  OS=$DISTRIB_ID
  VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
  OS=debian
  VER=$(cat /etc/debian_version)
elif [ -f /etc/redhat-release ]; then
  OS=$(awk '{print $1}' /etc/redhat-release | tr '[:upper:]' '[:lower:]')
  VER=$(awk '{print $4}' /etc/redhat-release | cut -d. -f1)
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

# проверяем наличие Docker Compose и удаляем его, если он установлен
if command -v docker-compose &> /dev/null
then
    uninstall_docker_compose
fi

# Установка Docker CE на основе дистрибутива Linux и его версии
if [ $OS == "ubuntu" ] && [ $VER == "20.04" ]; then
    # Установка Docker CE для Ubuntu 20.04
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release 
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
elif [ $OS == "ubuntu" ] && [ $VER == "22.04" ]; then
    # Установка Docker CE для Ubuntu 22.04
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
elif [ $OS == "debian" ] && [ $VER == "11" ]; then
    # Установка Docker CE для Debian 11
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee --force-confmiss /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
elif [ $OS == "debian" ] && [ $VER == "10" ]; then
    # Установка Docker CE для Debian 10
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
elif [ $OS == "centos" ] && [ $VER == "7" ]; then
  # Установка Docker CE для CentOS 7
  yum install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install docker-ce docker-ce-cli containerd.io
  systemctl start docker
  systemctl enable docker
elif [ $OS == "centos" ] && [ $VER == "8" ]; then
  # Установка Docker CE для CentOS 8
  yum install -y dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf install docker-ce docker-ce-cli containerd.io
  systemctl start docker
  systemctl enable docker
elif [ $OS == "centos" ] && [ $VER == "9" ]; then
  # Установка Docker CE для CentOS 9
  dnf install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install docker-ce docker-ce-cli containerd.io
  systemctl start docker
  systemctl enable docker
else
  echo "Дистрибутив Linux и/или его версия не поддерживается."
  exit 1
fi

echo "Docker CE успешно установлен."
# Установка Docker Compose
curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

# Получаем внешний IP-адрес
MYHOST_IP=$(hostname -I | cut -d' ' -f1)

# Записываем IP-адрес в файл docker-compose.yml с меткой MYHOSTIP
sed -i "s/- WG_HOST=.*/- WG_HOST=$MYHOST_IP/g" docker-compose.yml

# Запросите у пользователя пароль
echo ""
read -p "Введите пароль для веб-интерфейса: " WEBPASSWORD
echo ""

# Записываем в файл новый пароль
sed -i "s/- PASSWORD=.*/- PASSWORD=$WEBPASSWORD/g" docker-compose.yml

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
