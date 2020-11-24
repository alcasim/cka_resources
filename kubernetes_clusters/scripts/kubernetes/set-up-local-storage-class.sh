#!/bin/bash
# Run this script to create a storage class for local provisioning
# and to create PersistentVolumes on each worker node


cat > local-storage.yaml <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

EOF

for node in worker-0 worker-1 worker-2; do
  for vol in vol1 vol2 vol3 vol4; do
    cat >> local-storage.yaml <<EOF
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: node-${node}-${vol}
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/${vol}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${node}

EOF
done
done

kubectl apply -f local-storage.yaml
