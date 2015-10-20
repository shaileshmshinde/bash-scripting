#!/bin/bash

JBOSS_HOME=/usr/local/jboss-4.2.3.GA
JAVA_HOME=/usr/local/java
TWIDDLE=$JBOSS_HOME/bin/twiddle.sh
user=jbossadmin
pass=W00ker@dmin
hostname=192.168.20.26
WARN=95
CRITICAL=98
FREEMEM_WARN=15
FREEMEM_CRITICAL=10

echo "" > /tmp/out_jboss.txt

$TWIDDLE -u $user -p $pass -s $hostname get "jboss.system:type=ServerInfo" MaxMemory FreeMemory > /tmp/out_jboss.txt
$TWIDDLE -u $user -p $pass -s $hostname get "jboss.jca:service=ManagedConnectionPool,name=WooqerDS" InUseConnectionCount MaxSize  >> /tmp/out_jboss.txt
$TWIDDLE -u $user -p $pass -s $hostname get "jboss.web:type=ThreadPool,name=ajp-192.168.20.26-8009" currentThreadsBusy maxThreads >> /tmp/out_jboss.txt

MaxMemory=`cat /tmp/out_jboss.txt|awk -F= '$1 ~ "MaxMemory" {print $2}'`
FreeMemory=`cat /tmp/out_jboss.txt|awk -F= '$1 ~ "FreeMemory" {print $2}'`
InUseConnectionCount=`cat /tmp/out_jboss.txt|awk -F= '$1 ~ "InUseConnectionCount" {print $2}'`
MaxSize=`cat /tmp/out_jboss.txt|awk -F= '$1 ~ "MaxSize" {print $2}'`
currentThreadsBusy=`cat /tmp/out_jboss.txt|awk -F= '$1 ~ "currentThreadsBusy" {print $2}'`
maxThreads=`cat /tmp/out_jboss.txt|awk -F= '$1 ~ "maxThreads" {print $2}'`


MaxMemory=`expr $MaxMemory / 1048576`
FreeMemory=`expr $FreeMemory / 1048576`


equal_dat=$FreeMemory
total_dat=$MaxMemory
Freememp=`expr $equal_dat \* 100 / $total_dat`

equal_dat=$InUseConnectionCount
total_dat=$MaxSize
InUseConnectionCountp=`expr $equal_dat \* 100 / $total_dat`

equal_dat=$currentThreadsBusy
total_dat=$maxThreads
currentThreadsBusyp=`expr $equal_dat \* 100 / $total_dat`

do_perfdata() {
perfdata="'MaxMemory'=$MaxMemory 'FreeMemory'=$FreeMemory 'InUseConnectionCount'=$InUseConnectionCount 'MaxSize'=$MaxSize 'currentThreadsBusy'=$currentThreadsBusy 'maxThreads'=$maxThreads"
}

do_output() {
output="Free Memory : $Freememp%, Connections in use for WooqerDS : $InUseConnectionCount%, AJP Busy threads : $currentThreadsBusyp%"
}

do_output
do_perfdata

######
 rm -f /var/lib/check_mk_agent/job/twiddle.log

if [ $Freememp -lt $FREEMEM_CRITICAL -o $InUseConnectionCountp -gt $CRITICAL -o $currentThreadsBusyp -gt $CRITICAL ]; then
  echo "CRITICAL - ${output} | ${perfdata}"
  exit 2
else
  if [ $Freememp -le $FREEMEM_WARN -o $InUseConnectionCountp -ge $WARN -o $currentThreadsBusyp -ge $WARN ]; then
        echo "WARN - ${output} | ${perfdata}"
        exit 1
  else
        echo "OK - ${output} | ${perfdata}"
        exit  0
  fi
fi
