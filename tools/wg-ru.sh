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

function check_docker_result() {
    if ! "$1"; then
        echo "Error: could not $2 Docker container."
        exit 1
    fi
}

mapfile -t files < <(find "$root_dir" -type f -name "$target_file" -path "*/$target_dir/*")

for file_path in "${files[@]}"; do
    if grep -q "$file_search_string" "$file_path"; then
        echo "File $file_path already contains the meta information."
    else
        ip_address=$(curl -s https://ipapi.co/ip) 
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
        awk -v title="$title" -v ip_address="$ip_address" -v country="$country" -v country_f="$country_f" '
          /<title>WireGuard<\/title>/{
            gsub(/<title>WireGuard<\/title>/, title)
          }
          /<span class=\\"align-middle\\">WireGuard<\/span>/{
            gsub(/<span class=\\\"align-middle\\\">WireGuard<\/span>/, "<span class=\\"align-middle\\">Адрес: "ip_address" Страна: "country_f"<\/span>")
          }
          /<p class=\\"text-4xl font-medium\\">Clients<\/p>/{
            gsub(/<p class=\\"text-4xl font-medium\\">Clients<\/p>/, "<p class=\\"text-2xl font-medium\\">Клиенты<\/p>")
          }
          /<span class=\\"text-sm\\">New<\/span>/{
            gsub(/<span class=\\"text-sm\\">New<\/span>/, "<span class=\\"text-sm\\">Новый клиент<\/span>")
          }
          !/<head>/{
            print
            next
          }
          {
            print "<head>\n<meta name=\\""meta_info"\\">\n"$0
          }
        ' "$file_path" > "$file_path".tmp && mv "$file_path".tmp "$file_path"

        check_docker_result "docker stop $docker_container" "stop"
        check_docker_result "docker start $docker_container" "start"
    fi
done

echo "Script completed successfully."
