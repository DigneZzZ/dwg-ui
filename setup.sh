#!/bin/bash
# Получаем внешний IP-адрес
MYHOST_IP=$(hostname -I | cut -d' ' -f1)
# Обновление пакетов
printf "\e[42mОбновление пакетов...\e[0m\n"
apt update
printf "\e[42mПакеты успешно обновлены.\e[0m\n"

# Установка Git
printf "\e[42mУстановка Git...\e[0m\n"
apt install git -y
printf "\e[42mGit успешно установлен.\e[0m\n"

# Клонирование репозитория
printf "\e[42mКлонирование репозитория ad-wireguard...\e[0m\n"
git clone https://github.com/dignezzz/ad-wireguard.git temp

# копирование содержимого временной директории в целевую директорию с перезаписью существующих файлов и папок
cp -rf temp/* ad-wireguard/

# удаление временной директории со всем ее содержимым
rm -rf temp
printf "\e[42mРепозиторий ad-wireguard успешно клонирован до актуальной версии в репозитории.\e[0m\n"

# Переходим в папку ad-wireguard
printf "\e[42mПереходим в папку ad-wireguard...\e[0m\n"
cd ad-wireguard
printf "\e[42mПерешли в папку ad-wireguard\e[0m\n"

# Установка прав на файл установки
printf "\e[42mУстановка прав на файл установки...\e[0m\n"
chmod +x install.sh
printf "\e[42mПрава на файл установки выставлены.\e[0m\n"

# Запуск установки
printf "\e[42mЗапуск установки ad-wireguard...\e[0m\n"
./install.sh
printf "\e[42mУстановка ad-wireguard успешно завершена.\e[0m\n"

# Установка прав на директорию tools
printf "\e[42mУстановка прав на директорию tools...\e[0m\n"
chmod +x -R tools
printf "\e[42mПрава на директорию tools успешно установлены.\e[0m\n"

# Запуск скрипта ssh.sh
printf "\e[42mЗапуск скрипта ssh.sh для смены стандартного порта SSH...\e[0m\n"
./tools/ssh.sh
printf "\e[42mСкрипт ssh.sh успешно выполнен.\e[0m\n"

# Запуск скрипта ufw.sh
printf "\e[42mЗапуск скрипта ufw.sh для установки UFW Firewall...\e[0m\n"
./tools/ufw.sh
printf "\e[42mСкрипт ufw.sh успешно выполнен.\e[0m\n"

# Переходим в папку /
printf "\e[42mПереходим в папку /root/...\e[0m\n"
cd
printf "\e[42mПерешли в папку /root/ \e[0m\n"

printf '\e[48;5;202m\e[30m ################################################################## \e[0m\n'
printf '\e[48;5;202m\e[30m Всё установлено! \e[0m\n'
printf "\e[48;5;202m\e[30m Адрес входа в веб-интерфейс WireGuard после установки: http://$MYHOST_IP:51821 \e[0m\n"
printf '\e[48;5;202m\e[30m ################################################################## \e[0m\n'
printf '\e[48;5;202m\e[30m Не забудь отдельно установить UFW-Docker, для закрытия веб-интерфейса wireguard. \e[0m\n'
printf '\e[48;5;196m\e[97m ВНИМАНИЕ! Запускать только после того как создадите для себя клиента в WireGUARD!!! \e[0m\n'
printf '\e[48;5;202m\e[30m команда для установки: ./ad-wireguard/tools/ufw.docker \e[0m\n'
printf '\e[48;5;202m\e[30m ################################################################## \e[0m\n'
