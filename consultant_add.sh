#!/bin/bash
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'


logfile=/var/log/sftp_users.log
mkfifo ${logfile}.pipe
tee -a < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

expdate=$(date -d "365 days" +"%Y-%m-%d")
pass=$(openssl rand -base64 12)

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

echo -e "${YELLOW} What is the consultants name?${NC}"
read user

adduser --ingroup consultants --disabled-password --gecos ""  $user
echo $user:$pass | chpasswd
usermod $user --expiredate $expdate
chown $user:consultants /home/$user
mkdir /home/$user/uploads
chown $user:ftpaccess /home/$user/uploads

echo
echo -e "${YELLOW}User account ${RED}$user ${YELLOW}with password ${RED}$pass ${YELLOW}has been created and will expire on ${RED}$expdate ${NC}" 

echo "User account $user with password $pass will expire on $expdate" &>> $logfile

