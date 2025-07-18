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

yum install maven -y  &>>$LOGFILE
VALIDATE $? "Installing Maven"

if [ ! -d /app ]; then
    mkdir /app &>>$LOGFILE
    VALIDATE $? "Creating /app directory"
else
    echo -e "/app already exists ... $Y SKIPPING $N"
fi


curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip   &>>$LOGFILE
VALIDATE $? "Downloading shipping artifact"


cd /app   &>>$LOGFILE
VALIDATE $? "moving to directory"


unzip /tmp/shipping.zip    &>>$LOGFILE
VALIDATE $? "unzip shipping"

mvn clean package &>>$LOGFILE
VALIDATE $? "packaging shipping app"


mv target/shipping-1.0.jar shipping.jar  &>>$LOGFILE
VALIDATE $? "renaming shipping jar"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "copying shipping service"


systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable shipping &>>$LOGFILE
VALIDATE $? "enable shipping"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "start shipping service"

yum install mysql -y  &>>$LOGFILE
VALIDATE $? "instalng mysql client"

mysql -h mysql.janadevops.fun -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>$LOGFILE
VALIDATE $? "Loaded countries and cities info"


systemctl restart shipping &>>$LOGFILE
VALIDATE $? " restart shipping"













