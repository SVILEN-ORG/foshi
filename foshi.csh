#/usr/bin/csh

# Set the usage and help messages:
set script = "single_foshi.csh"
set usage = "Usage: $0 {start|stop|restart|help} {.cfg|all} ; possible .cfg files found: `echo *.cfg`, or use all "
set help = "Description: $0 will call '$script' for each .cfg file that has been passed to it and then drop to background.\
Created by Svilen Savov (svilen@svilen.org)"

# Basic input checks:
if ( $1 == "help" ) then
	echo $help
	echo $usage
	exit 1;
else if ( $#argv != 2 ) then
	echo $usage
	exit 1;
else if ( $2 == "all" ) then
	set cameras = `ls *.cfg`
else if ( -d $2 ) then
	echo "Error: $2 is a directory and cannot be started !"
	echo $usage
	exit 1;
else if ( -r $2 ) then
	set cameras = $2
else
	echo "Error" config file $2 does not exist !"
        echo $usage
        exit 1;
endif

# Preare the logs directory:
if (! -d logs) then; mkdir logs
endif

# Check what must be done and execute it:
switch ( $1 )
	case "restart":
		foreach i ($cameras)
			echo "Stopping the monitoring for $i..."
                	echo "`date`|$i|Stopping the monitoring script for $i" >> logs/$i.log
                	pkill -f "/bin/csh ./$script $i"
		end
	case "start":
		
	        # CALLING THE MAIN SCRIPT FOR EACH .CFG:
		foreach i ($cameras)
			echo "Starting the monitoring for $i..."
			echo "`date`|$i|Starting the monitoring script for $i" >> logs/$i.log
			( nohup ./$script $i >> logs/foshi.log ) >> & logs/foshi.log &
			echo "Monitoring started for $i"
		end
		breaksw

	case "stop":
                foreach i ($cameras)
                        echo "Stopping the monitoring for $i..."
                        echo "`date`|$i|Stopping the monitoring script for $i" >> logs/$i.log
                        pkill -f "/bin/csh ./$script $i"
                end
		breaksw
	default:
		breaksw
	endsw
endif