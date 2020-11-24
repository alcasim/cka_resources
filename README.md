# CKA resources
Latest update: November 2020

This repository contains material I've gathered to pass the CKA exam + some clusters which can be created using vagrant

Contributions and fixes are welcome :)

## Links
### Official Documentation
* [CNCF Curriculum repository](https://github.com/cncf/curriculum)
* [Kubernetes docs](https://kubernetes.io/docs/home/)
* [Candidate Handbook](https://training.linuxfoundation.org/go/cka-ckad-candidate-handbook)
* [CKA main page](https://www.cncf.io/certification/cka/)

### Non Official links
* [Kelsey Hightower "Kubernetes the Hard Way"](https://github.com/kelseyhightower/kubernetes-the-hard-way): how to build a k8s cluster from scratch with no automation tools.
* [walidshaari's Kubernetes Certified Administration repo](https://github.com/walidshaari/Kubernetes-Certified-Administrator): it links curriculum parts with documentation pages. Also contains interesting tips for the exam, and link to paid courses ([killer.sh](https://killer.sh/cka) is a very interesting one, it provides a CKA exam simulator with 25 scenarios)
* [dgkanatsios' CKAD exercises](https://github.com/dgkanatsios/CKAD-exercises): quite good to level up in "normal" k8s usage, and to train parts of the exam which matches the CKAD exam (workloads, services, etc...)
* [CKA example exam questions](https://levelup.gitconnected.com/kubernetes-cka-example-questions-practical-challenge-86318d85b4d): from the same creator than `killer.sh`, 6 really good scenarios to practice locally
* [backup/restore ETCD](https://brandonwillmott.com/2020/09/03/backup-and-restore-etcd-in-kubernetes-cluster-for-cka-v1-19/): quick guide to check how to backup and restore ETCD

## Study tips
These tips assume you are already familiar with k8s and you want to tune up your skills for the exam. If you are not familiar a good starting point are the [tutorials from kubernetes.io](https://kubernetes.io/docs/tutorials/), don't hesitate to practice as much as you want with [minikube](https://minikube.sigs.k8s.io/docs/start/), even trying questions from the CKAD exam.

I loosely followed this order to study:
1. Reading the docs, following the curriculum sections proposed in the [walidshaari's Kubernetes Certified Administration repo](https://github.com/walidshaari/Kubernetes-Certified-Administrator)
2. Do [Kelsey Hightower "Kubernetes the Hard Way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), I did it several times until I got familiar with which certificates are needed, how to create ETCD, etc... the `multi-node-cluster` can be used to follow this guide
3. Try creating a cluster with a controller node and a worker node with kubeadm following [the official documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
4. Rinse and repeat creating a multi node cluster with kubeadm. There are scripts which will do it by you in the `multi-node-cluster`, you can check them if you get stuck.
5. Create a k8s cluster version 1.18, and upgrade it.
6. Go through all the [dgkanatsios' CKAD exercises](https://github.com/dgkanatsios/CKAD-exercises) at least two times. In the first run trying to gather all information from official documentation only and/or using `kubectl explain`, without minding the time, learing how to locate the information. On the second and subsequent runs, trying to be fast.
7. Trying the [CKA example exam questions](https://levelup.gitconnected.com/kubernetes-cka-example-questions-practical-challenge-86318d85b4d) (a cluster is also provided there).
8. Practice some ETCD backup and restore (not needed in a multi node environment, but it doesn't hurt doing it)

This is not a strict order, it helps to follow it to acquire the installation/upgrade knowledge, but if you don't want to focus in the same thing all the time you can mix it with attempting CKAD questions in the middle.

For the exam, you should get used to easily locate what you need in the documentation (learn how to quickly navigate and to find sections you may need in your travels).

I have seen many places which recommend to create several aliases for `kubectl` in order to type quicker in the exam, but my take on this is to just create the alias `alias k=kubectl` as in the exam you will be context-switching (specially if you go back or don't follow the questions order) and having to type several alias each time you do a context switch may backfire. Of course this is a personal opinion and if you prefer to use several aliases you should do it, just keep in mind that you may lose them with the context changing.

Another really good command you should get used is `kubectl explain` (and `kubectl explain --recursive`). It's very handful when you know what you are doing but you need to check exact names for the different fields of the object you are creating.

Finally, the `kubectl --dry-run=client -o yaml` trick to populate "skeleton" YAMLs which you can edit afterwards with anything you need. Learning how to create pods, deployments... with this helps a lot for the complex cases which are not supported by `kubectl`

## About the clusters
This a WIP section. Also, the intention of these clusters is to have a testbed where to practice for the CKA, with no other applications or purposes.

In the `kubernetes_clusters` folder you can spin up two kinds of Kubernetes clusters based on Vagrant machines. The Vagrantfile and the different provisioners are heavily based on [this fork from "kubernetes the hard way"](https://github.com/kinvolk/kubernetes-the-hard-way-vagrant). I started using that repository to play with k8s installations and I ended up building some scripts to have different practice environments. The clusters available are:

- "two-nodes-cluster": it contains a controller node and a worker node
- "multi-node-cluster": it spins up a lb, 3 controller nodes and 3 workers nodes (same setup than [Kelsey Hightower "Kubernetes the Hard Way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) )

I have set a 2GB memory size for each worker and controller node, but the controller probably would work with 1GB or less. You can also downsize the workers if you have memory constraints to run this cluster, it will only limit the size of the containers you can run inside.

When the clusters are created with the `start-full-*` scripts, they also provide:
- [Weaveworks network addon](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)
- Creating an StorageClass and several local volumes you can use for testing PVCs, StatefulSets...

### two-nodes-cluster
You can spin up a simple cluster with a controller node and a worker node with the script `start-full-two-node-cluster.sh`. It should take about 5 minutes to be ready, which is handy to practice with a running cluster. As it provision only some instances from the Vagrantfile, you can manually start more instances and try to join them in the cluster by yourself, as part of practice.

If you are interested only in creating the virtual machines but you want to test Kubernetes installation by yourself, you can use the script `start-two-nodes.sh`.

### multi-node-cluster
 Contains a LB for the controller nodes, 3 controller nodes and 3 worker nodes.

If you want to provision the "bare metal" cluster you only need to execute `vagrant up`. This will only create the VMs but you will have to install everything by yourself. This cluster can be used to follow the [Kelsey Hightower "Kubernetes the Hard Way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) (ignoring the parts where it sets up load balancers, as they are already in place) or if you want to provision a cluster following the [official guide using kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#external-etcd-nodes). In this case, I had to install ETCD separately as `kubeadm` was conflicting with the internal vagrant IP address, once ETCD was running you can install the rest of the nodes following the guide.

There are scripts to do the different installation steps if you want to speed up the process or if you bump into problems and need some inspiration to continue. There is also a `start-cluster.sh` script which do the `vagrant up` and runs the scripts until the cluster is fully provisioned. There is plenty of room for improvement on this script (and PRs are welcome!) as it's solely purpose is to mimic what someone should do manually to learn about installing k8s clusters. As there are not steps executed in parallel the provision is a bit slow (about 15 minutes in a modern laptop). Once provisioned `kubectl` will be available on `controller-0` node.

### TO-DO:
- [ ] allow selecting kubernetes version in the full provisioning script
- [ ] configure `kubectl` in all nodes
