#!/bin/bash

# Проверить, существует ли файл подкачки /swapfile
if grep -q /swapfile /etc/fstab; then
    echo "Файл подкачки уже существует."
    current_swap_size=$(grep /swapfile /proc/swaps | awk '{print $3}')
    echo "Текущий размер подкачки: $current_swap_size"
    read -p "Вы хотите создать новый файл подкачки? (y/n) " choice
    case "$choice" in
        y|Y ) ;;
        n|N ) exit;;
        * ) echo "Неправильный выбор. Отмена."; exit;;
    esac
    # Удалить старый файл подкачки и запись из /etc/fstab
    sudo swapoff /swapfile
    sudo rm /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab
fi

# Получить размер ОЗУ в байтах
mem_bytes=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')

# Рассчитать размер файла подкачки
if (( $mem_bytes < 2147483648 )); then
    # Вдвое больше объема ОЗУ, если ОЗУ менее 2 ГБ
    swap_size=$((mem_bytes * 2))
else
    # ОЗУ больше или равно 2 ГБ, размер подкачки равен ОЗУ + 2 ГБ
    swap_size=$((mem_bytes + 2147483648))
fi

# Создать файл подкачки
sudo fallocate -l $swap_size /swapfile

# Назначить правильные разрешения на файл подкачки
sudo chmod 600 /swapfile

# Форматировать файл подкачки как swap
sudo mkswap /swapfile

# Включить файл подкачки
sudo swapon /swapfile

# Добавить запись в /etc/fstab для автоматического включения файла подкачки при загрузке системы
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
