# Обновление пакетов
printf "Обновление пакетов...\n"
apt update
printf "Пакеты успешно обновлены.\n"

# Установка Git
printf "Установка Git...\n"
apt install git -y
printf "Git успешно установлен.\n"

# Клонирование репозитория
printf "Клонирование репозитория ad-wireguard...\n"
git clone https://github.com/dignezzz/ad-wireguard.git
printf "Репозиторий ad-wireguard успешно склонирован.\n"

# Установка прав на файл установки
printf "Установка прав на файл скрипта установки...\n"
chmod +x ad-wireguard/install.sh
printf "Права на файл скрипта успешно установлены.\n"

# Запуск установки
printf "Запуск установки ad-wireguard...\n"
./ad-wireguard/install.sh
printf "Установка ad-wireguard успешно завершена.\n"

# Установка прав на директорию tools
printf "Установка прав на директорию tools для выполнения скриптов...\n"
chmod +x -R ad-wireguard/tools
printf "Права на директорию tools успешно установлены.\n"

# Запуск скрипта ssh.sh
printf "Запуск скрипта ssh.sh для смены стандартного порта SSH...\n"
./ad-wireguard/tools/ssh.sh
printf "Скрипт ssh.sh успешно выполнен.\n"

# Запуск скрипта ufw.sh
printf "Запуск скрипта ufw.sh для установки UFW Firewall...\n"
./ad-wireguard/tools/ufw.sh
printf "Скрипт ufw.sh успешно выполнен.\n"
echo "Всё установлено!"
echo "Не забудь отдельно установить UFW-Docker, для закрытия веб-интерфейса wireguard."
echo "команда для установки: ./ad-wireguard/tools/ufw.docker"
