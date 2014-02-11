#!/bin/bash
if [ -z $1 ]; then
        echo "Usages : $0 Vehical name"; exit 1;
elif
        [ -n $1 ]; then
        vehicale=$1
fi

case $vehicale in
"car")
        clear && echo ""
        echo "For $vehicale price is 10 Rs. per K/M."
        echo "";;
"jeep")
        clear && echo ""
        echo "For $vehicale price is 11 Rs. per K/M."
        echo "";;
"bmw")
        clear && echo ""
        echo "For $vehicale price is 31 Rs. per K/M."
        echo "";;
"bike")
        clear && echo ""
        echo "For $vehicale price is 7 Rs. per hour."
        echo "";;

*) clear && echo ""
         echo "$vehicale is not available; sorry for inconvience"
        echo ""
esac
