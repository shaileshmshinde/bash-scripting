#!/bin/bash
clear
echo ""
uname -a |awk '{print $1,$3}'
echo ""
ssh -V  2>&1 |head -n 1|awk -F", " '{print $1}'
echo ""
httpd -V  2>&1 |head -n 1|awk -F" " '{print $3}'
echo ""
php -v  2>&1 |awk  'NR ==1{print $1,$2};/Zend/{print $1,$2,$3}'
echo ""
read -p "Provide your Application Server path : " waspath

if      [ ! -z $waspath ]
then    bash ${waspath}/bin/versionInfo.sh|sed -n '/Installed Product/ {n;n;N;p}'
        echo "WebSphere" `${waspath}/java/bin/java -version 2>&1|awk 'NR == 1'`
        ${waspath}/java/bin/java -cp /opt/IBM/Informix_JDBC_Driver/lib/ifxjdbc.jar com.informix.jdbc.Version
else    echo "Application Server path not found!!!"
fi

echo ""
read -p "Provide directory path of your server.xml file : "  serverxml
echo ""

if [ ! -z $serverxml ]
then
echo  `cat $serverxml/server.xml | grep -oP "genericJvmArguments=\".*\" " | sed 's/.*(\".*\")//'`
else echo "server.xml is not in this path or path is incorrect"
fi
echo ""
