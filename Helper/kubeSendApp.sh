kubectl exec -it $(kubectl get pod | grep guest | cut -d " " -f 1 | head -n 1) -- /home/integrationTest.sh
