#!bin/bash
status_check() {
    if [ $1 -eq 0 ]; then
        echo -e "\e[32mSUCCESS\e[0m"
    else
        echo -e "\e[31mFAILURE\e[0m"
        exit 2
    fi
} 

print() {
    echo -e "\n\t\t\e[36m--------------------- $1 ----------------------\e[0m\n" >>$LOG
    echo -n -e "$1 \t-"
}

if [ $UID -ne 0 ]; then
    echo -e "\e[33mYou need to run the script with Sudo rights\e[0m"
    exit 1
fi

LOG=/tmp/roboshop.log
rm -f $LOG

ADD_APP_USER(){
    print "Adding Roboshop user"
    id roboshop &>>$LOG
    if [ $? -eq 0 ]; then
        echo -e "\n\e[35mUser already exists, skipping.\e[0m"
    else
        useradd roboshop &>>$LOG
    fi 
    status_check $?
}    

SystemD_Setup(){    
    print "Setting up Mongodb configuration in ${COMPONENT} service"
    sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>$LOG && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
    status_check $?

    print "Setting up and starting ${COMPONENT} service"
    systemctl daemon-reload && systemctl restart ${COMPONENT} && systemctl enable ${COMPONENT}
    status_check $?
}

DOOWNLOAD(){
    print "Download ${COMPONENT} components"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>$LOG
    status_check $?

    cd /home/roboshop
    print "Unzip ${COMPONENT} components"
    rm -rf ${COMPONENT} && unzip -o /tmp/${COMPONENT}.zip &>>$LOG && mv ${COMPONENT}-main ${COMPONENT}
    status_check $?
}

COMPONENT(){
    print "Installing NodeJS"
    yum install nodejs make gcc-c++ -y &>>$LOG
    status_check $?

    ADD_APP_USER
    DOOWNLOAD
    
    cd /home/roboshop/${COMPONENT}
    print "Download NodeJS dependencies"
    npm install --unsafe-perm &>>$LOG
    status_check $?

    chown roboshop:roboshop -R /home/roboshop

    SystemD_Setup
}