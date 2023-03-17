
#!/bin/bash

# Проверка наличия установленного ufw
if [ -x "$(command -v ufw)" ]; then
  echo "UFW уже установлен."
  read -p "Хотите обновить список портов на основе используемых сервисов? (y/n): " update_ports
  if [ "$update_ports" = "y" ]; then
    # Получить список открытых портов с помощью netstat и фильтрацией через awk и sort
    ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

    # Очистка текущих правил и настройка новых правил
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    for port in $ports
    do
      sudo ufw allow $port/tcp
    done

    # Сохранение правил и включение ufw
    sudo ufw enable
    echo "Список портов был успешно обновлен."
  else
    echo "Установка завершена без изменений."
  fi
else
  read -p "UFW не установлен, хотите установить его? (y/n): " install_ufw
  if [ "$install_ufw" = "y" ]; then
    # Установка ufw
    sudo apt-get update
    sudo apt-get install ufw

    # Получить список открытых портов с помощью netstat и фильтрацией через awk и sort
    ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

    # Очистка текущих правил и настройка новых правил
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    for port in $ports
    do
      sudo ufw allow $port/tcp
    done

    # Сохранение правил и включение ufw
    sudo ufw enable
    echo "UFW был успешно установлен и настроен на открытие используемых портов."
  else
    echo "Установка завершена без изменений."
  fi
fi
