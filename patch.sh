cat patch.sh
#!/bin/bash

cd /root && pwd

#[ ! -d /root/openssl ] && echo "creating directory openssl" && mkdir openssl && cd openssl
if [ ! -d /root/openssl ]
        then mkdir openssl && cd openssl
else cd openssl
fi
/bin/pwd

/usr/bin/wget http://10.0.4.18/install/kickstart/cos/6.4_x64/dvd-1/Packages/openssl098e-0.9.8e-17.el6.centos.2.x86_64.rpm
/usr/bin/wget http://10.0.4.18/install/kickstart/cos/6.4_x64/dvd-1/Packages/openssl-1.0.0-27.el6.x86_64.rpm
/usr/bin/wget http://10.0.4.18/install/kickstart/cos/6.4_x64/dvd-1/Packages/openssl-devel-1.0.0-27.el6.x86_64.rpm
echo "wget completed"
rpm -e --nodeps openssl10-libs-1.0.1e-1.ius.centos6.i686 openssl10-libs-1.0.1e-1.ius.centos6.x86_64 openssl10-1.0.1e-1.ius.centos6.x86_64
rpm -Uhv --force openssl-1.0.0-27.el6.x86_64.rpm openssl-devel-1.0.0-27.el6.x86_64.rpm
yum -y install openssl/*
yum -y update
#[ $? -eq 0 ] && echo "Rebooting server `init 6` " || {echo "some error"; exit 1 ; }
