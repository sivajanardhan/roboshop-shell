#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$(basename $0)
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

# Setup NodeJS
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "Setting up NodeJS repo"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing NodeJS"

# Add user roboshop if not exists
id roboshop &>>$LOGFILE
if [ $? -ne 0 ]; then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "User roboshop already exists ... $Y SKIPPING $N"
fi

# Create /app directory if not exists
if [ ! -d /app ]; then
    mkdir /app &>>$LOGFILE
    VALIDATE $? "Creating /app directory"
else
    echo -e "/app directory already exists ... $Y SKIPPING $N"
fi

# Download and extract application
curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "Downloading user artifact"

cd /app &>>$LOGFILE
VALIDATE $? "Moving into app directory"

unzip -o /tmp/user.zip &>>$LOGFILE
VALIDATE $? "Unzipping user"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

# Set up systemd service
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE
VALIDATE $? "Copying user.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable user &>>$LOGFILE
VALIDATE $? "Enabling user service"

systemctl start user &>>$LOGFILE
VALIDATE $? "Starting user service"

# MongoDB setup
cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "Copying mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.janadevops.fun </app/schema/user.js &>>$LOGFILE
VALIDATE $? "Loading user data into MongoDB"
