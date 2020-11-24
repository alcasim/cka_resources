#!/bin/bash
ETCD_NAME=$(hostname -s)
INTERNAL_IP=$(ip addr sh enp0s8 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# Check if running in controller node
if [[ $(hostname -s) != *"controller-"* ]];then
    echo "This script should be executed only on a controller node!"
    exit 1
fi


# check if certificates were generated
if [[ $(hostname -s) =~ "controller-0" && ! -f "/etc/kubernetes/pki/etcd/server.key" ]];then
  echo "certificates were not generated, not installing ETCD"
  exit 1
fi

if [[ $(hostname -s) =~ "controller-[1-2]" && ! -f "/vagrant/scripts/certificates/${INTERNAL_IP}/pki/etcd/server.key" ]];then
  echo "certificates were not generated, not installing ETCD"
  exit 1
fi

# move certificates
if [[ $(hostname -s) =~ ^controller-(1|2) ]]; then
  echo "moving certificates"
  mv /vagrant/scripts/certificates/${INTERNAL_IP}/pki /etc/kubernetes
  chown -R root:root /etc/kubernetes/pki
fi

wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.10/etcd-v3.4.10-linux-amd64.tar.gz"

tar -xvf etcd-v3.4.10-linux-amd64.tar.gz
mv etcd-v3.4.10-linux-amd64/etcd* /usr/local/bin/

mkdir -p /etc/etcd /var/lib/etcd
chmod 700 /var/lib/etcd


cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=simple
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/kubernetes/pki/etcd/server.crt \\
  --key-file=/etc/kubernetes/pki/etcd/server.key \\
  --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt \\
  --peer-key-file=/etc/kubernetes/pki/etcd/peer.key \\
  --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://192.168.199.10:2380,controller-1=https://192.168.199.11:2380,controller-2=https://192.168.199.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
