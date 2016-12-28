#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
##Working directories
gitdir=$PWD
logfile=/var/log/sftp_install.log
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
chmod +x adduser.sh
chown root:root adduser.sh
mv adduser.sh ~

##Updates and stuff
print_status "${YELLOW}Adding Repos/Depos...Please Wait${NC}"
print_notification "Updating and installing openssh-server unattended-upgrades apt-listchanges fail2ban ufw"
apt-get update -y &>> $logfile 
apt-get upgrade -y &>> $logfile 
apt-get install openssh-server unattended-upgrades apt-listchanges fail2ban ufw -y  &>> $logfile
error_check 'Updates and depos installation'
ufw limit OpenSSH  &>> $logfile

##Banner
cp $gitdir/issue /etc/ssh/

##Modifying config 
print_status "${YELLOW}Modifying SFTP configuration${NC}"
##Remove unwanted configs
sed -i '\|X11Forwarding yes|d' /etc/ssh/sshd_config &>> $logfile 
sed -i '\|X11DisplayOffset 10|d' /etc/ssh/sshd_config &>> $logfile 
sed -i '\|Subsystem sftp /usr/lib/openssh/sftp-server|d' /etc/ssh/sshd_config &>> $logfile 
##Adding wanted configs
echo "Subsystem sftp internal-sftp" | sudo tee -a /etc/ssh/sshd_config &>> $logfile 
echo "Match group ftpaccess" | sudo tee -a /etc/ssh/sshd_config &>> $logfile 
echo "ChrootDirectory %h" | sudo tee -a /etc/ssh/sshd_config &>> $logfile 
echo "X11Forwarding no" | sudo tee -a /etc/ssh/sshd_config &>> $logfile 
echo "AllowTcpForwarding no" | sudo tee -a /etc/ssh/sshd_config &>> $logfile 
echo "ForceCommand internal-sftp" | sudo tee -a /etc/ssh/sshd_config &>> $logfile 
echo "Banner /etc/ssh/issue" | sudo tee -a /etc/ssh/sshd_config &>> $logfile 
 
 ##Restart service with new configs
service ssh restart &>> $logfile 
error_check 'SFTP configuration changes'

##Create FTP Group
print_status "${YELLOW}Creating group for SFTP users${NC}"
addgroup ftpaccess &>> $logfile 
error_check 'SFTP Users group'

##Remove files
cd ~
rm -rf $gitdir/sftp_server

print_status "${YELLOW}Configuration Complete...Run the adduser.sh script to create a SFTP user.${NC}"








