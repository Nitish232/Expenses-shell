userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2....$R FAILURE $N"
        exit 1
    else 
        echo -e "$2....$R Success $N"
    fi
}

if [ $userid -ne 0 ]
then 
    echo "Please run this script with root access."
    exit 1
else 
    echo "You are super user."
fi

dnf install nginx -y &>>$logfile
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$logfile
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$logfile
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$logfile
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$logfile
unzip /tmp/frontend.zip &>>$logfile
VALIDATE $? "Extracting frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$logfile
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$logfile
VALIDATE $? "Restarting nginx"
