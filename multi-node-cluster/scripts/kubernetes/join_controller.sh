#!/bin/bash
INTERNAL_IP=$(ip addr sh enp0s8 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

if [[ ! -f "/vagrant/scripts/tmp/join-controller-command.sh" ]]; then
  join_command=$(cat "/vagrant/scripts/tmp/join-command.sh")
  echo "${join_command} --control-plane" > /vagrant/scripts/tmp/join-controller-command.sh
  chmod 755 /vagrant/scripts/tmp/join-controller-command.sh
fi

if [[ $(hostname -s) =~ ^controller-(1|2) ]]; then
  echo "moving certificates"
  mv /vagrant/scripts/certificates/${INTERNAL_IP}/pki/* /etc/kubernetes/pki/
  chown -R root:root /etc/kubernetes/pki
  rmdir /vagrant/scripts/certificates/${INTERNAL_IP}/pki
fi

/vagrant/scripts/tmp/join-controller-command.sh
