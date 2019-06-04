#!/bin/sh
$(socat /dev/null TCP:redis-master.jenkins.svc.cluster.local:6379,connect-timeout=2 2> /dev/null)
ret1=$?
$(socat /dev/null TCP:redis-slave.jenkins.svc.cluster.local:6379,connect-timeout=2 2> /dev/null)
ret2=$?

([ $ret1 -eq 0 ] && [ $ret2 -eq 0 ]) && exit 0 || exit 1

