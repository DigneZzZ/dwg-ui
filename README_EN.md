# English version

# Ad-WireGuard with UI = AdGuard with DoH DNS +  Wireguard with UI (wg-easy) + Unbound
Combination WireGuard (wg-easy latest) + Adguard Home + Unbound (Latest)

Here is the start of combination
# Requirings:
* Docker (include in install.sh for Debian 10-11, Ubuntu 20-22.04)
* Docker-compose (include in install.sh for Debian 10-11, Ubuntu 20-22.04)

These confinguration of AdGuard include DNS-over-HTTPS (DoH) via Cloudflare service by using DNS: https://cloudflare-dns.com/dns-query
Fow query to CF-DNS using Unbound. This is some type of DNS forwarding.

Recomendation VPS Hosting with 10% Discount: 	[VDSina.ru](https://vdsina.ru/?partner=rwmhc7jbcg)


# Quick Install
1. Clone the git and edit install-script
## CLEAR SERVER:
```bash
apt update && apt install git -y && git clone https://github.com/dignezzz/ad-wireguard.git && cd ad-wireguard && chmod +x install.sh && ./install.sh && cd 
```
## INSTALL Docker, Docker-Compose and Ad-WireGuard
```bash
git clone https://github.com/dignezzz/ad-wireguard.git && cd ad-wireguard && chmod +x install.sh && ./install.sh && cd 
```

## Autors:

👤 ** Alexey **
* Git: [DigneZzZ](https://github.com/DigneZzZ)
* Site: [OpeNode.RU](https://openode.ru)

👤 ** Dmitriy **
* Git [Nubortg](https://github.com/nubortg)


## Wireguard-Easy Web-UI
![image](https://user-images.githubusercontent.com/50312583/206703310-3bc8f759-91fa-42db-8d43-eca0050c70bf.png)

## Adguard Web-UI
![image](https://user-images.githubusercontent.com/50312583/206703207-f3bd39f1-72c7-458c-9893-ad2126a0d47b.png)



## After Installation

### WG-Easy web-ui:
yo.ur.ip.xx:51821 
And type password from script.

Then..  Connect to WireGuard!

### AGH
#### After ur connection to WG:
Go to: http://10.2.0.100/  

### Login: **admin** 
### Password: **a12345678**

## ATTENTION! Change admin username and/or password
### First way:
1. On the server:
```bash
sudo apt install apache2-utils 
htpasswd -nbB admin 'MyNewPassword'
```

2. Open ur configuration file of AGH:
```bash
nano ../ad-wireguard/conf/AdGuardHome.yaml
```
3. Change for NEW Name and Password:
```bash
users:
  - name: admin
    password: $2y$10$G7Qu8Y3szepMfaRUyQ.FmuKR.n4U9dHOQm.GgrIMuYC9UP8vmHJri
```
4. Recreate your container:
```bash
docker-compose up -d --force-recreate
```
### Second way:
1. Go to site: https://hostingcanada.org/htpasswd-generator/
2. Change Mode: **bcrypt**
3. Enter new Username and Password
4. Open ur configuration file of AGH:
```bash
nano ../ad-wireguard/conf/AdGuardHome.yaml
```
5. Change Name and Password:
```bash
users:
  - name: admin
    password: $2y$10$G7Qu8Y3szepMfaRUyQ.FmuKR.n4U9dHOQm.GgrIMuYC9UP8vmHJri
```
6. Recreate your container:
```bash
docker-compose up -d --force-recreate
```

Full information from AGH site: https://docs.cloudron.io/apps/adguard-home/

# Adlists:
### RU-Adlist
https://easylist-downloads.adblockplus.org/advblock.txt
### BitBlock
https://easylist-downloads.adblockplus.org/bitblock.txt
### Cntblock
https://easylist-downloads.adblockplus.org/cntblock.txt
### EasyList
https://easylist-downloads.adblockplus.org/easylist.txt
### Доп список от Шакала
https://schakal.ru/hosts/alive_hosts_ru_com.txt
### файл с разблокированными r.mail.ru и graph.facebook.com
https://schakal.ru/hosts/hosts_mail_fb.txt

# Upstream DNS-Servers
### About default DNS
  The unencrypted 1.1.1.1 is fine if you're sure the connection between your AGH instance and Cloudflare DNS won't be tampered. Otherwise use the encrypted endpoint, either https://cloudflare-dns.com/dns-query for unfiltered query or https://security.cloudflare-dns.com/dns-query for malware filtering. Note that ECH doesn't work if you're using unencrypted upstream.

### All DNS Servers
https://adguard-dns.io/kb/general/dns-providers/#cloudflare-dns

### DNS Perfomance list:
https://www.dnsperf.com/#!dns-resolvers

