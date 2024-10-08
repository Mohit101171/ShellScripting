#!bin/bash
source components/common.sh

print "Installing NodeJS"
yum install nodejs make gcc-c++ -y &>>$LOG
status_check $?

print "Adding Roboshop user"
id roboshop &>>$LOG
if [ $? -eq 0 ]; then
    echo -e "\n\e[35mUser already exists, skipping.\e[0m"
else
    useradd roboshop &>>$LOG
fi 
status_check $?

print "Download catalogue components"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>$LOG
status_check $?

cd /home/roboshop
print "Unzip catalogue components"
rm -rf catalogue && unzip -o /tmp/catalogue.zip &>>$LOG && mv catalogue-main catalogue
status_check $?

cd /home/roboshop/catalogue
print "Download NodeJS dependencies"
npm install --unsafe-perm &>>$LOG
status_check $?

print "Setting up Mongodb configuration in catalogue service"
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/catalogue/systemd.service &>>$LOG && mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
status_check $?

print "Setting up and starting Catalogue service"
systemctl daemon-reload && systemctl restart catalogue && systemctl enable catalogue
status_check $?