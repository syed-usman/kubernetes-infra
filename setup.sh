# start cluster
echo '---------------------------'
echo 'Setting up minikube cluster'
echo '---------------------------'

minikube delete
minikube start \
  --kubernetes-version=v1.23.0 \
  --memory=6g \
  --bootstrapper=kubeadm \
  --extra-config=kubelet.authentication-token-webhook=true \
  --extra-config=kubelet.authorization-mode=Webhook \
  --extra-config=scheduler.bind-address=0.0.0.0 \
  --extra-config=controller-manager.bind-address=0.0.0.0

sleep 15

echo '---------------------------'
echo 'Starting the demo app'
echo '---------------------------'
# Run the demo app Kuard
kubectl run --restart=Never --image=gcr.io/kuar-demo/kuard-amd64:blue kuard

sleep 15

# Install Prometheus Grafana
echo '---------------------------'
echo 'Installing Prometheus and Grafana using helm'
echo '---------------------------'
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack

sleep 45

# Port forward prometheus and grafana
echo '---------------------------'
echo 'Port forwarding (for local use only)'
echo '---------------------------'

kubectl port-forward kuard 8080:8080 > out.log 2>&1 &
kubectl port-forward deployment/prometheus-grafana 3000 > out.log 2>&1 &
kubectl port-forward prometheus-prometheus-kube-prometheus-prometheus-0 9090 > out.log 2>&1 &


# logging Setup
# elasticsearch
kubectl create -f logging/elasticsearch/elasticsearch-service.yaml
kubectl create -f logging/elasticsearch/elasticsearch-statefulset.yaml
sleep 30
kubectl port-forward es-cluster-0 9200:9200 > out.log 2>&1 &

# kibana
kubectl create -f logging/kibana/kibana-deployment.yaml
kubectl create -f logging/kibana/kibana-service.yaml
sleep 30
kubectl port-forward kibana-74d7cb859b-89hbm 5601:5601 > out.log 2>&1 &

# fluentd
kubectl create -f logging/fluentd/fluentd-clusterrole.yaml
kubectl create -f logging/fluentd/fluentd-serviceaccount.yaml
kubectl create -f logging/fluentd/fluentd-clusterrolebinding.yaml
kubectl create -f logging/fluentd/fluentd-daemonset.yaml

kubectl create -f logging/log-writer-pod.yaml