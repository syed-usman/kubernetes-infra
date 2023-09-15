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
  --extra-config=controller-manager.bind-address=0.0.0.0 \
  --addons=metrics-server
  --addons=dashboard
