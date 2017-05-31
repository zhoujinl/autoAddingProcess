# old 9526
# new 25440
# some final variable
oneDateSeconds=86400
keepRunningDates=1

#get all process
function getAllProcess(){
	echo xxx;
}


# get the process running seconds
# params: 1.process pid
# return: 1.the process running seconds
function getProcessRunningSeconds(){
        vpid=$1;
        # current unix time (seconds since epoch [1970-01-01 00:00:00 UTC])
        vnow=`date +%s`;

        # process start unix time (also seconds since epoch)
        # I'm fairly sure this is the right way to get the start time in a machine readable way (unlike ps)...but could be wrong
        vstart=`stat -c %Y /proc/"$vpid"`;

        # simple subtraction (both are in UTC, so it works)
        vdiff=$((vnow-vstart));
        echo $vdiff
}

#params:1. vdays ;
#		2. pid
#

function checkProcessRunningSpecifyDays(){
	vdays=$1;
	vpid=$2;
	vdiff=$(getProcessRunningSeconds $vpid)
	vdaysSeconds=$(($vdays * $oneDateSeconds))
	if [ $vdiff -gt $vdaysSeconds ] ;then 
		retval=0;
	else 
		retval=1;
	fi;
	return $retval;
}




age=$(getProcessRunningSeconds 25440)
age=$(checkProcessRunningSpecifyDays 1 9526)

printf "that process has run for %s seconds\n" "$age"

printf "success"





