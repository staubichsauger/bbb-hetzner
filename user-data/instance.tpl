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
 git
# ufw

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
mkdir -p /var/data/letsencrypt
mkdir -p /var/data/postgres-data

# ---------------------- Setup BBB
git clone --recurse-submodules https://github.com/alangecker/bigbluebutton-docker.git bbb-docker
cd bbb-docker/
cp /tmp/bbb-env .env
rm -f postgres-data
ln -s /var/data/postgres-data postgres-data

# Taken from bbb-docker/scripts/setup
RANDOM_1=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 40)
RANDOM_2=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 40)
RANDOM_3=$(head /dev/urandom | tr -dc a-f0-9 | head -c 128)
sed -i "s/SHARED_SECRET=.*/SHARED_SECRET=$RANDOM_1/" .env
sed -i "s/ETHERPAD_API_KEY=.*/ETHERPAD_API_KEY=$RANDOM_2/" .env
sed -i "s/RAILS_SECRET=.*/RAILS_SECRET=$RANDOM_3/" .env

# Set variables injected by terraform
sed -i "s#EXTERNAL_IPv4=.*#EXTERNAL_IPv4=${floating_ip}#" .env
sed -i "s#DOMAIN=.*#DOMAIN=${dnsname}#" .env

rm docker-compose.https.yml
cp /tmp/https.yml docker-compose.https.yml

if [ -f "/var/data/images.tar" ]; then
    echo importimages >> /tmp/msg
    docker image load -i /var/data/images.tar
fi

./scripts/compose up -d

while [ $(bash /home/bbb/bbb-docker/scripts/compose ps | wc -l) -lt 5 ]; do
    echo waiting
    sleep 10
done

sleep 300

echo createuser >> /tmp/msg
./scripts/compose exec -T greenlight bundle exec rake admin:create[admin,${admin_email},${admin_pwd},admin]

#ufw enable
#ufw allow 22/tcp
#ufw allow 80
#ufw allow 443
#ufw allow 3000:4000/tcp
#ufw allow 3000:4000/udp
#ufw allow 465
#ufw allow 16384:32768/udp
#ufw allow 5143
#ufw default deny

echo "------------------------------ started ------------------------------"

docker image save -o /var/data/images.tar $(docker images bbb-docker* | tail -n +2 | sed 's#.*\(bbb-[a-z]\+_[a-z0-9]\+-\?[a-z]*\).*#\1#' | tr '\n' ' ')

echo "------------------------------ done ---------------------------------"
