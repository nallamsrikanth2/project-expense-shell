#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "enter the password"
read -s password

if [ $USERID -ne 0 ]
then
    echo -e "$R please run the script inside the root server $N"
else
    echo -e  "$G you are a super user $N"
fi

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$R $2 ... FAILURE $N"
    else
        echo -e "$G $2 ... SUCCESS $N"
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enable nodejs 20"

dnf install nodejs -y   &>>$LOG_FILE
VALIDATE $? "install nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "create the user"
else
    echo -e "$Y already created $N"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "craete the app directory"
rm -rf /app/*  &>>$LOG_FILE
VALIDATE $? "remove the everything app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOG_FILE
VALIDATE $? "download the code"

cd /app  &>>$LOG_FILE
VALIDATE $? "move to app directory"

npm install  &>>$LOG_FILE
VALIDATE $? "install the libreries"

cp /home/ec2-user/shell-expense/backend.service /etc/systemd/system/backend.service  &>>$LOG_FILE
VALIDATE $? "move to backend.service file"

systemctl daemon-reload  &>>$LOG_FILE
VALIDATE $? "daemon reload"

systemctl start backend  &>>$LOG_FILE
VALIDATE $? "start backend"

systemctl enable backend  &>>$LOG_FILE
VALIDATE $? "enable backend"

dnf install mysql -y   &>>$LOG_FILE
VALIDATE $? "install mysql"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -p$"{password}" < /app/schema/backend.sql  &>>$LOG_FILE
VALIDATE $? "load the schema"

systemctl restart backend  &>>$LOG_FILE
VALIDATE $? "restart the backend"

echo -e "$G backend server created sucessfully $N"