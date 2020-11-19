#!/bin/bash
# check https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/ for further details
# This script is not executed during provisioning, but it's kept for tracking purposes, as it's the "official" way to provision
# the ETCD cluster certificates

export HOST0=192.168.199.10
export HOST1=192.168.199.11
export HOST2=192.168.199.12
NAMES=("controller-0" "controller-1" "controller-2")

mkdir -p /vagrant/scripts/certificates/${HOST0}/ /vagrant/scripts/certificates/${HOST1}/ /vagrant/scripts/certificates/${HOST2}/

ETCDHOSTS=(${HOST0} ${HOST1} ${HOST2})

for i in "${!ETCDHOSTS[@]}"; do
HOST=${ETCDHOSTS[$i]}
NAME=${NAMES[$i]}
cat << EOF > /vagrant/scripts/certificates/${HOST}/kubeadmcfg.yaml
apiVersion: "kubeadm.k8s.io/v1beta2"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: ${NAMES[0]}=https://${ETCDHOSTS[0]}:2380,${NAMES[1]}=https://${ETCDHOSTS[1]}:2380,${NAMES[2]}=https://${ETCDHOSTS[2]}:2380
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF
done
