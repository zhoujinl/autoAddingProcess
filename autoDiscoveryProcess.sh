# some final variables
g_allpidfile=".getChoiceProcessPid.txt";
g_tempJslonfile=".tempJsonFile.txt";
g_applicationProcsss="core.ApplicationProcess";
g_oneDateSeconds=86400;
g_processMessageJsonPre="{\"$g_applicationProcsss\":[";
g_processMessageJsonSuff="],";
g_processRelationJsonPre="\"RelationShip\": [";
g_processRelationJsonSuff="]}";

# 前台传入
g_keepRunningDates=36;
g_neid=1000001011;
g_agentid=80008001;
g_name=1000001011;
g_sourclassname="core.Linux.Mainframe";
g_user="logstash";
g_processname="logstash";
g_exclude="other"


#get all process
function getChoiceProcess(){
	if [ -n $g_user ] ; then
		vcmd="ps -f -u $g_user  ";
	else 
		vcmd="ps -ef  "
	fi;
	if [ -n $g_processname ]; then	
		vcmd=$vcmd" | grep $g_processname ";
	fi;
	if [ -n $g_exclude ]; then
		vcmd=$vcmd" | grep -v  $g_exclude ";
	fi;

	eval $vcmd | awk '{print $2}' > $g_allpidfile
	#cat .getChoiceProcessPid.txt
}

function getProcessName(){
	vpid=$1;
	vprocesscmd=`ps -p $vpid|grep -v "CMD"|awk '{print $4}'`;
	vprocessuser=`ps -p $vpid -o user|grep -v "USER"`;
	vprocessname=${g_neid}-${vpid}-${vprocessuser}-${vprocesscmd};
	echo $vprocessname
}
function getProcessShortDiscription(){
	vpid=$1;
	vprocesscmd=`ps -p $vpid|grep -v "CMD"|awk '{print $4}'`;
	vprocessname=$vprocesscmd;
	echo $vprocessname
}
function getProcessUser(){
	vpid=$1;
	vprocessuser=`ps -p $vpid -o user|grep -v "USER"`;
	echo $vprocessuser
}

## $1 pid
function generateProcessMessage(){
	vpid=$1;
	vproName=$(getProcessName $vpid);
	vproShorD=$(getProcessShortDiscription $vpid);
	vproUser=$(getProcessUser $vpid);

	vprcmd=$vproShorD;
	#base64 加密
	vproShorD=`echo "$vproShorD"|base64 `;
	
	vpre="{\"action\":\"10\",\"value\":{";
	vsuff="}},";
	vdatasetid="\"dataset_id\": \"7\",";
	vname="\"name\":\""$vproName"\","
	vshortdis="\"short_description\":\""$vproShorD"\","
	vuser="\"process_user\":\""$vproUser"\","
	vcmd="\"process_name\":\""$vprcmd"\","
	vnameformat="\"name_format\": \"neId-pid-user-ProcessName\","

	vmessage=${vdatasetid}${vnameformat}${vname}${vshortdis}${vuser}${vcmd}
	vresult=${vpre}${vmessage}${vsuff} ;
	echo $vresult;
}

## $1 pid
function generateProcessRelation(){
	vpid=$1;
	vproName=$(getProcessName $vpid);
	
		
	vpre="{\"action\":\"10\",\"value\":{";
	vsuff="}},";
	
	vsourcepre="\"source\": {";
	vsourcesuff="},";
	vdistpre="\"destination\": {";
	vdistsuff="}";
	
	vsourcename="\"name\":\""$g_name"\","
	vsourceclass="\"class\":\""$g_sourclassname"\""
	
	vdistname="\"name\":\""$vproName"\","
	vdistclass="\"class\":\""$g_applicationProcsss"\""

	vsourceResult=${vsourcepre}${vsourcename}${vsourceclass}${vsourcesuff};
	vdistResult=${vdistpre}${vdistname}${vdistclass}${vdistsuff};
	vresult=${vpre}${vsourceResult}${vdistResult}${vsuff};
	echo $vresult;
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
	
	vmessagebuild=$g_processMessageJsonPre;
	vrelationbuild=$g_processRelationJsonPre;
	
	for pid in `cat $g_allpidfile` 
	do
		isfound=$(isProcessRunningOverSpecifyDays $pid)
		#TODO isListen 	
		if [ $isfound -eq 1 ] ; then 
			##执行操作
			x=$(generateProcessMessage $pid);
			y=$(generateProcessRelation $pid);
			vmessagebuild=${vmessagebuild}$x;
			vrelationbuild=${vrelationbuild}$y;
		fi;
	done;
	vmessagebuild=${vmessagebuild}${g_processMessageJsonSuff}
	vrelationbuild=${vrelationbuild}${g_processRelationJsonSuff};
	echo ${vmessagebuild}${vrelationbuild} > $g_tempJslonfile
}

function getJsonFileName(){
	vfilenamePre="CFG_"${g_neid}"_7_"${g_agentid}"_";
	vnowdate=`date -d now +%Y%m%d%H%M%S`;
	vmiddle="_000_FULL_";
	vfilesize=`ls -al|grep $g_tempJslonfile |awk '{print $5}'`;
	vfilenameSuff=".json"
	
	vresult=${vfilenamePre}${vnowdate}${vmiddle}${vfilesize}${vfilenameSuff};
	echo $vresult;
}
function getFinallyResult(){

	if [ ! -f $g_tempJslonfile ];then 
		echo "xxx"
		exit -1;
	fi
	vjsonFileName=$(getJsonFileName);
	cat ${g_tempJslonfile} > ${vjsonFileName} 
}

printf "=============================>> begin.\n"
##1.查找所有的进程
getChoiceProcess
##2.过滤出，符合条件的进程,并进行封装，输出
getProcessRunningOverDays
##3.生成最终的CFG文件
getFinallyResult

printf "=============================>> end.\n"









