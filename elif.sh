#!/bin/bash
read -p "Type any Number : " N

if      [ $N -gt 0 ];then
        echo "It's +Ve Number"

elif    [ $N -lt 0 ]; then
        echo "It's-Ve Number"

elif    [ $N -eq 0 ]; then
        echo "It's Zero"
else
        echo ""
        echo "It's not a number Type a number,"
fi
