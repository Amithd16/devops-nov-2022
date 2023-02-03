#!/bin/bash
[[ -z "$1" ]] && { echo "Enter the mode $0 <master>/<worker>"; exit 1; }

sudo apt update
sudo apt-get install -y apt-transport-https

sudo su - <<EOF
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list
EOF

sudo apt update
sudo apt install -y docker.io

sudo su - <<EOF
wget https://github.com/containerd/containerd/releases/download/v1.6.12/containerd-1.6.12-linux-amd64.tar.gz
tar xvf containerd-1.6.12-linux-amd64.tar.gz
systemctl stop containerd
cd bin
cp * /usr/bin/
systemctl start containerd
EOF

sudo systemctl start docker 
sudo systemctl enable docker.service 

sudo apt-get install -y kubeadm kubelet=1.25.5-00 kubectl kubernetes-cni

if [[ $1 == 'master' ]]; then 
sudo su - <<EOF
kubeadm init
EOF

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://docs.projectcalico.org/manifests/calico-typha.yaml

kubetl get nodes
fi  

if [[ $1 == 'worker' ]]; then 
sudo su - <<EOF
systemctl daemon-reload 
systemctl restart docker 
systemctl restart kubectl 
EOF

echo "Run the kubeadm join <TOKEN> command which we get from kubeadm init from master"
fi
