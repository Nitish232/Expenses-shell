#!/bin/bash

userid=$(id -u)
timestap=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$timestap.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter DB password : "
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R  FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi

}

if [ $userid -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1
else
    echo "You are super user."
fi

dnf install mysql-server -y &>>$logfile
VALIDATE $? "Installing Mysql Server"

systemctl enable mysqld &>>$logfile
VALIDATE $? "Enabling Mysql Server"

systemctl start mysqld &>>$logfile
VALIDATE $? "Starting mysql Server"

mysql -h 172.31.31.96 -uroot -p${mysql_root_password} -e 'show databases;' &>>$logfile
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$logfile
    VALIDATE $? "Mysql root password setup"
else
    echo -e "Mysql root Password is already setup...$Y SKIPPING $N"
fi