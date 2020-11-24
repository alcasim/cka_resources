#!/usr/bin/env bash
vagrant up

CONTROLLERS=("controller-0" "controller-1" "controller-2")
WORKERS=("worker-0" "worker-1" "worker-2")

echo "--------- Install containerd and kubeadm in controller nodes"
for node in "${CONTROLLERS[@]}"; do
  vagrant ssh ${node} -c "sudo /vagrant/scripts/kubernetes/install_prereq_kubeadmin.sh"
done

echo "--------- Generate certificates"
vagrant ssh controller-0 -c "sudo /vagrant/scripts/kubernetes/generate_etcd_certificates.sh"


echo "--------- Install etcd"
for node in "${CONTROLLERS[@]}"; do
  vagrant ssh ${node} -c "sudo /vagrant/scripts/kubernetes/install_etcd.sh"
done

sleep 60
echo "--------- Start Kubernetes installation"
vagrant ssh controller-0 -c "sudo /vagrant/scripts/kubernetes/start_kubernetes_install.sh multi"
echo "--------- Installing controller nodes"
vagrant ssh controller-1 -c "sudo /vagrant/scripts/kubernetes/join_controller.sh"
vagrant ssh controller-2 -c "sudo /vagrant/scripts/kubernetes/join_controller.sh"
rm scripts/tmp/join-controller-command.sh


echo "--------- Install worker nodes"
for node in "${WORKERS[@]}"; do
  vagrant ssh ${node} -c "sudo /vagrant/scripts/kubernetes/install_prereq_kubeadmin.sh"
  vagrant ssh ${node} -c "sudo /vagrant/scripts/tmp/join-command.sh"
  vagrant ssh ${node} -c "sudo /vagrant/script/kubernetes/create_worker_volumes.sh"
done
rm scripts/tmp/join-command.sh


echo "--------- setup local StorageClass and set up some PersistentVolumes"
vagrant ssh controller-0 -c "/vagrant/scripts/kubernetes/set-up-local-storage-class.sh"
