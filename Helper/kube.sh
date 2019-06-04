#!/bin/sh

pod=$(kubectl get pod | grep guest | cut -d " " -f 1 | head -n 1)
kubectl exec -it ${pod} -- /home/integrationTest.sh
