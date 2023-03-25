#!/bin/bash

# Функция для вывода сообщения об успешном выполнении
function success_message {
    printf "\e[42m%s\e[0m\n" "$1"
}

# Функция для вывода сообщения об ошибке
function error_message {
    printf "\e[41m%s\e[0m\n" "$1"
}

# Функция для запроса размера файла подкачки у пользователя
function ask_swapsize {
    read -rp "Введите желаемый размер файла подкачки в МБ: " swapsize
    while (( swapsize > max_swapsize )); do
        read -rp "Размер файла подкачки слишком большой. Максимальный размер: $max_swapsize МБ. Пожалуйста, введите другой размер: " swapsize
    done
}

# Получаем свободное дисковое пространство с помощью команды df и awk
# Из вывода команды df используем только строку, соответствующую корневому разделу (/)
# С помощью awk извлекаем пятый столбец, содержащий свободное дисковое пространство
# Значение сохраняем в переменную free_space
free_space=$(df / | awk 'NR==2{print $4}')

# Вычисляем половину свободного дискового пространства и сохраняем значение в переменную max_swapsize
max_swapsize=$((free_space/2))

# Проверить, существует ли файл подкачки /swapfile
if grep -q /swapfile /etc/fstab; then
    success_message "Файл подкачки уже существует."
    currentswapsize=$(grep /swapfile /proc/swaps | awk '{print $3}')
    printf "Текущий размер подкачки: %s\n" "$currentswapsize"
    printf "Вы хотите создать новый файл подкачки? (y/n) " 
    read -r choice
    case "$choice" in
        y|Y )
            # Рассчитать размер файла подкачки
            mem_bytes=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')
            if (( mem_bytes < 2147483648 )); then
                # Вдвое больше объема ОЗУ, если ОЗУ менее 2 ГБ
                suggested_swapsize=$(( mem_bytes * 2 / 1024 / 1024 ))
            else
                # ОЗУ больше или равно 2 ГБ, размер подкачки равен ОЗУ + 2 ГБ
                suggested_swapsize=$(( (mem_bytes + 2147483648) / 1024 / 1024 ))
            fi
            # Предложить пользователю размер файла подкачки
            read -rp "Хотите использовать рекомендуемый размер файла подкачки в $suggested_swapsize МБ? (y/n) " choice
            case "$choice" in
                y|Y ) swapsize=$(( suggested_swapsize * 1024 * 1024 ));;
                n|N ) ask_swapsize; swapsize=$(( swapsize * 1024 * 1024 ));;
                * ) error_message "Неправильный выбор. Отмена."; exit;;
            esac;;
        n|N ) ask_swapsize; swapsize=$(( swapsize * 1024 * 1024 ));;
        * ) error_message "Неправильный выбор. Отмена."; exit;;
    esac
    # Проверить, не превышает ли запрошенный размер максимально допустимый
    while (( swapsize > max_swapsize )); do
        read -rp "Размер файла подкачки слишком большой. Максимальный размер: $max_swapsize МБ. Пожалуйста, введите другой размер: " swapsize
        swapsize=$(( swapsize * 1024 * 1024 ))
    done
else
    # Запросить размер файла подкачки у пользователя
    ask_swapsize
    swapsize=$(( swapsize * 1024 * 1024 ))
    # Проверить, не превышает ли запрошенный размер максимально допустимый
    while (( swapsize > max_swapsize )); do
        read -rp "Размер файла подкачки слишком большой. Максимальный размер: $max_swapsize МБ. Пожалуйста, введите другой размер: " swapsize
        swapsize=$(( swapsize * 1024 * 1024 ))
    done
fi
mem_bytes=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')
success_message "Размер ОЗУ: $(numfmt --to=iec-i --suffix=B "$mem_bytes")"

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
