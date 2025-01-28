#!bin/bash
source components/common.sh

print "Installing Nginx\t\t"
yum install nginx -y &>>$LOG
status_check $?

print "Downloading HTDOCS for frontend page"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG
status_check $?

print "Unzip HTDOCS for frontend page\t"
cd /usr/share/nginx && rm -rf * &&  unzip /tmp/frontend.zip &>>$LOG && mv frontend-main/* . && mv static html &>>$LOG 
status_check $?

print "Copy Nginx R0boshop Config\t"
# rm -rf frontend-master static README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
status_check $?

print "Update Nginx Roboshop Config\t"
sed -i -e '/catalogue/ s/localhost/catalogue.roboshop.internal/' /etc/nginx/default.d/roboshop.conf &>>$LOG
sed -i -e '/user/ s/localhost/user.roboshop.internal/' /etc/nginx/default.d/roboshop.conf &>>$LOG
sed -i -e '/cart/ s/localhost/cart.roboshop.internal/' /etc/nginx/default.d/roboshop.conf &>>$LOG
sed -i -e '/shipping/ s/localhost/shipping.roboshop.internal/' /etc/nginx/default.d/roboshop.conf &>>$LOG
sed -i -e '/payment/ s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf &>>$LOG
status_check $?

print "Restarting Nginx service"
systemctl restart nginx &>>$LOG systemctl enable nginx &>>$LOG
status_check $?
