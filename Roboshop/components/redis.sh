#!bin/bash
source components/common.sh

print "Install yum-utils and download Redis Repos"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG
status_check $?

print "Setup Redis Repos"
yum-config-manager --enable remi &>>$LOG
status_check $?

print "Install Redis"
yum install redis -y &>>$LOG
status_check $?

print "Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf"

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
status_check $?

print "Start Redis Service"
systemctl enable redis &>>$LOG && systemctl start redis $>>$LOG