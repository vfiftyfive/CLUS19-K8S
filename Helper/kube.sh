#!/bin/sh

kubectl apply -f `pwd`/redis-master-controller.json -f `pwd`/redis-master-service.json -f `pwd`/redis-slave-controller.json -f `pwd`/redis-slave-service.json -f `pwd`/guestbook-controller.yaml
sleep 30
pod=$(kubectl get pod | grep guest | cut -d " " -f 1 | head -n 1)
kubectl exec -it ${pod} -- /home/integrationTest.sh
