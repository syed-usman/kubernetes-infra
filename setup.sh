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

kubectl apply -f logging/elasticsearch-service.yaml
kubectl apply -f logging/elasticsearch-statefulset.yaml

kubectl apply -f logging/fluentd-clusterrole.yaml
kubectl apply -f logging/fluentd-clusterrolebinding.yaml
kubectl apply -f logging/fluentd-daemonset.yaml
kubectl apply -f logging/fluentd-serviceaccount.yaml

kubectl apply -f logging/kibana-deployment.yaml
kubectl apply -f logging/kibana-service.yaml



kubectl create namespace test-apps
kubens test-apps

# pod that generates bogus logs
kubectl create -f test-apps/log-writer-pod.yaml

# web server setup
kubectl apply -f test-apps/web-server-deployment.yaml
kubectl apply -f test-apps/web-server-service.yaml
kubectl apply -f test-apps/web-server-hpa.yaml



