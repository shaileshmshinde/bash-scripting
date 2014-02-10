#!/bin/bash
read -p "please put your username : " username
grep -iq $username /etc/passwd  || { echo "No such id found" ; exit 1;}
read -p "type your password : " passwd
echo $passwd |pamtester login $username authenticate
