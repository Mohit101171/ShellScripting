#!bin/bash
source components/common.sh

print "Setting up mongodb repo\t\t"
echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
status_check $?

print "Installing Mongodb"
yum install -y mongodb-org &>>/tmp/roboshoplog
status_check $?

print "Congifuring mongodb config file to have ip 0.0.0.0"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
status_check $?

print "Enabling and starting mongodb service"
systemctl enable mongod
systemctl restart mongod
status_check $?

print "Donwloading Mongodb schema" 
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>/tmp/roboshoplog
status_check $?

cd /tmp

print "Unzipping mongodb schema archive"
unzip -o mongodb.zip &>>/tmp/roboshoplog
status_check $?

cd mongodb-main

print "Loading mongodb schema"
mongo < catalogue.js &>>/tmp/roboshoplog
mongo < users.js &>>/tmp/roboshoplog
status_check $?

exit 0