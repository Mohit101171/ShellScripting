#!bin/bash
source components/common.sh

print "Setting up mongodb repo\t\t\t\t"
echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >>/etc/yum.repos.d/mongodb.repo
status_check $?

print "Installing Mongodb\t\t\t\t"
yum install -y mongodb-org &>>$LOG
status_check $?

print "Congifuring mongodb config file to have ip 0.0.0.0"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
status_check $?

print "Enabling and starting mongodb service\t\t"
systemctl enable mongod
systemctl restart mongod
status_check $?

print "Donwloading Mongodb schema\t\t\t" 
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>$LOG
status_check $?

cd /tmp

print "Unzipping mongodb schema archive\t\t"
unzip -o mongodb.zip &>>$LOG
status_check $?

cd mongodb-main

print "Loading mongodb schema\t\t\t\t"
mongo < catalogue.js &>>$LOG
mongo < users.js &>>$LOG
status_check $?

exit 0