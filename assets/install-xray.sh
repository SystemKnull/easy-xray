#!/bin/bash

# load uuid and path 
source params.txt

yum install -y unzip wget net-tools epel-release openssl

pkg_url="https://github.com/XTLS/Xray-core/releases/download/v1.4.2/Xray-linux-64.zip"
tmp_dir=/tmp/xray

mkdir -p $tmp_dir
wget $pkg_url -O xray.zip
unzip xray.zip -d $tmp_dir

cp $tmp_dir/xray /usr/local/bin
cp $tmp_dir/*.dat /usr/local/bin
cp -f "./assets/xray.service" "/lib/systemd/system/"

logDir=/var/log/xray
mkdir -p $logDir
touch $logDir/access.log
touch $logDir/error.log
chown -R nobody $logDir


# generate config
config_dir=/usr/local/etc/xray
mkdir -p $config_dir
sed "s/xray_uuid/$uuid/" ./assets/config.json >  $config_dir/config.json


# setup nginx
yum install -y nginx

domain=$(/usr/sbin/ifconfig eth0 | grep 'inet ' | awk '{print $2}')
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout  /etc/nginx/server.key -out  /etc/nginx/server.crt -subj "/C=US/ST=Zhejiang/L=Hangzhou/O=haha/OU=haha/CN=$domain"

sed "s#xray_path#$path#" ./assets/nginx.conf > /etc/nginx/nginx.conf


# start services
systemctl enable nginx
systemctl enable xray
systemctl start nginx
systemctl start xray


