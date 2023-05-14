#!/bin/bash

root_dir="/var/lib/docker/overlay2" # путь к корневой директории
target_dir="diff/app/www" # целевая директория
target_file="index.html" # целевой файл
meta_info="openode_ru_changed" # имя мета-информации

for file_path in $(find $root_dir -type f -name $target_file -path "*/$target_dir/*"); do
    if grep -q "<meta name=\"$meta_info\">" "$file_path"; then # проверяем, есть ли мета-информация в файле
        echo "File $file_path already contains the meta information."
    else
        ip_address=$(curl -s https://checkip.amazonaws.com/) # получаем IP-адрес
        country=$(curl -s https://ipinfo.io/country/) # получаем страну
        # заменяем строку <title>WireGuard</title> на <title>WireGuard сервер - Адрес: $ip_address Страна: $country</title>
        sed -i -e "s/<title>WireGuard<\/title>/<title>WireGuard сервер - Адрес: $ip_address Страна: $country<\/title>/g" "$file_path"
        echo "Title в файле $target_file изменен. Добавлен IP адрес и Страна"
        # заменяем строку <span class="align-middle">WireGuard</span> на <span class="align-middle">WireGuard сервер - Адрес: $ip_address Страна: $country</span>
        sed -i -e "s/<span class=\"align-middle\">WireGuard<\/span>/<span class=\"align-middle\">WireGuard сервер - Адрес: $ip_address Страна: $country<\/span>/g" "$file_path"
        echo "Содержимое <span class=\"align-middle\"> в файле $target_file изменено."
        # заменяем строку <p class="text-2xl font-medium">Clients</p> на <p class="text-2xl font-medium">Клиенты</p>
        sed -i -e "s/<p class=\"text-4xl font-medium\">Clients<\/p>/<p class=\"text-2xl font-medium\">Клиенты<\/p>/g" "$file_path"
        echo "Содержимое <p class=\"text-2xl font-medium\"> в файле $target_file изменено."
        # заменяем строку <span class="text-sm">New</span> на <span class="text-sm">Новый клиент</span>
        sed -i -e "s/<span class=\"text-sm\">New<\/span>/<span class=\"text-sm\">Новый клиент<\/span>/g" "$file_path"
        echo "Содержимое <span class=\"text-sm\"> в файле $target_file изменено."
        # заменяем строку <span v-if="requiresPassword" class="text-sm text-gray-400 mb-10 mr-2 mt-3 cursor-pointer hover:underline float-right" @click="logout">Logout
        # на <span v-if="requiresPassword" class="text-sm text-gray-400 mb-10 mr-2 mt-3 cursor-pointer hover:underline float-right" @click="logout">Выйти
        sed -i -e "s/<span v-if=\"requiresPassword\"\n          class=\"text-sm text-gray-400 mb-10 mr-2 mt-3 cursor-pointer hover:underline float-right\" @click=\"logout\">\n          Logout/<span v-if=\"requiresPassword\"\n          class=\"text-sm text-gray-400 mb-10 mr-2 mt-3 cursor-pointer hover:underline float-right\" @click=\"logout\">\n          Выйти/g" "$file_path"
        echo "Содержимое <span v-if=\"requiresPassword\"> в файле $target_file изменено."
        # добавляем мета-информацию перед тегом <head>
        sed -i -e "/<head>/a <meta name=\"$meta_info\">" "$file_path"
        echo "Мета-информация добавлена в файл $target_file."
        
        sed -i -e "s#<p v-cloak class=\"text-center m-10 text-gray-300 text-xs\">Made by <a target=\"blank\" class=\"hover:underline\"\n        href=\"https://emilenijssen.nl/\?ref=wg-easy\">Emile Nijssen</a> · <a class=\"hover:underline\"\n        href=\"https://github.com/sponsors/WeeJeWel\" target=\"blank\">Donate</a> · <a class=\"hover:underline\"\n        href=\"https://github.com/weejewel/wg-easy\" target=\"blank\">GitHub</a></p>#<p v-cloak class=\"text-center m-10 text-gray-300 text-xs\">Made by <a target=\"blank\" class=\"hover:underline\"\n        href=\"https://emilenijssen.nl/\?ref=wg-easy\">Emile Nijssen</a> · <a class=\"hover:underline\"\n        href=\"https://yoomoney.ru/to/41001707910216\" target=\"blank\">Donate for OpeNode.ru</a> · <a class=\"hover:underline\"\n        href=\"https://github.com/weejewel/wg-easy\" target=\"blank\">GitHub</a> ··· <a class=\"hover:underline\"\n        href=\"https://openode.ru\" target=\"blank\">Russian by OpeNode.RU</a> </p>#g" "$filepath"
        # перезапускаем контейнер wg-easy
        docker stop wg-easy 
        docker start wg-easy 
        echo "Улучшение главной страницы WG-easy завершено. Немного добавлен русский перевод."
    fi
done

