#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Root check
if [ $USERID -ne 0 ]
then
    echo -e "$R Please run the script as root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

# Validation function
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2 ... FAILURE $N"
        exit 1
    else
        echo -e "$G $2 ... SUCCESS $N"
    fi
}

# Install MySQL
dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL server"

# Enable MySQL
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysqld"

# Start MySQL
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting mysqld"

# Check root password
mysql -h db.nsrikanth.online -uroot -pExpenseApp@1 -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    VALIDATE $? "Setting root password"
else
    echo -e "$Y Root password already set $N"
fi

echo -e "$G DB server setup completed successfully $N" &>>$LOG_FILE