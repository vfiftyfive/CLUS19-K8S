#!/bin/sh

pod=$(kubectl get pod | grep guest | cut -d " " -f 1 | head -n 1)
kubectl exec -i ${pod} -- /home/integrationTest.sh && kubectl exec -i ${pod} -- cat /home/exit 
