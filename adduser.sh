#!/bin/bash
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'


logfile=/var/log/sftp_users.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

expdate=$(date -d "7 days" +"%Y-%m-%d")
pass=$(openssl rand -base64 10)

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

echo -e "${YELLOW} What is the new user's name?${NC}"
read user

adduser --ingroup ftpaccess --shell /usr/sbin/nologin --disabled-password --gecos ""  $user
echo $pass | passwd $user --stdin
usermod $user --expiredate $expdate
chown root:root /home/$user
mkdir /home/$user/uploads
chown $user:ftpaccess /home/$user/uploads

echo
echo -e "${YELLOW}User account ${RED}$user ${YELLOW}with password ${RED}$pass ${YELLOW}has been created and will expire on ${RED}$expdate ${NC}" 

echo -e "${YELLOW}User account ${RED}$user ${YELLOW}with password ${RED}$pass ${YELLOW}has been created and will expire on ${RED}$expdate ${NC}" &>> $logfile

