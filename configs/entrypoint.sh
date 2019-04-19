#!/bin/sh
set -xeuo pipefail
IFS=$'\n\t'

#UPDATE PASSWORD
echo "vsftp:${FTP_PASS}" | /usr/sbin/chpasswd -e

if [[ "${PASV_ENABLE}" == "YES" ]]; then
  echo "PASV is enabled"
  echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_addr_resolve=YES" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_max_port=${PASV_MAX}" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_min_port=${PASV_MIN}" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
else
  echo "pasv_enable=NO" >> /etc/vsftpd/vsftpd.conf
fi

if [[ "${ONLY_UPLOAD}" == "YES" ]]; then
  echo "This FTP server only accepts upload."
  echo "download_enable=NO" >> /etc/vsftpd/vsftpd.conf
  echo "ftpd_banner=Welcome to FTP Server. Note: this FTP server only accepts upload." >> /etc/vsftpd/vsftpd.conf
elif [[ "${ONLY_DOWNLOAD}" == "YES" ]]; then
  echo "This FTP server only accepts download."
  echo "ftpd_banner=Welcome to FTP Server. Note: this FTP server only accepts download." >> /etc/vsftpd/vsftpd.conf
  sed -i 's/write_enable=YES/write_enable=NO/g' /etc/vsftpd/vsftpd.conf
else
  echo "ftpd_banner=Welcome to FTP Server" >> /etc/vsftpd/vsftpd.conf
fi

echo "local_enable=YES
chroot_local_user=YES
background=YES
dirmessage_enable=YES
write_enable=YES
passwd_chroot_enable=NO
seccomp_sandbox=NO
vsftpd_log_file=/var/log/vsftpd.log
log_ftp_protocol=YES
local_root=/volume
chroot_local_user=YES
chroot_list_enable=NO
allow_writeable_chroot=YES
pasv_promiscuous=YES
max_clients=${MAX_CLIENTS}
max_per_ip=${MAX_PER_IP}
listen_ipv6=${LISTEN_IPV6}" >> /etc/vsftpd/vsftpd.conf

sed -i "s/anonymous_enable=YES/anonymous_enable=${ANONYMOUS_ENABLE}/" /etc/vsftpd/vsftpd.conf

cat /etc/vsftpd/vsftpd.conf|grep -v '^#'

mkdir -p /volume/upload
chown vsftp /volume/upload

/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
tail -F /var/log/vsftpd.log
