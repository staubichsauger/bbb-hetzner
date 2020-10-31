#!/bin/bash

# ---------------------- Setup requirements
ip addr add ${floating_ip} dev eth0

apt-get update
apt-get install -yqq \
 apt-transport-https \
 ca-certificates \
 curl \
 gnupg2 \
 software-properties-common \
 git \
 ufw

# ---------------------- Install docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io

curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# ---------------------- Setup volume
mkdir -p /home/bbb
cd /home/bbb
mkdir -p /var/data
mount /dev/sdb /var/data

# ---------------------- Setup BBB
git clone --recurse-submodules https://github.com/alangecker/bigbluebutton-docker.git bbb-docker
cd bbb-docker/
cp /var/data/bbb-env .env
rm docker-compose.https.yml

cp /tmp/https.yml docker-compose.https.yml

./scripts/compose up

./scripts/compose exec greenlight bundle exec rake admin:create
while [ $? -ne 0 ]; do
    sleep 30
    ./scripts/compose exec greenlight bundle exec rake admin:create
done

ufw enable
ufw allow 22/tcp
ufw allow 80
ufw allow 443
ufw allow 3478
ufw allow 465
ufw allow 16384:32768/udp
ufw allow 3008
ufw allow 5143
ufw default deny
