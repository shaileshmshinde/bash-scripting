#!/bin/bash

ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3

TIME_WAIT=0
ESTABLISHED=0

NETSTAT="/bin/netstat"
AWK="/bin/awk"
SORT="/bin/sort"
UNIQ="/usr/bin/uniq"


/bin/echo "" > /tmp/out.txt

print_help() {
    echo "  -w|--warn)"
    echo "    Sets a warning level for requests per second. Default is: off"
    echo "  -c|--crit)"
    echo "    Sets a critical level for requests per second. Default is: off"
    echo "  -p|--port)"
    echo "    Sets a port"
    exit $ST_UK
}

EXPECTED_ARGS=6
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` -w 100 -c 200 -p 80"
  exit $E_BADARGS
fi

while test -n "$1"; do
    case "$1" in
        --warn|-w)
            warn=$2
            shift
            ;;
        --crit|-c)
            crit=$2
            shift
            ;;
        --port|-p)
            port=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit $ST_UK
            ;;
    esac
    shift
done

port=":$port$"

$NETSTAT -ant|$AWK -v p=$port '$4 ~ p {print $6}'|$SORT|$UNIQ -c > /tmp/out.txt 2>&1

TIME_WAIT=`cat /tmp/out.txt |grep TIME_WAIT|awk '{print $1}'`
ESTABLISHED=`cat /tmp/out.txt |grep ESTABLISHED|awk '{print $1}'`

if [ -z "$TIME_WAIT" ];
then
TIME_WAIT=0
fi

if [ -z "$ESTABLISHED" ];
then
ESTABLISHED=0
fi

perfdata="'TIME_WAIT'=$TIME_WAIT 'ESTABLISHED'=$ESTABLISHED"
output="'TIME_WAIT'=$TIME_WAIT 'ESTABLISHED'=$ESTABLISHED"

if [ ${ESTABLISHED} -ge ${warn} -a ${ESTABLISHED} -lt ${crit} ]
        then
            echo "WARNING - ${output} | ${perfdata}"
            exit $ST_WR
        elif [ ${ESTABLISHED} -ge ${crit} ]
        then
            echo "CRITICAL - ${output} | ${perfdata}"
        exit $ST_CR
        else
            echo "OK - ${output} | ${perfdata}"
            exit $ST_OK
        fi
