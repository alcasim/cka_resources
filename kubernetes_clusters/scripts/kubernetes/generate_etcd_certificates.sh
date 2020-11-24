#!/bin/bash
# based on https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

export HOST0=192.168.199.10
export HOST1=192.168.199.11
export HOST2=192.168.199.12

kubeadm init phase certs etcd-ca
kubeadm init phase certs etcd-server --config=/vagrant/scripts/certificates/${HOST2}/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/vagrant/scripts/certificates/${HOST2}/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/vagrant/scripts/certificates/${HOST2}/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/vagrant/scripts/certificates/${HOST2}/kubeadmcfg.yaml
cp -R /etc/kubernetes/pki /vagrant/scripts/certificates/${HOST2}/
# cleanup non-reusable certificates
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm init phase certs etcd-server --config=/vagrant/scripts/certificates/${HOST1}/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/vagrant/scripts/certificates/${HOST1}/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/vagrant/scripts/certificates/${HOST1}/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/vagrant/scripts/certificates/${HOST1}/kubeadmcfg.yaml
cp -R /etc/kubernetes/pki /vagrant/scripts/certificates/${HOST1}/
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm init phase certs etcd-server --config=/vagrant/scripts/certificates/${HOST0}/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/vagrant/scripts/certificates/${HOST0}/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/vagrant/scripts/certificates/${HOST0}/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/vagrant/scripts/certificates/${HOST0}/kubeadmcfg.yaml
# No need to move the certs because they are for HOST0

# clean up certs that should not be copied off this host
find /vagrant/scripts/certificates/${HOST2} -name ca.key -type f -delete
find /vagrant/scripts/certificates/${HOST1} -name ca.key -type f -delete
