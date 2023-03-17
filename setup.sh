#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Добро пожаловать в утилиту загрузки и запуска скриптов!${NC}"
echo -e "${YELLOW}Выберите файлы для загрузки (разделите номера запятыми):${NC}"

echo -e "{YELLOW}1. ssh.sh - Изменение порта для SSH. (не забудьте на что меняли!!!) - запускайте раньше чем установка UFW"
echo -e "2. ufw-install.sh - Установка UFW (FirewallD для CentOS) и настройка портов"
echo -e "3. ufw-docker.sh - Установка ufw-docker для безопасности контейнеров Docker (нет поддержки CentOS)${NC}"

read -p "Введите свой выбор (например, 1,2,3): " choices

# Разбиваем введенную строку на массив, используя запятые в качестве разделителей
IFS=',' read -ra selected <<< "$choices"

# Проходим по выбранным номерам и загружаем соответствующие файлы
for choice in "${selected[@]}"; do
    case $choice in
        1)
            if curl -O https://raw.githubusercontent.com/DigneZzZ/ad-wireguard/main/ssh.sh && chmod +x ssh.sh && sh ssh.sh; then
                echo -e "${GREEN}Файл ssh.sh загружен и запущен успешно.${NC}"
            else
                echo -e "${RED}Не удалось загрузить или запустить файл ssh.sh${NC}"
            fi
            ;;
        2)
            if curl -O https://raw.githubusercontent.com/DigneZzZ/ad-wireguard/main/ufw-setup.sh -o ufw-setup.sh && chmod +x ufw-setup.sh && sh ufw-setup.sh; then
                echo -e "${GREEN}Файл ufw-setup.sh загружен и запущен успешно.${NC}"
            else
                echo -e "${RED}Не удалось загрузить или запустить файл ufw-setup.sh.${NC}"
            fi
            ;;
            
        3)
            if curl -O https://raw.githubusercontent.com/DigneZzZ/ad-wireguard/main/ufw-docker.sh && chmod +x ufw-docker.sh && sh ufw-docker.sh; then
                echo -e "${GREEN}Файл ufw-docker.sh загружен и запущен успешно.${NC}"
            else
                echo -e "${RED}Не удалось загрузить или запустить файл ufw-docker.sh.${NC}"
            fi
            ;;
            
        *)
            echo -e "${RED}Неверный выбор: $choice${NC}"
            ;;
    esac
done

echo -e "${YELLOW}Загрузка и запуск завершены.${NC}"
echo -e "${GREEN}http://openode.ru${NC}"
