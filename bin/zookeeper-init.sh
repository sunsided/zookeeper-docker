#!/usr/bin/env bash

set -eo pipefail

ZK=$1
MYID=1
IPADDRESS=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`

cd $ZOOKEEPER_PATH
if [ -n "$ZK" ] 
then

 	output=`./bin/zkCli.sh -server $ZK:2181 get /zookeeper/config | grep ^server` 
  
	# extract all the zk-ids from the output
	declare -a id_list=()
	while read x;
	do
		id_list+=(`echo $x | cut -d"=" -f1 | cut -d"." -f2`)
	done <<<$(output)
	sorted_id_list=( $(
		for el in "${id_list[@]}"
		do  
			echo "$el"
		done | sort -n) )
	
	# get the next increasing number from the sequence
	MYID=$((${sorted_id_list[${#sorted_id_list[@]}-1]}+1))

	echo $output >> $ZOOKEEPER_PATH/conf/zoo.cfg.dynamic
	echo "server.$MYID=$IPADDRESS:2888:3888:observer;2181" >> $ZOOKEEPER_PATH/conf/zoo.cfg.dynamic

	cp $ZOOKEEPER_PATH/conf/zoo.cfg.dynamic $ZOOKEEPER_PATH/conf/zoo.cfg.dynamic.org
	$ZOOKEEPER_PATH/bin/zkServer-initialize.sh --force --myid=$MYID
	ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' $ZOOKEEPER_PATH/bin/zkServer.sh start

	# reconfigure the cluster
	$ZOOKEEPER_PATH/bin/zkCli.sh -server $ZK:2181 reconfig -add "server.$MYID=$IPADDRESS:2888:3888:participant;2181"

	# restart the server
	$ZOOKEEPER_PATH/bin/zkServer.sh stop
	ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' $ZOOKEEPER_PATH/bin/zkServer.sh start-foreground

else

	echo "server.$MYID=$IPADDRESS:2888:3888;2181" >> $ZOOKEEPER_PATH/conf/zoo.cfg.dynamic
	$ZOOKEEPER_PATH/bin/zkServer-initialize.sh --force --myid=$MYID
	ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' $ZOOKEEPER_PATH/bin/zkServer.sh start-foreground

fi
