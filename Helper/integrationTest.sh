#!/bin/sh
socat /dev/null TCP:redis-master.jenkins.svc.cluster.local:6379,connect-timeout=2 2> /dev/null
ret1=$?
socat /dev/null TCP:redis-slave.jenkins.svc.cluster.local:6379,connect-timeout=2 2> /dev/null
ret2=$?

if ! [[ ${ret1} || ${ret2} ]]; then
	exit 0;
else exit 1;
fi
