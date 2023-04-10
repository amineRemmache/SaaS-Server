#!/bin/bash

# echo "[TASK 1] Pull required containers"
# kubeadm config images pull >/dev/null 2>&1

# echo "[TASK 2] Initialize Kubernetes Cluster"
# kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

# echo "[TASK 3] Deploy Calico network"
# kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1

echo "[TASK 1] Generate and save cluster join command to /joincluster.sh"
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - 

echo "[TASK 2] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

kubeadm token create --print-join-command > /vagrant/k3s-token
cat /vagrant/k3s-token
