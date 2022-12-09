# ad-wireguard-ui
Combination Wireguird (wg-easy latest) + Adguard Home + Unbound (Latest)

Here is the start of combination
# Requirings:
* Docker
* Docker-compose

These confinguration of AdGuard include DNS-over-HTTPS (DoH) via Cloudflare service by using DNS: https://cloudflare-dns.com/dns-query
Fow query to CF-DNS using Unbound. This is some type of DNS forwarding.

# Quick Install

```bash
git clone https://github.com/dignezzz/ad-wireguard.git
cd ad-wireguard && nano docker-compose.yml

#then run
docker-compose up -d
```

## AFter Instalation
After install, follow to instruction:
Go to: http://10.2.0.100/  
<b>Login:</b> <u>admin</u> <br />
<b>Password:</b> <u>12345678</u>

# Adlists:
## RU-Adlist
https://easylist-downloads.adblockplus.org/advblock.txt
## BitBlock
https://easylist-downloads.adblockplus.org/bitblock.txt
## Cntblock
https://easylist-downloads.adblockplus.org/cntblock.txt
## EasyList
https://easylist-downloads.adblockplus.org/easylist.txt

## Upstream DNS-Servers
### About default DNS
  The unencrypted 1.1.1.1 is fine if you're sure the connection between your AGH instance and Cloudflare DNS won't be tampered. Otherwise use the encrypted endpoint, either https://cloudflare-dns.com/dns-query for unfiltered query or https://security.cloudflare-dns.com/dns-query for malware filtering. Note that ECH doesn't work if you're using unencrypted upstream.

### All DNS Servers
https://adguard-dns.io/kb/general/dns-providers/#cloudflare-dns

### DNS Perfomance list:
https://www.dnsperf.com/#!dns-resolvers



## What is DNS Leak?

сли я уже использую VPN, зачем мне проверять, имеется ли утечка DNS?

Может возникнуть одна из двух проблем:

1. Ваше устройство может отправлять DNS-запросы за пределы VPN-туннеля.

![dns-leak-outsite@2x-6df1ea3f639ce9d3c5495ab2b7d29fb2e3001bb4bee79478dcee19c94c0a7281 png](https://user-images.githubusercontent.com/50312583/206524515-ce57ba9d-b981-464d-8752-9ca10a1cfdb1.png)

2. Пользователь VPN, отправляющий запросы DNS за пределы зашифрованного туннеля
![dns-leak-3rd-party@2x-08291d1d4d48e0b4c1430ba77a653a2e39509e96a382440da0cb2f0b61687606 png](https://user-images.githubusercontent.com/50312583/206524560-bcbd86a9-8d04-42bb-af66-0dac5d6981e5.png)

Ваше устройство может отправлять DNS-запросы через VPN-туннель, но на сторонний DNS-сервер.
Диаграмма, на которой изображен пользователь VPN, отправляющий DNS-запросы через зашифрованный туннель, но на сторонний сервер
В обоих случаях третьи лица могут видеть все веб-сайты и приложения, которые вы используете.
