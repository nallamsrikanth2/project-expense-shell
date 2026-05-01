#!/bin/bash

USERIS=$(id -u)
TIMESTAP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

echo "entet your password"
read -s password

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
    echo -e "$R please run the script in inside the root user  $N"
else
    echo -e "$G you are root user $N"
fi

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$R $2 ... FAILURE $N"
    else
        echo -e "$G $2 ... SUCCESS $N"
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "install the mysql server"

systemctl enable mysqld  &>>$LOG_FILE
VALIDATE $? "enable mysqld"

mysql -h db.nsrikanth.online -uroot -pExpenseApp@1 -e 'shoe databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass -p"${password}" &>>$LOG_FILE
    VALIDATE $? "set up root password"
else
    echo "root password alredy setup"
fi


echo -e "$G db server successfully created $N" $>>$LOG_FILE




