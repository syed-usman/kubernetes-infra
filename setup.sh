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


kubectl create namespace main
kubens main

# pod that generates bogus logs
kubectl create -f log-writer-pod.yaml

# web server setup
kubectl apply -f webserver/web-server-deployment.yaml
kubectl apply -f webserver/web-server-service.yaml
kubectl apply -f webserver/web-server-hpa.yaml



