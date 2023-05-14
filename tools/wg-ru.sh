#!/bin/bash

root_dir="/var/lib/docker/overlay2"
target_dir="diff/app/www"
target_file="index.html"
meta_info="openode_ru_changed"
file_search_string="<meta name=\"$meta_info\">"
docker_container="wg-easy"
add_meta_info="y"
title="<title>WireGuard сервер. Адрес: $ip_address Страна: $country</title>"

function check_file() {
    if [ ! -f "$1" ]; then
        echo "Error: file $1 not found."
        exit 1
    fi
}


mapfile -t files < <(find "$root_dir" -type f -name "$target_file" -path "*/$target_dir/*")

for file_path in "${files[@]}"; do
    if grep -q "$file_search_string" "$file_path"; then
        echo "File $file_path already contains the meta information."
    else
        ip_address=$(curl -s https://checkip.amazonaws.com/) 
        if [ -z "$ip_address" ]; then
            echo "Error: could not retrieve IP address."
            exit 1
        fi
        country_f=$(curl -s curl -s https://ipapi.co/country_name)
        country=$(curl -s curl -s https://ipapi.co/country_code_iso3)
        if [ -z "$country" ]; then
            echo "Error: could not retrieve country."
            exit 1
        fi
        check_file "$file_path"
        
        # Заменяем текст с помощью команды sed
        sed -i "s|<title>[^<]*<\/title>|<title>WireGuard :: Адрес: $ip_address Страна: $country<\/title>|" "$file_path"
        sed -i "s|<span class=\\"align-middle\\">WireGuard<\/span>|<span class=\\"align-middle\\">WireGuard: Адрес: $ip_address Страна: $country_f<\/span>|" "$file_path"
        sed -i "s|>Clients<|>Клиенты<|" "$file_path"
        sed -i "s|>New<|>Новый клиент<|" "$file_path"
        sed -i 's#https://github.com/sponsors/WeeJeWel#https://yoomoney.ru/to/41001707910216#g' "$file_path"
        sed -i 's#href="https://github.com/weejewel/wg-easy" target="_blank">GitHub#href="https://openode.ru" target="_blank">ReCreated by OpeNode.ru#g' "$file_path"
        sed -i 's#v-cloak class="text-center m-10 text-gray-300 text-xs"#v-cloak class="text-center m-10 text-gray-600 text-xs"#g' "$file_path"
        # Добавляем мета-информацию
        sed -i "1s|^|<head>\n<meta name=\\"$meta_info\\">\n|" "$file_path"


       docker stop $docker_container
       docker start $docker_container
    fi
done

echo "Script completed successfully."
