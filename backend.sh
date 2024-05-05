#!/bin/bash

userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter DB password :"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2....$R FAILURE $N"
        exit 1
    else
        echo -e "$2....$G Success $N"
    fi
}

if [ $userid -ne 0 ]
then 
    echo "Please run this script with super user"
    exit 1
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$logfile
VALIDATE $? "Diabling default nodejs"

dnf module enable nodejs:20 -y &>>$logfile
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$logfile
VALIDATE $? "installinh node js 20"

id expense &>>$logfile
if [ $? -ne 0 ]
then 
    useradd expense &>>$logfile
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y skipping $N"
fi

mkdir -p /app &>>logfile
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>logfile
VALIDATE $? "Downloading  backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>logfile
VALIDATE $? "Extracted backend code"

npm install &>>logfile
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/Expenses-shell/backend.service /etc/systemd/system/backend.service &>>$logfile
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$logfile
VALIDATE $? "Daemon reload"

systemctl start backend &>>$logfile
VALIDATE $? "Starting backend"

systemctl enable backend &>>$logfile
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$logfile
validate $? "Installing mysql client"

mysql -h 172.31.31.96 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$logfile
VALIDATE $? "Schema loading"

systemctl restart backend &>>$logfile
VALIDATE $? "Restarting backend"
