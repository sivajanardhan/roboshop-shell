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






yum module enable redis:remi-6.2 -y &>>$LOGFILE
VALIDATE $? "enabling redis 6.2 "

yum install redis -y &>>$LOGFILE
VALIDATE $? "Installing Redis 6.2 "


sed -i 's/127.0.0.1/0.0.0.0/g'   /etc/redis.conf  /etc/redis/redis.conf &>>$LOGFILE
VALIDATE $? "Allowing Remote connections to redis"

systemctl enable redis &>>$LOGFILE
VALIDATE $? "enabling redis"


systemctl start redis &>>$LOGFILE
VALIDATE $? "starting redis"