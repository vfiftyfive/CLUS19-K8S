pod=$(KUBECONFIG=$(pwd)/config kubectl get pod | grep guest | cut -d " " -f 1 | head -n 1)
KUBECONFIG=$(pwd)/config kubectl exec -it ${pod} -- /home/integrationTest.sh
