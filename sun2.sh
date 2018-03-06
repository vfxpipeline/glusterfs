# UPDATE CENTOS
yum -y update
yum -y install epel-release
yum -y install gparted

# ADD HOST ENTRY
echo "192.168.0.7 sun1" >> /etc/hosts
echo "192.168.0.6 sun2" >> /etc/hosts

# MAKE DIRECTORY FOR MOUNT GLUSTER VOLUME
mkdir  -p /gluster

# MOUNT GLUSTER VOLUME ON STARTUP
echo "/dev/sda3 /gluster                    xfs    defaults        0 0" >> /etc/fstab
mount -a

# DISABLE AND STOP FIREWALL
systemctl disable firewalld
systemctl stop firewalld

# INSTALL GLUSTER 310 PACKAGES
yum -y install centos-release-gluster310
yum -y install glusterfs
yum -y install glusterfs-server

# ENABLE GLUSTER IN STARTUP
systemctl enable glusterd
systemctl start glusterd

# ADD POOLS IN GLUSTER
gluster peer probe sun1
gluster peer probe sun2

# CREATE DATA FOLDER 
mkdir -p /gluster/data

# RESTART GLUSTER SERVICE
systemctl restart glusterd

# CREATE A DIRECTORY TO MOUNT GLUSTER DATA 
mkdir /data/volume1 -p

# MOUNT GLUSTER DATA
echo "sun2:volume1 /data/volume1                    glusterfs    defaults        0 0" >> /etc/fstab
mount -a

# INSTALL CTDB AND SAMBA PACKAGES
yum install -y ctdb samba samba-common samba-winbind-clients samba-vfs-glusterfs

# MAKE SELINUX TO PERMISSIVE
setenforce 0

# REMOVE CTDBD.CONF FILE
rm -f /etc/ctdb/ctdbd.conf

# CREATE SYMLINKS TO CTDB DIRECTORY 
ln -s /data/volume1/ctdb/ctdbd.conf /etc/ctdb/ctdbd.conf
ln -s /data/volume1/ctdb/nodes /etc/ctdb/nodes
ln -s /data/volume1/ctdb/public_addresses /etc/ctdb/public_addresses

# STOP AND DISABLE SAMBA SERVICE
systemctl stop smb.service
systemctl disable smb.service

# ENABLE CTDB SERVICE
systemctl enable ctdb.service

# RESTART CTDB SERVICE
systemctl restart ctdb

# ADD USER TO ACCESS SHARE
useradd user01
smbpasswd -a user01








