#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
curl -sfL https://get.k3s.io | K3S_TOKEN_FILE="./k3s-token" K3S_URL="https://192.168.1.210:6443" K3S_NODE_NAME=$1 sh -
# apt install -qq -y sshpass >/dev/null 2>&1
# sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.example.com:/joincluster.sh /joincluster.sh 2>/dev/null
# bash /joincluster.sh >/dev/null 2>&1
