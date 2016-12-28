#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
expdate = 'date -d "7 days" +"%Y-%m-%d"'

echo "What is the new user's name?"
read user

adduser $user -e $expdate --ingroup ftpaccess --shell /usr/sbin/nologin
chown root:root /home/$user
mkdir /home/$user/upload
chown $user:ftpaccess /home/$user/upload


