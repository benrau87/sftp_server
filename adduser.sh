#!/bin/bash
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
expdate=$(date -d "7 days" +"%Y-%m-%d")

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

echo -e "${YELLOW} What is the new user's name?${NC}"
read user

useradd $user --ingroup ftpaccess --shell /usr/sbin/nologin
usermod $user --expiredate $expdate
chown root:root /home/$user
mkdir /home/$user/upload
chown $user:ftpaccess /home/$user/upload

echo -e "${YELLOW}User account ${RED}$user ${YELLOW}has been created and will expire on ${RED}$expdate ${NC}"

