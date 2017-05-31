# some final variables
g_allpidfile=".getChoiceProcessPid.txt";
g_destclassname="core.ApplicationProcess";
g_oneDateSeconds=86400;

# 前台传入
g_keepRunningDates=72;
g_neid=1000001011 ;
g_sourclassname=1000001011 ;
g_user="logstash";
g_processname="logstash";
g_exclude="other"


#get all process
function getChoiceProcess(){
	if [ -n $g_user ] ; then
		cmd="ps -f -u $g_user  ";
	else 
		cmd="ps -ef  "
	fi;
	if [ -n $g_processname ]; then	
		cmd=$cmd" | grep $g_processname ";
	fi;
	if [ -n $g_exclude ]; then
		cmd=$cmd" | grep -v  $g_exclude ";
	fi;

	eval $cmd | awk '{print $2}' > $g_allpidfile
	cat .getChoiceProcessPid.txt
}

function getProcessName(){
	v_pid=$1;
	v_processcmd=`ps -p $v_pid|grep -v "CMD"|awk '{print $4}'`;
	v_processuser=`ps -p $v_pid -o user|grep -v "USER"`;
	v_processname=$g_neid-$v_processuser-$v_processcmd;
	echo $v_processname
}
function getProcessShortDiscription(){
	v_pid=$1;
	v_processcmd=`ps -p $v_pid|grep -v "CMD"|awk '{print $4}'`;
	v_processuser=`ps -p $v_pid -o user|grep -v "USER"`;
	v_processname=$v_processcmd;
	echo $v_processname
}

function generateProcessJson(){

	
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
        vlstart=`ps -p $vpid -o lstart|grep -v "STARTED"`;
		vstart=`date -d "$vlstart" +%s`;
        # simple subtraction (both are in UTC, so it works)
        vdiff=$((vnow-vstart));
        echo $vdiff
}

#params: 1. vpid
#return  if the process running seconds >= g_keepRunningDates return 1 ; esle 0
function isProcessRunningOverSpecifyDays(){
	vpid=$1;
	vdiff=$(getProcessRunningSeconds $vpid)
	vdaysSeconds=$(($g_keepRunningDates * $g_oneDateSeconds))

	if [ $vdiff -gt $vdaysSeconds ] ;then  
		retval=1;    
	else 
		retval=0;
	fi;
	echo $retval;
}


# find process we need
function getProcessRunningOverDays(){
	if [ ! -f $g_allpidfile ] ;then
		return;
	fi;
	for pid in `cat $g_allpidfile` 
	do
		isfound=$(isProcessRunningOverSpecifyDays $pid)
		if [ $isfound -eq 1 ] ; then 
			echo  $pid $isfound;
			
			
		fi;
	done;
}



printf "Main the process has run for %s seconds\n" "$age"
x=$( getChoiceProcess )
getProcessRunningOverDays
generateProcessJson 4446








