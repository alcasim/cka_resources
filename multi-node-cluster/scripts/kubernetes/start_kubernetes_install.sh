#!/bin/bash
kubeadm init --config /vagrant/scripts/kubernetes/initial-kubeadm-config.yaml

# Create token to join other nodes
kubeadm token create --print-join-command > /vagrant/scripts/tmp/join-command.sh
chmod 755 /vagrant/scripts/tmp/join-command.sh

# Copy certificates for other controllers

CONTROLLERS=("192.168.199.11" "192.168.199.12")
for i in ${CONTROLLERS[@]}; do
  mkdir -p /vagrant/scripts/certificates/${i}/pki
  cp /etc/kubernetes/pki/ca.* /vagrant/scripts/certificates/${i}/pki
  cp /etc/kubernetes/pki/sa.* /vagrant/scripts/certificates/${i}/pki
  cp /etc/kubernetes/pki/front-proxy-ca.* /vagrant/scripts/certificates/${i}/pki
done

# Configure kubectl
mkdir -p $HOME/.kube
cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u vagrant ):$(id -g vagrant) $HOME/.kube/config

# install weave
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
