# DWG UI - Docker WireGuard (DWG) - Проект одного скрипта 
<img src="https://user-images.githubusercontent.com/50312583/231138618-750b4b04-ade0-4e67-852e-f103030684a9.png" width="400">
### Представляю вам лучшую сборку для самой быстрой настройки VPN сервера на WireGuard
### **DWG-UI** = AdGuard with DoH DNS +  Wireguard with UI (wg-easy) + Unbound 
Тема поддержки на моём форуме:
https://openode.ru/topic/116-dwg-ui/

Версия без UI: https://github.com/DigneZzZ/dwg-cli

Универсальный установщик выбор UI / без UI: https://github.com/DigneZzZ/dwg/

### UPD 05.05.23:  Добавил файл `./change.sh` чтобы можно было менять пароль и логин к AGH.

### [ENGLISH DOCS](https://github.com/DigneZzZ/dwg-ui/blob/main/README_EN.md)

# Требования
* Чистый пустой сервер.
* Поддерживаемые операционные системы: **Ubuntu 20.04, 22.04; Debian 11, Centos 8,9**

Скрипт устанавливает все автоматически.
Все комментарии по скрипту внутри в комментариях

### [4VPS.su](https://4vps.su/account/r/18170) Рекомендую - однозначно! Скорость до 2ГБ\с. В моих тестах самый быстрый был сервер в Швейцарии!
### [VDSina.ru](https://vdsina.ru/?partner=rwmhc7jbcg) Рекомендую VPS хостинг - по рефералке скидка 10%!!!: 	
1. Очень хорошая скорость (до 1гб/с)
2. Посуточные тарифы
3. Доступные тарифы мощных сборок.
4. Лояльность к VPN использованию серверов.
5. Очень приятный интерфейс,  ISP отдыхает.
### [AEZA.net](https://aeza.net/?ref=377137)  -  бонус +15% к пополнению
### [Melbicom](https://melbicom.ru/?from=44619)
Достаточно хорошая стабильность и связь в 1гб/с (причем с гарантиями не менее 100мбит\с)
### [Pq.Hosting](https://pq.hosting/?from=45709)
Все критерии закрыты и 1Гб/с
### [Fornex](https://fornex.com/code/jwo1cg/)
Базовый вариант на котором хотел бы отметить своё внимание. Претензий нет, кроме как скорость 100мбит/сек. (но хочется отметить, что скорость эта достаточно стабильная!)


# Самая быстрая установка - 1 минута

Запусти команду на чистом сервере

```bash
bash <(wget -qO- https://raw.githubusercontent.com/DigneZzZ/dwg-ui/main/setup.sh)
```

## Что установится:

0. Сначала установится Git, чтобы можно было скопировать мой репозиторий
1. Docker - последняя версия
2. Docker-compose - последняя версия
3. Wg-easy - интерактивный режим введения пароля для веб
4. AdGuard Home - интерактивный режим создания пользователя и пароля (можно оставить стандартным)
5. Unbound - все в стоке
6. apache2-utils - необходим для генерации хэш-паролей
7. ssh.sh - скрипт для смены порта SSH подключения
8. ufw.sh - скрипт для установки UFW Firewall.
9. Напомнит установить ufw-docker и сам закроет доступ извне! **ВНИМАНИЕ! Запускать только после того как создадите для себя клиента в WireGUARD!!!**

## Автор:

👤 ** Alexey **
* Git: [DigneZzZ](https://github.com/DigneZzZ)
* Site: [OpeNode.RU](https://openode.ru)

# Скриншоты
## Wireguard-Easy Web-UI
![image](https://user-images.githubusercontent.com/50312583/206703310-3bc8f759-91fa-42db-8d43-eca0050c70bf.png)

## Adguard Web-UI
![image](https://user-images.githubusercontent.com/50312583/206703207-f3bd39f1-72c7-458c-9893-ad2126a0d47b.png)



## После установки

### WG-Easy web-ui:
yo.ur.ip.xx:51821 
И останется ввести пароль который задавали на момент установки


### AdGuard HOME 
#### Заходим после установки:
http://10.2.0.100/  

### Login: **admin** 
### Password: **admin**
Пароль по умолчанию, при ручной установке: `a12345678`


## Предустановленный Adlists для Рунета в том числе:
* RU-Adlist
https://easylist-downloads.adblockplus.org/advblock.txt
* BitBlock
https://easylist-downloads.adblockplus.org/bitblock.txt
* Cntblock
https://easylist-downloads.adblockplus.org/cntblock.txt
* EasyList
https://easylist-downloads.adblockplus.org/easylist.txt
* Доп список от Шакала
https://schakal.ru/hosts/alive_hosts_ru_com.txt
* файл с разблокированными r.mail.ru и graph.facebook.com
https://schakal.ru/hosts/hosts_mail_fb.txt
---
* All DNS Servers
https://adguard-dns.io/kb/general/dns-providers/#cloudflare-dns
* DNS Perfomance list:
https://www.dnsperf.com/#!dns-resolvers

# Почему именно AdGuardHome, а не PiHole?
![image](https://user-images.githubusercontent.com/50312583/229718610-cfa5dc9b-08a6-4761-b8e7-f54315afab57.png)


