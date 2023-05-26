#!/bin/bash
set -euxo pipefail

# NB this is not really required. we only install it to have the wg tool to
#    quickly see the wireguard configuration.
apt-get install -y wireguard

#DEPLOY JENKINS ON K
# .........................8S
# helm repo add jenkins https://charts.jenkins.io
# helm repo update
# helm upgrade --install jenkins-4.3.23 jenkins/jenkins --kubeconfig /etc/rancher/k3s/k3s.yaml

helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm search repo jenkinsci
kubectl apply -f ../k8s-manifests/jenkins-volume.yaml
sudo chown -R 1000:1000 /data/jenkins-volume
kubectl apply -f ../k8s-manifests/jenkins-sa.yaml
chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f ../k8s-manifests/jenkins-values.yaml $chart
jsonpath="{.data.jenkins-admin-password}"
secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
echo $(echo $secret | base64 --decode)
jsonpath="{.spec.ports[0].nodePort}"
NODE_PORT=$(kubectl get -n jenkins -o jsonpath=$jsonpath services jenkins)
jsonpath="{.items[0].status.addresses[0].address}"
NODE_IP=$(kubectl get nodes -n jenkins -o jsonpath=$jsonpath)
echo http://$NODE_IP:$NODE_PORT/login


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



