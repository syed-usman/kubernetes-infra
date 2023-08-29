echo '---------------------------'
echo 'Starting the demo app'
echo '---------------------------'
# Run the demo app Kuard
kubectl run --restart=Never --image=gcr.io/kuar-demo/kuard-amd64:blue kuard


# Install Prometheus Grafana
echo '---------------------------'
echo 'Installing Prometheus + Grafana'
echo '---------------------------'

kubectl create namespace monitoring
kubens monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack


# Logging Setup
echo '---------------------------'
echo 'Installing ELK from Helm chart'
echo '---------------------------'


kubectl create namespace logging
kubens logging

helm package efk-stack/efk-stack
helm install efk-stack efk-stack-0.1.0.tgz


# pod that generates bogus logs
kubectl create -f logging/log-writer-pod.yaml

# web server setup
kubectl apply -f webserver/web-server-deployment.yaml
kubectl apply -f webserver/web-server-service.yaml
kubectl apply -f webserver/web-server-hpa.yaml




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
