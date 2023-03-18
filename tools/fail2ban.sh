#!/bin/bash

# Проверяем, установлен ли fail2ban
if [ -x "$(command -v fail2ban-client)" ]; then
  printf "{YELLOW}Fail2ban уже установлен.{NORMAL}\n"
  exit 0
fi

# Проверяем, запущен ли скрипт от имени sudo
if [[ $EUID -ne 0 ]]; then
  printf "{RED}Этот скрипт нужно запустить от имени sudo.{NORMAL}\n"
  exit 1
fi

# Подтверждаем начало установки
printf "{YELLOW}Установка Fail2ban.{NORMAL}\n"
printf "Вы уверены, что хотите продолжить? (y/n) "
read -r response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  exit 0
fi

# Устанавливаем fail2ban
apt-get update
apt-get install -y fail2ban

# Добавляем сервис для мониторинга доступа sshd
ssh_port=$(ss -ntlp | grep sshd | awk '{print $5}' | cut -d ':' -f 2)
printf "Обнаружен порт SSH: %s\n" "$ssh_port"
printf "Хотите добавить сервис для мониторинга доступа SSH? (y/n) "
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  cat > /etc/fail2ban/jail.d/sshd.local << EOF
[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 2592000
EOF
fi

# Настраиваем конфигурационный файл
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 2592000
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 2592000

[http-get-dos]
enabled = true
port = http,https
filter = http-get-dos
logpath = /var/log/apache2/access.log
maxretry = 300
EOF

# Предлагаем пользователю добавить настройки для веб-сервера, ftp и smtp
printf "Хотите добавить настройки для веб-сервера, FTP и SMTP? (y/n) "
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  cat >> /etc/fail2ban/jail.local << EOF
[apache]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache*/*error.log
maxretry = 3
bantime = 2592000

[proftpd]
enabled = true
port = ftp
filter = proftpd
logpath = /var/log/proftpd/proftpd.log
maxretry = 3
bantime = 2592000

[postfix]
enabled = true
port = smtp,ssmtp
filter = postfix
logpath = /var/log/mail.log
maxretry = 3
bantime = 2592000
EOF
fi

# Перезапускаем сервис
systemctl restart fail2ban

# Проверяем, успешно ли выполнена установка
if [ -x "$(command -v fail2ban-client)" ]; then
  printf "{GREEN}Установка Fail2ban завершена успешно.{NORMAL}\n"
  exit 0
else
  printf "{RED}Произошла ошибка при установке Fail2ban.{NORMAL}\n"
  exit 1
fi
