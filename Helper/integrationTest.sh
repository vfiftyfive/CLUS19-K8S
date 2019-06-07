#!/bin/sh
$(socat /dev/null TCP:redis-master.devbuild.svc.cluster.local:6379,connect-timeout=2 2> /dev/null)
ret1=$?
$(socat /dev/null TCP:redis-slave.devbuild.svc.cluster.local:6379,connect-timeout=2 2> /dev/null)
ret2=$?

([ $ret1 -eq 0 ] && [ $ret2 -eq 0 ]) && ( echo 'success' > /home/exit ) || ( echo 'fail' > /home/exit )
