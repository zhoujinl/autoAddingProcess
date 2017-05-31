###进程自动发现

1. ps -eo pid,etime,cmd -H
 [zhoujl@itmtest1 json]$  ps -eo pid,etime,cmd -H |grep yanjsh
 7578       00:00           grep yanjsh
17130  2-08:48:41   ./luax scheduler.lua --agent=j_agent_yanjsh --max=8
13469    09:10:38     ./luax scheduler.lua --agent=j_agent_yanjsh --max=8
14136    09:09:56     ./luax scheduler.lua --agent=j_agent_yanjsh --max=8
15860    09:03:49     ./luax scheduler.lua --agent=j_agent_yanjsh --max=8
13468    09:10:38   /usr/bin/java -Dprogram=j_agent_yanjsh -Dsun.lang.ClassLoader.allowArraySyntax=true -Duser.timezone=Asia/Shanghai -Xms256m -Xmx1024m com.ffcs.itm.agent.init.AgentStart

查出运行时间大于一天的进程ID

2.并且有监听端口


3.获取相应的进行信息


4.按照格式生成配置文件

