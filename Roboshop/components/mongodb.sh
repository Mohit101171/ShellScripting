#!bin/bash

echo "Setting up mongodb repo"
echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo

echo "Installing Mongodb"
yum install -y mongodb-org &>>/tmp/roboshoplog

echo "Congifuring mongodb config file to have ip 0.0.0.0"
sed -i -e 's/127.0.0.1/0.0.0.0' /etc/mongod.conf

echo "Enabling and starting mongodb service"
systemctl enable mongod
systemctl restart mongod

echo "Donwloading Mongodb schema" 
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>/tmp/roboshoplog

cd /tmp

echo "Unzipping mongodb schema archive"
unzip mongodb.zip &>>/tmp/roboshoplog
cd mongodb-main

echo "Loading mongodb schema"
mongo < catalogue.js &>>/tmp/roboshoplog
mongo < users.js &>>/tmp/roboshoplog