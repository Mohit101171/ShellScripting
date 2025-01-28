#!bin/bash
source components/common.sh

print "Install yum-utils and download Redis Repos"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG
status_check $?

print "Setup Redis Repos\t\t\t"
yum-config-manager --enable remi &>>$LOG
status_check $?

print "Install Redis\t\t\t\t"
yum install redis -y &>>$LOG
status_check $?

print "Update the BindIP in redis.conf\t\t"

if [ -f /etc/redis.conf ]; then
 sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
fi 
if [ -f /etc/redis/redis.conf ]; then
 sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
fi 
status_check $?

print "Start Redis Service\t\t\t"
systemctl enable redis &>>$LOG && systemctl restart redis &>>$LOG
status_check $?