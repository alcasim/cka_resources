#!/usr/bin/env bash
vagrant up controller-0
vagrant up worker-0

NODES=("controller-0" "worker-0")

echo "--------- Install containerd and kubeadm in all nodes"
for node in "${NODES[@]}"; do
  vagrant ssh ${node} -c "sudo /vagrant/scripts/kubernetes/install_prereq_kubeadmin.sh"
done

echo "--------- Start Kubernetes installation"
vagrant ssh controller-0 -c "sudo /vagrant/scripts/kubernetes/start_kubernetes_install.sh single"

echo "--------- Install worker node"
vagrant ssh worker-0 -c "sudo /vagrant/scripts/tmp/join-command.sh"
vagrant ssh worker-0 -c "sudo /vagrant/script/kubernetes/create_worker_volumes.sh"

rm scripts/tmp/join-command.sh


echo "--------- setup local StorageClass and set up some PersistentVolumes"
vagrant ssh controller-0 -c "/vagrant/scripts/kubernetes/set-up-local-storage-class.sh"
