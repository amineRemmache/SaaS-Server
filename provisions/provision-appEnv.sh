#!/bin/bash
set -euxo pipefail

# NB this is not really required. we only install it to have the wg tool to
#    quickly see the wireguard configuration.
apt-get install -y wireguard

helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins-4.3.23 jenkins/jenkins --kubeconfig /etc/rancher/k3s/k3s.yaml


$ kubectl exec --namespace default -it svc/myjenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo

kubectl --namespace default port-forward svc/myjenkins 8080:2323
echo http://$SERVICE_IP:2323/login

# deploying app on kubernetes
echo "deploying app's k8s's manifests"
kubectl apply -f ../app/app-deployment.yml
kubectl apply -f ../app/app-service.yml

echo "deploying app's Database's k8s's manifests"
kubectl apply -f ../app/appDB-statefulset.yml
kubectl apply -f ../app/appDB-service.yml



