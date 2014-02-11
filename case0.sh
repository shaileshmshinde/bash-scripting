#!/bin/bash
today=$(date +%a)
case $today in
        Mon|Tue|Wed)
        echo "Today is $today Full backup" ;;
        
        Thur|Fri)
        echo "Today is $today differential backup" ;;
        
        Sat|Sun)
        echo "No Backup today";;

*) ;;
esac
