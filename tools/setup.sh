#!/bin/bash

# Проверяем наличие утилит curl, chmod и read
if ! command -v curl &> /dev/null || ! command -v chmod &> /dev/null || ! command -v read &> /dev/null
then
    echo "Ошибка: Не найдены необходимые утилиты curl, chmod и read. Пожалуйста, установите их и попробуйте снова"
    exit 1
fi

# Проверяем наличие файлов на сервере
for i in {1..5}
do
    if curl --head --silent --fail https://example.com/script${i}.sh 2>&1 | grep "HTTP/1.[01] [23].." > /dev/null
    then
        echo "Файл script${i}.sh найден на сервере"
    else
        echo "Ошибка: Файл script${i}.sh не найден на сервере"
        exit 1
    fi
done

# Предлагаем пользователю выбрать скрипты для установки
printf "Выберите скрипты для установки:\n"
printf "1. Скрипт 1\n"
printf "2. Скрипт 2\n"
printf "3. Скрипт 3\n"
printf "4. Скрипт 4\n"
printf "5. Скрипт 5\n"
printf "Введите номер скрипта (через запятую, например, 1,2,3): "
read -r scripts

# Извлекаем выбранные скрипты в массив
IFS=',' read -ra script_arr <<< "$scripts"

# Итерируемся по массиву и устанавливаем выбранные скрипты
for script_num in "${script_arr[@]}"
do
  case $script_num in
    1)
      # Скачиваем и устанавливаем первый скрипт
      printf "\033[0;32mУстановка скрипта 1...\033[0m\n"
      curl -O https://example.com/script1.sh && chmod +x script1.sh && ./script1.sh
      if [ $? -eq 0 ]; then
        printf "\033[0;32mСкрипт 1 успешно установлен\033[0m\n"
      else
        printf "\033[0;31mНе удалось установить скрипт 1\033[0m\n"
      fi
      ;;
    2)
      # Скачиваем и устанавливаем второй скрипт
      printf "\033[0;32mУстановка скрипта 2...\033[0m\n"
      curl -O https://example.com/script2.sh && chmod +x script2.sh && ./script2.sh
      if [ $? -eq 0 ]; then
        printf "\033[0;32mСкрипт 2 успешно установлен\033[0m\n"
      else
        printf "\033[0;31mНе удалось установить скрипт 2\033[0m\n"
      fi
      ;;
    3)
    
      # Скачиваем и устанавливаем третий
            printf "\033[0;32mУстановка скрипта 3...\033[0m\n"
      curl -O https://example.com/script3.sh && chmod +x script3.sh && ./script3.sh
      if [ $? -eq 0 ]; then
        printf "\033[0;32mСкрипт 3 успешно установлен\033[0m\n"
      else
        printf "\033[0;31mНе удалось установить скрипт 3\033[0m\n"
      fi
      ;;
    4)
      # Скачиваем и устанавливаем четвертый скрипт
      printf "\033[0;32mУстановка скрипта 4...\033[0m\n"
      curl -O https://example.com/script4.sh && chmod +x script4.sh && ./script4.sh
      if [ $? -eq 0 ]; then
        printf "\033[0;32mСкрипт 4 успешно установлен\033[0m\n"
      else
        printf "\033[0;31mНе удалось установить скрипт 4\033[0m\n"
      fi
      ;;
    5)
      # Скачиваем и устанавливаем пятый скрипт
      printf "\033[0;32mУстановка скрипта 5...\033[0m\n"
      curl -O https://example.com/script5.sh && chmod +x script5.sh && ./script5.sh
      if [ $? -eq 0 ]; then
        printf "\033[0;32mСкрипт 5 успешно установлен\033[0m\n"
      else
        printf "\033[0;31mНе удалось установить скрипт 5\033[0m\n"
      fi
      ;;
    *)
      # Некорректный ввод
      printf "\033[0;33mНекорректный ввод. Попробуйте снова.\033[0m\n"
      ;;
  esac
done

      
