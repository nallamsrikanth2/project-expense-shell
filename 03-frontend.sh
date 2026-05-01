#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
    echo -e "$R please run the script inside the root user $N"
else
    echo -e "$G you are a super user $N"
fi

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$R $2 ... FAILURE $N"
    else
        echo -e "$G $2 ... SUCCESS $N"
    fi
}

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "install the nginx"

systemctl enable nginx  &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx   &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "remobe the files in html"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "download the frontend code"

cd /usr/share/nginx/html  &>>$LOG_FILE
VALIDATE $? "move to directory"

unzip /tmp/frontend.zip  &>>$LOG_FILE
VALIDATE $? "unzip the frontend code"

cp /home/ec2-user/shell-expense/expense.conf /etc/nginx/default.d/expense.conf  &>>$LOG_FILE
VALIDATE $? "copy the expense.comf"

systemctl restart nginx  &>>$LOG_FILE
VALIDATE $? "restart nginx"

echo -e "$G frontend server created successfully $N"
