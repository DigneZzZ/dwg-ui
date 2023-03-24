apt update
apt install git -y
git clone https://github.com/dignezzz/ad-wireguard.git 
chmod +x ad-wireguard/install.sh 
./ad-wireguard/install.sh
chmod +x -R ad-wireguard/tools
./ad-wireguard/tools/ssh.sh
./ad-wireguard/tools/ufw.sh
./ad-wireguard/tools/ufw.docker
echo "Всё установлено!"
