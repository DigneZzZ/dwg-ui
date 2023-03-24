apt update
apt install git -y
git clone https://github.com/dignezzz/ad-wireguard.git 
chmod +x ad-wireguard/install.sh 
./ad-wireguard/install.sh
chmod +x -R ad-wireguard/tools
./ad-wireguard/tools/ssh.sh
./ad-wireguard/tools/ufw.sh
echo "Всё установлено!"
echo "Не забудь отдельно установить UFW-Docker, для закрытия веб-интерфейса wireguard."
echo "команда для установки: ./ad-wireguard/tools/ufw.docker"
