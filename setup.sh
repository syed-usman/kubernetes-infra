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