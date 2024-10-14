#!/bin/bash
# Based on bashpodder script written by Linc 10/1/2004
# Find the latest script from him at http://lincgeek.org/bashpodder
# Modified by Chris Debenham 20/3/2009
# Now forks sub-shells for each feed and downloads in parallel
# Displays a single status table tracking the multiple downloads

# Parse config file
config=$HOME/.bashpodder
export logdir=`grep "^#LOGDIR" $config | cut -f2 -d:`
export datadir=`grep "^#PODDIR" $config | cut -f2 -d:`
cd $(dirname $0)

# Function to download a feed
download_feed()
{
    podcast=$1
    echo Reading $podcast
    feedid=`echo $podcast | md5sum - | cut -f1 -d' '`
    #Increment counter
    flock $logdir/active_downloads -c 'echo $((`cat $logdir/active_downloads`+1)) > $logdir/active_downloads'
	file=$(output_xslt | xsltproc - $podcast 2> /dev/null || wget -q $podcast -O - | tr '\r' '\n' | tr \' \" | sed -n 's/.*url="\([^"]*\)".*/\1/p')
    if [ ! -e $logdir/$feedid.log ];then touch $logdir/$feedid.log;fi
	for url in $file
	do
		if ! grep "$url" $logdir/$feedid.log > /dev/null
			then
            if [ "$catchup" = "1" ]
            then
                echo $url >> $logdir/$feedid.log
            else 
			    wget -o $logdir/$feedid.wget -t 10 -U BashPodder -c -O $datadir/$(echo "$url" | awk -F'/' {'print $NF'} | awk -F'=' {'print $NF'} | awk -F'?' {'print $1'}) "$url"
                if [ $? -eq 0 ]
                then
                    echo $url >> $logdir/$feedid.log
                else
                    echo $url >> $logdir/$feedid.fail
                fi
                rm $logdir/$feedid.wget
            fi
		fi
        status=`cat $logdir/control`
        if [ "$status" = "Stop" ]
        then
            echo Exiting $podcast
            flock $logdir/active_downloads -c 'echo $((`cat $logdir/active_downloads`-1)) > $logdir/active_downloads'
            exit
        fi
	done
    cp $logdir/$feedid.log $logdir/$feedid.log.back
    sort --unique --output $logdir/$feedid.log $logdir/$feedid.log.back
    rm $logdir/$feedid.log.back
    #Decrement counter
    flock $logdir/active_downloads -c 'echo $((`cat $logdir/active_downloads`-1)) > $logdir/active_downloads'
    echo Finished $podcast
}

show_help()
{
    echo "Bashpodder - Chris's edition"
    echo "Made 20 March 2009"
    echo "Last update 22 Feb 2010"
    echo "----------------------------"
    echo "Command-line options"
    echo " -h               show this help"
    echo " -c               catchup mode - don't download anything but say that we have"
    echo " -a url [items]   add a feed"
    echo "                  - first parameter is the feed url"
    echo "                  - second is the number of recent items to download"
    exit
}

output_xslt()
{
cat <<EOF
<?xml version="1.0"?>
<stylesheet version="1.0"
    xmlns="http://www.w3.org/1999/XSL/Transform">
    <output method="text"/>
    <template match="/">
        <apply-templates select="/rss/channel/item/enclosure"/>
    </template>
    <template match="enclosure">
        <value-of select="@url"/><text>&#10;</text>
    </template>
</stylesheet>
EOF
}

add_podcast()
{
    if [[ -n $@ ]]
    then
        podcast=$1
        feedid=$(echo $podcast | md5sum | cut -f1 -d' ')
        parse_enclosure.xsl | xsltproc - "$podcast" 2>/dev/null |tac|head --lines=-${2:-1} >> $logdir/$feedid.log
        echo "$podcast # $feedid" >> $config
        echo "Logged all but the newest ${2:-1}"
        exit 0
    else
        echo nothing to do
        exit 1
    fi
}

# create datadir if necessary:
mkdir -p $datadir
mkdir -p $logdir
export download=1

case "$1" in
    '-c')
        echo "Catchup Mode enabled"
        export catchup=1
        ;;
    '-h')
        show_help
        ;;
    '-t')
        echo Tracking only
        download=0
        ;;
   '-a')
        add_podcast $2 $3
        ;;
esac

if [ "$download" = "1" ]
then
echo 0 > $logdir/active_downloads

echo Starting downloads
echo "Go" > $logdir/control
# Read the bp.conf file and wget any url not already in the podcast.log file:
while read podcast
do
    podcast=`echo $podcast | sed -e 's/#.*$//g'`
    if [ -n "$podcast" ]
    then
        download_feed $podcast &
    fi
done < $config

# Wait a moment so the sub-processes have started
sleep 5

if [ "$catchup" = "1" ]
then
    while [ `cat $logdir/active_downloads` -gt 0 ]
    do
        sleep 1
    done
    echo Done
    exit
fi
fi

# Setup for non-blocking input
if [ -t 0 ]; then
    stty -echo -icanon time 0 min 0
fi

# Track download progress
while [ `cat $logdir/active_downloads` -gt 0 ]
do tput clear
    ROWS=`stty size | cut -f2 -d" "`
    NAMESIZE=$(($ROWS-29))
    printf "%8s|%4s|%5s|%7s|%s\n" "Down" "Perc" "Rate" "Remain" "Filename"
    echo "-----------------------------------------------------------------"

    for LOG in $logdir/*.wget
        do if [ -e "$LOG" ]; 
            then filename=`cat $LOG |grep "^Saving" | tail -1 | sed -e "s/^.*podcasts\/\(.*\)'$/\1/g" | cut -c1-$NAMESIZE`
            status=`tail -2 $LOG | head -1 | sed -e 's/\.\.* //g' -e 's/  */ /g'`
            printf "%8s|%4s|%5s|%7s|%s\n" $status $filename
        fi
    done
    echo
    echo "Press 'q' to quit"
    sleep 2

    # Check for console input
    read line
    if [ -n "$line" ]; then
        if  [ "$line" = "q" ]; then
            if [ -t 0 ]; then
                stty sane
            fi
            echo "Stop" > $logdir/control
            pkill -f "wget.*BashPodder"
            while [ `cat $logdir/active_downloads` -gt 0 ]
            do
                sleep 1
            done
            echo Cancelled on request of user
            exit
        fi
    fi
done
if [ -t 0 ]; then
    stty sane
fi
rm /tmp/parse_enclosure.xsl 2>/dev/null
echo Done

