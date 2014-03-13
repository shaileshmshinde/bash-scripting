#!/bin/bash
while true
do
        clear
        cat <<-XXX
            Server name is $(hostname)
            *******************************
              Main Menu
            *******************************
            [1] Check current time
            [2] Check current user activity
            [3] Check Network activty current time
            [4] Exit
        XXX
read -p "Enter your choice : " choice
case $choice in
        1) echo "Today date is $(date)"
                read -p "Please press [Enter] to continue.." readenter
        ;;
        2) echo "$(w)"
                read -p "Please press [Enter] to continue.." readenter
        ;;
        3) echo "$(netstat -nat)"
                read -p "Please press [Enter] to continue.." readenter
        ;;
        4) exit 0 && echo BYE
        ;;
        *) echo "Invalid Option; select option again."
esac

done
