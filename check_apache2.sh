#!/bin/sh

PROGNAME=`basename $0`
VERSION="Version 1.3,"
AUTHOR="2009, Mike Adolphs (http://www.matejunkie.com/)"

print_version() {
    echo "$VERSION $AUTHOR"
}

print_help() {
    print_version $PROGNAME $VERSION
    echo ""
    echo "Description:"
    echo "$PROGNAME is a Nagios plugin to check the Apache's server status."
    echo "It monitors requests per second, bytes per second/request, "
    echo "amount of busy/idle workers and its CPU load."
    echo ""
    echo "Example call:"
    echo "./$PROGNAME -H localhost -P 80 -t 3 -b /usr/sbin -p /var/run \\"
    echo "-n apache2.pid -s status_page [-S] [-R] [-wr] 100 [-cr] 250"
    echo ""
    echo "Options:"
    echo "  -H|--hostname)"
    echo "    Sets the hostname. Default is: localhost"
    echo "  -P|--port)"
    echo "    Sets the port. Default is: 80"
    echo "  -t|--timeout)"
    echo "    Sets a timeout within the server's status page must've been"
    echo "    accessed. Otherwise the check will go into an error state."
    echo "    Default is: 3"
    echo "  -b|--binary-path)"
    echo "    Sets the path to the apache binary. Used for getting Apache's"
    echo "    CPU load. Default is: /usr/sbin"
    echo "  -p|--pid-path)"
    echo "    Path to Apache's pid file. Default is: /var/run"
    echo "  -n|--pid-name)"
    echo "    Name of Apache's pid file. Default is: apache2.pid"
    echo "  -s|--status-page)"
    echo "    Defines the name of the status page. Default is: server-status"
    echo "  -R|--remote-server)"
    echo "    Disabled the pid check so that remote Apaches can be queried."
    echo "    Default is: off"
    echo "  -S|--secure)"
    echo "    Enables HTTPS (no certificate check though). Default is: off"
    echo "  -ww|--warning-wkrs)"
    echo "    Sets a warning level for workers. Default is: off"
    echo "  -cw|--critical-wkrs)"
    echo "    Sets a critical level for workers. Default is: off"
    exit $ST_UK
}

ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3

hostname="localhost"
port=80
remote_srv=0
path_binary="/usr/sbin"
path_pid="/var/run"
name_pid="httpd.pid"
status_page="server-status"
timeout=15
secure=0
running=0

wcdiff_req=0
wclvls_req=0
wclvls_wkrs=0

while test -n "$1"; do
    case "$1" in
        --help|-h)
            print_help
            exit $ST_UK
            ;;
        --version|-v)
            print_version $PROGNAME $VERSION
            exit $ST_UK
            ;;
        --hostname|-H)
            hostname=$2
            shift
            ;;
        --port|-P)
            port=$2
            shift
            ;;
        --timeout|-t)
            timeout=$2
            shift
            ;;
        --remote-server|-R)
            remote_srv=1
            ;;
        --binary_path|-b)
            path_binary=$2
            shift
            ;;
        --pid_path|-p)
		 path_pid=$2
            shift
            ;;
        --pid_name|-n)
            name_pid=$2
            shift
            ;;
        --status-page|-s)
            status_page=$2
            shift
            ;;
        --secure|-S)
            secure=1
            ;;
        --warning-wkrs|-ww)
            warn_wkrs=$2
            shift
            ;;
        --critical-wkrs|-cw)
            crit_wkrs=$2
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

# check functions

val_wcdiff_wkrs() {
    if [ ! -z "$warn_wkrs" -a ! -z "crit_wkrs" ]
    then
        wclvls_wkrs=1

        if [ ${warn_wkrs} -gt ${crit_wkrs} ]
        then
            wcdiff_wkrs=1
        fi
    elif [ ! -z "$warn_wkrs" -a -z "$crit_wkrs" ]
    then
        wcdiff_wkrs=2
    elif [ -z "$warn_wkrs" -a ! -z "$crit_wkrs" ]
    then
        wcdiff_wkrs=3
    fi
}


check_pid() {
    if [ -f "$path_pid/$name_pid" ]
    then
        retval=0
    else
        retval=1
    fi
}

