#/usr/bin/csh

# Set the usage and help messages:
set usage = "Usage: $0 {config_file.cfg} ; possible .cfg files found: `echo *.cfg`"
set help = "Better run ./foshi.csh help ..."

# Basic input checks:
if ( $1 == "help" ) then
        echo $help
        echo $usage
        exit 1;
else if ( $#argv != 1 ) then
        echo $usage
        exit 1;
else if ( -r $1 ) then
        set camera = $1
else if ( -d $1 ) then
        echo "Error: $1 is a directory and cannot be started !"
        echo $usage
        exit 1;
else
        echo "Error: configuration file '$1' not found !"
	echo $help
        echo $usage
        exit 1;
endif

# Load the variables from the .cfg file:
set noglob
source $1
unset noglob

set cam_alarm_total = "$cam_alarm1 $cam_alarm2"

# Create a startup entries in the log files:
echo "`date`|$1|Initiating monitoring for $trig_camera ($cam_ip) via Shinobi ($shi_ip), appending to log file: logs/$1.log"
echo "`date`|$1|Initiating monitoring for $trig_camera ($cam_ip) via Shinobi ($shi_ip), verifying the connection..." >> logs/$1.log

# Cycle the main loop endlessly, checking for events every 1 second:
while ( 1 )
   if ( `curl -m 2 -Is $cam_ip | head -n 1` != "" ) then
      echo "`date`|$1|Connection to $trig_camera ($cam_ip) has been established, checking for new alarms every 1 second!" >> logs/$1.log
      while ( `curl -m 2 -Is $cam_ip | head -n 1` != "" )
        foreach i ($cam_alarm_total)
                if ( `curl -s -m 2 "$cam_ip/cgi-bin/CGIProxy.fcgi?cmd=getDevState&usr=$cam_usr&pwd=$cam_pwd" | grep "<$i>" | sed 's/[^0-9]//g'` == "2" ) then
                        echo "`date`|$1|:$i event on $trig_camera ($cam_ip), triggering Shinobi ($shi_ip) recording!" >> logs/$1.log
                        curl -s "$shi_ip/$shi_apikey/motion/$shi_grp/$shi_cam?data={"plug":$trig_camera,"name":$trig_zone,"reason"\:$i,"confidence":$trig_confidence}" -o /dev/null
                        sleep 5
                else
                        sleep $cam_alarm_timer
                endif
        end
      end
   else
	echo "`date`|$1|Connection to $trig_camera ($cam_ip) has been lost, retrying in 60 seconds..." >> logs/$1.log
	sleep 60
   endif
end
