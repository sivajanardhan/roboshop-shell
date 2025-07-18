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


curl -sL https://rpm.nodesource.com/setup_lts.x | bash  &>>$LOGFILE
VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? " installing node js "


id roboshop &>>$LOGFILE
if [ $? -ne 0 ]; then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Adding user roboshop"
else
    echo -e "User roboshop already exists ... $Y SKIPPING $N"
fi

if [ ! -d /app ]; then
    mkdir /app &>>$LOGFILE
    VALIDATE $? "creating app directory"
else
    echo -e "/app already exists ... $Y SKIPPING $N"
fi


curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "downloading user artifact"

if [ ! -d /app ]; then
    mkdir /app &>>$LOGFILE
    VALIDATE $? "Creating /app directory"
else
    echo -e "/app already exists ... $Y SKIPPING $N"
fi

VALIDATE $? "moving into app "

unzip /tmp/user.zip &>>$LOGFILE
VALIDATE $? " unzipping user"

npm install  &>>$LOGFILE
VALIDATE $? "installing npm"

cp /home/centos/roboshop-shell/user.service  /etc/systemd/system/user.service &>>$LOGFILE
VALIDATE $? "copying user.service"


systemctl daemon-reload &>>$LOGFILE
VALIDATE $? " deaon reaload"

systemctl enable user &>>$LOGFILE
VALIDATE $? "enabling user"
 
systemctl start user &>>$LOGFILE
VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "installing mongodb org shell"

mongo --host mongodb.janadevops.fun </app/schema/user.js &>>$LOGFILE
VALIDATE $? "loading user data into mongodb"








