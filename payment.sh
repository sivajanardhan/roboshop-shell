
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

yum install python36 gcc python3-devel -y &>>$LOGFILE

VALIDATE $? "Installing python"

# useradd roboshop &>>$LOGFILE
id roboshop &>>$LOGFILE
if [ $? -ne 0 ]; then
  useradd roboshop &>>$LOGFILE
  VALIDATE $? "Creating roboshop user"
else
  echo -e "roboshop user already exists ... $Y SKIPPING $N"
fi


# mkdir /app  &>>$LOGFILE
if [ ! -d /app ]; then
  mkdir /app  &>>$LOGFILE
  VALIDATE $? "Creating /app directory"
else
  echo -e "/app already exists ... $Y SKIPPING $N"
fi


curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE

VALIDATE $? "Downloading artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/payment.zip &>>$LOGFILE

VALIDATE $? "unzip artifact"

pip3.6 install -r requirements.txt &>>$LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE

VALIDATE $? "copying payment service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable payment  &>>$LOGFILE

VALIDATE $? "enable payment"

systemctl start payment &>>$LOGFILE

VALIDATE $? "starting payment"
