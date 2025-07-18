#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "settingup npm source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs "

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>>$LOGFILE
VALIDATE $? "downloading articaft file "

cd /app  &>>$LOGFILE
VALIDATE $? "moving into app directory "

unzip /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "unzipping catalogue"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service  &>>$LOGFILE
VALIDATE $? "catalogue.service"
systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "loading data"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo  /etc/yum.repos.d/mongo.repo &>>$LOGFILE

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "instllling mongodb org shell" 

mongo --host mongodb.janadevops.fun </app/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "loading catalogue data into mongodb"





