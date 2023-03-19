#!/bin/bash

# Получаем список всех сетей Docker
networks=$(docker network ls --format '{{.Name}}')

# Цикл для обработки каждой сети
for network in $networks
do
  # Получаем информацию об IP-адресах сети и выводим ее на экран
  echo "IP адреса для сети $network:"
  docker network inspect $network --format '{{json .IPAM.Config}}'
done
