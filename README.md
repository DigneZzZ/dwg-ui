# ad-wireguard
Combination Wireguird + Adguard Home + Unbound (Latest)

Here is the start of combination
# Requirings:
* Docker
* Docker-compose


```bash
git clone https://github.com/dignezzz/ad-wireguard.git
cd ad-wireguard
nano docker-compose.yml

#then run
docker-compose up -d
```

## AFter Instalation
After install, follow to instruction:
Go to: http://10.2.0.100:3000/  
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
The unencrypted 1.1.1.1 is fine if you're sure the connection between your AGH instance and Cloudflare DNS won't be tampered. Otherwise use the encrypted endpoint, either https://cloudflare-dns.com/dns-query for unfiltered query or https://security.cloudflare-dns.com/dns-query for malware filtering. Note that ECH doesn't work if you're using unencrypted upstream.
