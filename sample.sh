#!/bin/bash
user_id=$(id -u)
script_name=$($0 | cut -d "." -f1)
time_stamp=$(date +%F-%H-%M-%S)
logfile=/tmp/$script_name-time_stamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
    if [$1 -ne 0]
    then
      echo -e "$2 $R installation failed $N"
      exit 1
    else
        echo -e "$2 $G installation success $N"
    fi
}

if [$user_id -ne 0]
then
    echo "please run this script in superuser"
    exit 1 #manually exit if error comes
else
    echo "you are alraedy superuser"
fi

for i in $@
do
   echo "package to install:$i"
   dnf list installed $i &>>logfile
   if [$? -e 0]
   then
      echo -e "$i $Y already installed $N"
    else
       dnf install $i -y &>>logfile
       validate $? "$i installation"
    fi
done    
      