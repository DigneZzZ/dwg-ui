#!/bin/bash
# Функция для вывода сообщения об успешном выполнении
function success_message {
    printf "\e[42m%s\e[0m\n" "$1"
}

# Функция для вывода сообщения об ошибке
function error_message {
    printf "\e[41m%s\e[0m\n" "$1"
}

# Проверить, существует ли файл подкачки /swapfile
if grep -q /swapfile /etc/fstab; then
    success_message "Файл подкачки уже существует."
    currentswapsize=$(grep /swapfile /proc/swaps | awk '{print $3}')
    success_message "Текущий размер подкачки: $currentswapsize"
    printf "Вы хотите создать новый файл подкачки? (y/n) " 
    read -r choice
    case "$choice" in
        y|Y ) ;;
        n|N ) exit;;
        * ) error_message "Неправильный выбор. Отмена."; exit;;
    esac
    # Удалить старый файл подкачки и запись из /etc/fstab
    sudo swapoff /swapfile
    sudo rm /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab
fi

# Получить размер ОЗУ в байтах
mem_bytes=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')

# Рассчитать размер файла подкачки
if (( mem_bytes < 2147483648 )); then
    # Вдвое больше объема ОЗУ, если ОЗУ менее 2 ГБ
    swapsize=$(( mem_bytes * 2 ))
else
    # ОЗУ больше или равно 2 ГБ, размер подкачки равен ОЗУ + 2 ГБ
    swapsize=$(( mem_bytes + 2147483648 ))
fi
# Проверить, монтирован ли файл подкачки
if grep -q '/swapfile' /proc/swaps; then
    # Если файл подкачки уже монтирован, отключите его
    success_message "Отключение файла подкачки..."
    sudo swapoff /swapfile
fi

# Создать файл подкачки
success_message "Создание файла подкачки..."
sudo fallocate -l "$swapsize" /swapfile

# Назначить правильные разрешения на файл подкачки
success_message "Назначение правильных разрешений на файл подкачки..."
sudo chmod 600 /swapfile

# Форматировать файл подкачки как swap
success_message "Форматирование файла подкачки как swap..."
sudo mkswap /swapfile

# Включить файл подкачки
success_message "Включение файла подкачки..."
sudo swapon /swapfile

# Добавить запись в /etc/fstab для автоматического включения файла подкачки при загрузке системы
success_message "Добавление записи в /etc/fstab для автоматического включения файла подкачки при загрузке системы..."
printf '/swapfile none swap sw 0 0\n' | sudo tee -a /etc/fstab

# Вывод информации о созданном swap файле и размере ОЗУ
swap_size=$(numfmt --to=iec-i --suffix=B "$swapsize")
mem_size=$(numfmt --to=iec-i --suffix=B "$mem_bytes")
success_message "Swap файл размером $swap_size был успешно создан."
success_message "Размер ОЗУ: $mem_size"
