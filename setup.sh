#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
##Working directories
gitdir=$PWD
logfile=/var/log/cuckoo_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

##Colors!!
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

##Functions!!
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

function error_check
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully completed."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}
export DEBIAN_FRONTEND=noninteractive

##Begin scripting
print_status "${YELLOW}Adding Repos/Depos...Please Wait${NC}"
apt-get update &>> $logfile 
apt-get install openssh-server unattended-upgrades apt-listchanges fail2ban ufw -y  &>> $logfile
ufw limit OpenSSH  &>> $logfile
error_check 'Updates and depos installation'

##Create FTP Group
addgroup ftpaccess
print_status "${YELLOW}Configuration Complete${NC}"







