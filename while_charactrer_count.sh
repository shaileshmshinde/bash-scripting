#!/bin/bash
apple="$1"
a=0
b=0
d=0

[ $# -eq 0 ] && { echo "usages : $0 filename"; exit 1; }

[ ! -f $apple ] && { echo "File not found"; exit 2; }

while IFS= read -r -n1 don
do
        [[ $don == a ]] &&  (( a++ ))
        [[ $don == b ]] &&  (( b++ ))
        [[ $don == d ]] &&  (( c++ ))

done < "$apple"

echo "total letter counter"
echo "a=$a"
echo "b=$b"
echo "d=$d"
