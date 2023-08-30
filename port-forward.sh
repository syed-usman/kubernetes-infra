
# Port forward prometheus and grafana
echo '---------------------------'
echo 'Port forwarding (for local use only)'
echo '---------------------------'

kubectl port-forward kuard 8080:8080 > out.log 2>&1 &
kubectl port-forward deployment/prometheus-grafana 3000 > out.log 2>&1 &
kubectl port-forward prometheus-prometheus-kube-prometheus-prometheus-0 9090 > out.log 2>&1 &
kubectl port-forward es-cluster-0 9200:9200 > out.log 2>&1 &

KIBANA_POD=$(kubectl get pods -l app=kibana -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $KIBANA_POD 5601:5601 > out.log 2>&1 &
