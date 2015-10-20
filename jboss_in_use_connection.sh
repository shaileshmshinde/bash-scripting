#!/bin/bash

JBOSS_HOME=/usr/local/jboss-4.2.3.GA
JAVA_HOME=/usr/local/java
TWIDDLE=$JBOSS_HOME/bin/twiddle.sh
user=jbossadmin
pass=W00ker@dmin
hostname=192.168.20.25
WARN=120
CRITICAL=140

echo "" > /home/infra.mg/12Nov2014/out_jboss.txt

$TWIDDLE -u $user -p $pass -s $hostname get "jboss.jca:service=ManagedConnectionPool,name=WooqerDS" InUseConnectionCount MaxSize  >> /home/infra.mg/12Nov2014/out_jboss.txt

InUseConnectionCount=`cat /home/infra.mg/12Nov2014/out_jboss.txt|awk -F= '$1 ~ "InUseConnectionCount" {print $2}'`
MaxSize=`cat /home/infra.mg/12Nov2014/out_jboss.txt|awk -F= '$1 ~ "MaxSize" {print $2}'`

do_perfdata() {
perfdata="'InUseConnectionCount'=$InUseConnectionCount 'MaxSize'=$MaxSize"
}

do_output() {
output="Connections in use for WooqerDS : $InUseConnectionCount , Max Connection is $MaxSize"
}

do_output
do_perfdata

######
 rm -f /var/lib/check_mk_agent/job/twiddle.log


if [ $InUseConnectionCount -gt $CRITICAL ]; then
  echo "CRITICAL - ${output} | ${perfdata}"
  exit 2
else
  if [ $InUseConnectionCount -ge $WARN ]; then
        echo "WARN - ${output} | ${perfdata}"
        exit 1
  else
        echo "OK - ${output} | ${perfdata}"
        exit  0
  fi
fi
