#!/bin/bash

# Проверяем, установлен ли ufw
if [ -x "$(command -v ufw)" ]; then
  echo "UFW уже установлен."
  # Получаем список открытых портов с помощью netstat и фильтрацией через awk и sort
  ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

  # Проверяем, установлен ли ufw-docker
  if [ -x "$(command -v ufw-docker)" ]; then
    echo "UFW-Docker уже установлен."
    read -p "Хотите обновить список портов на основе используемых сервисов? (y/n): " update_ports
    if [ "$update_ports" = "y" ]; then
      # Очистка текущих правил и настройка новых правил
      sudo ufw --force reset
      sudo ufw default deny incoming
      sudo ufw default allow outgoing
      for port in $ports
      do
        sudo ufw allow $port/tcp
      done

      # Применяем правила для ufw-docker
      sudo ufw allow in on docker0
      sudo ufw reload

      echo "Список портов был успешно обновлен."
    else
      echo "Установка завершена без изменений."
    fi
  else
    read -p "UFW-Docker не установлен, хотите установить его? (y/n): " install_ufw_docker
    if [ "$install_ufw_docker" = "y" ]; then
      # Установка ufw-docker
      sudo curl -fsSL https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker -o /usr/local/bin/ufw-docker
      sudo chmod +x /usr/local/bin/ufw-docker

      # Очистка текущих правил и настройка новых правил
      sudo ufw --force reset
      sudo ufw default deny incoming
      sudo ufw default allow outgoing
      for port in $ports
      do
        sudo ufw allow $port/tcp
      done

      # Применяем правила для ufw-docker
      sudo ufw allow in on docker0
      sudo ufw reload

      echo "UFW-Docker был успешно установлен и настроен на открытие используемых портов."
    else
      echo "Установка завершена без изменений."
    fi
  fi
else
  read -p "UFW не установлен, хотите установить его? (y/n): " install_ufw
  if [ "$install_ufw" = "y" ]; then
    # Установка ufw
    sudo apt-get update
    sudo apt-get install ufw

    # Получаем список открытых портов с помощью netstat и фильтрацией через awk и sort
    ports=$(sudo netstat -lnp | awk '/^tcp/ {if ($NF != "LISTENING") next; split($4, a, ":"); print a[2]}' | sort -u)

    # Проверяем, установлен ли ufw-docker
    if [ -x "$(command -v ufw-docker)" ]; then
      echo "UFW-Docker уже установлен."
      read -p "Хотите обновить список портов на основе используемых сервисов? (y/n): " update_ports
      if [ "$update_ports" = "y" ]; then
        # Очистка текущих правил и настройка новых правил
        sudo ufw --force reset
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        for port in $ports
        do
          sudo ufw allow $port/tcp
        done

        #  # Применяем правила для ufw-docker
        sudo ufw allow in on docker0
        sudo ufw reload

        echo "Список портов был успешно обновлен."
      else
        echo "Установка завершена без изменений."
      fi
    else
      read -p "UFW-Docker не установлен, хотите установить его? (y/n): " install_ufw_docker
      if [ "$install_ufw_docker" = "y" ]; then
        # Установка ufw-docker
        sudo curl -fsSL https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker -o /usr/local/bin/ufw-docker
        sudo chmod +x /usr/local/bin/ufw-docker

        # Очистка текущих правил и настройка новых правил
        sudo ufw --force reset
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        for port in $ports
        do
          sudo ufw allow $port/tcp
        done

        # Применяем правила для ufw-docker
        sudo ufw allow in on docker0
        sudo ufw reload

        echo "UFW-Docker был успешно установлен и настроен на открытие используемых портов."
      else
        echo "Установка завершена без изменений."
      fi
    fi
  else
    echo "Установка завершена без изменений."
  fi
fi