check_processes() {
    if [ $1 -lt 1 ]
    then
        echo "UNKNOWN - Your Apache server seems not to run. Is your Nagios \
privileged to run 'ps ax' and is the Apache2 binary really located in \
$path_binary?"
        exit $ST_UK
    fi
}

check_output() {
    stat_output=`stat -c %s ${output_dir}/server-status`
    if [ "$stat_output" = 0 ]
    then
        echo "UNKNOWN - Local copy of server-status is empty. Are we \
allowed to access http://${hostname}:${port}/server-status?"
        exit $ST_UK
    fi
}

# get functions
get_status() {
    if [ "$secure" = 1 ]
    then
        server_status1=`wget -qO- --no-check-certificate -t 3 \
-T ${timeout} https://${hostname}:${port}/${status_page}?auto`
    sleep 1
        server_status2=`wget -qO- --no-check-certificate -t 3 \
-T ${timeout} https://${hostname}:${port}/${status_page}?auto`
    else
        server_status1=`wget -qO- -t 3 -T ${timeout} \
http://${hostname}:${port}/${status_page}?auto`
        sleep 1
        server_status2=`wget -qO- -t 3 -T ${timeout} \
http://${hostname}:${port}/${status_page}?auto`
    fi
}
get_vals() {
    cpu_load="$(cpu_load=0; ps -Ao pcpu,args | grep "$path_binary/httpd" \
| awk '{print $1}' | while read line
    do
        cpu_load=`echo "scale=3; $cpu_load + $line" | bc -l`
    echo $cpu_load
    done)"
    cpu_load=`echo $cpu_load | awk '{print $NF}' | sed 's/^\./0./'`

    tmp1_req_psec=`echo ${server_status1} | awk '{print $3}'`
    tmp2_req_psec=`echo ${server_status2} | awk '{print $3}'`
    req_psec=`echo "scale=2; ${tmp2_req_psec} - ${tmp1_req_psec}" | bc -l \
| sed 's/^\./0./'`

    bytes_psec=`echo ${server_status1} | awk '{print $14}' | sed 's/^\./0./'`
    bytes_preq=`echo ${server_status1} | awk '{print $16}' | sed 's/^\./0./'`
    wkrs_busy=`echo ${server_status1} | awk '{print $18}' | sed 's/^\./0./'`
    wkrs_idle=`echo ${server_status1} | awk '{print $20}' | sed 's/^\./0./'`

    if [ -z $wkrs_busy ]
    then
    echo "CRITICAL - Unable to get Busy Workers detail"
    exit $ST_CR
    fi

}

do_output() {
    output="Apache serves $req_psec Requests per second. Busy workers: $wkrs_busy, idle: $wkrs_idle"
}

do_perfdata() {
    perfdata="'cpu_load'=$cpu_load 'req_psec'=$req_psec \
'bytes_psec'=$bytes_psec 'bytes_preq'=$bytes_preq 'workers_busy'=$wkrs_busy \
'workers_idle'=$wkrs_idle"

}


val_wcdiff_wkrs

if [ "$wcdiff_wkrs" = 1 ]
then
    echo "Please adjust your warning/critical thresholds. The warning must \
be lower than the critical level!"
    exit $ST_UK
elif [ "$wcdiff_wkrs" = 2 ]
then
    echo "Please also set a critical value when you want to use \
warning/critical thresholds!"
    exit $ST_UK
elif [ "$wcdiff_wkrs" = 3 ]
then
    echo "Please also set a warning value when you want to use \
warning/critical thresholds!"
    exit $ST_UK
else
    if [ "$remote_srv" = 0 ]
    then
        running=`check_pid`
        check_pid $running
    fi

    get_status
    get_vals

    do_output
    do_perfdata

if [ "${wclvls_wkrs}" = 1 ]
    then
    if [ ${wkrs_busy} -ge ${warn_wkrs} -a ${wkrs_busy} -lt ${crit_wkrs} ]
        then
            echo "WARNING - ${output} | ${perfdata}"
            exit $ST_WR
        elif [ ${wkrs_busy} -ge ${crit_wkrs} ]
        then
            echo "CRITICAL - ${output} | ${perfdata}"
        exit $ST_CR
        else
            echo "OK - ${output} | ${perfdata}"
           exit $ST_OK
        fi
    else
        echo "OK - ${output} | ${perfdata}"
       exit $ST_OK
    fi

fi
