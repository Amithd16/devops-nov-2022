#!/bin/bash

function unkown_option() {
echo "Unknown option $1 -s $2"; 
echo -e "    This bash script will setup K8S cluster using kubeadm \n       (preffered Ubuntu 20.04_LTS)"
echo "------------------------------ Master setup ------------------------------"
echo "    FOR mater node setup: curl -s <url> | sudo bash -s master"
echo "       Save the kubeadm join <token> command to run on worker node"
echo "------------------------------ Master setup ------------------------------"
echo "    FOR worker node setup: curl -s <url> | sudo bash -s worker"
echo "       Run the kubeadm join <token> command which we get from master node"
echo "--------------------------------------------------------------------------"
exit 1;
}

[[ -z "$1" ]] && { unkown_option $0 $1; }

if [[ "$1" == 'master' ]]; then 
echo -e "\n-------------------------- K8S Master node setup --------------------------"
elif [[ "$1" == 'worker' ]]; then 
echo -e "\n-------------------------- K8S Worker node setup --------------------------"
else 
unkown_option $0 $1
fi

echo -e "\n-------------------------- Update OS --------------------------\n"
sudo apt update
echo -e "\n-------------------------- APT transport for downloading pkgs via HTTPS --------------------------\n"
sudo apt-get install -y apt-transport-https

sudo su - <<EOF
echo -e "\n--------------------------  Adding K8S packgaes to APT list --------------------------\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list
EOF

echo -e "\n-------------------------- Install docker.io --------------------------\n"
sudo apt update
sudo apt install -y docker.io

sudo su - <<EOF
echo -e "\n-------------------------- Update container.io --------------------------\n"
wget https://github.com/containerd/containerd/releases/download/v1.6.12/containerd-1.6.12-linux-amd64.tar.gz
tar xvf containerd-1.6.12-linux-amd64.tar.gz
systemctl stop containerd
cd bin
cp * /usr/bin/
systemctl start containerd
EOF

echo -e "\n-------------------------- Start and enable docker.service --------------------------\n"
sudo systemctl start docker 
sudo systemctl enable docker.service 

echo -e "\n-------------------------- Install kubeadm, kubelet, kubectl and kubernetes-cni --------------------------\n"
sudo apt-get install -y kubeadm kubelet=1.25.5-00 kubectl kubernetes-cni

if [[ $1 == 'master' ]]; then 
echo -e "\n-------------------------- Initiate kubeadm (master node) --------------------------\n"
sudo su - <<EOF
kubeadm init
EOF

echo -e "\n-------------------------- Kubeconfig setup --------------------------\n"
sleep 4
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
[[ -d "$HOME/.kube" ]] || echo "     Failed to setup Kubeconfig"

sudo sysctl net.bridge.bridge-nf-call-iptables=1 &>/dev/null

echo -e "\n-------------------------- Copy the join <token> command --------------------------\n" 
echo "       We need to run this command in the worker node which we need to add to this node "
echo "         (Better save the join command in a seperate file for future use )"
echo "          To generate new join command:  kubeadm token create --print-join-command"
echo -e "\n-----------------------------------------------------------------------------------\n"

echo -e "\n-------------------------- Install weaveworks network cni --------------------------\n"
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
#kubectl apply -f https://docs.projectcalico.org/manifests/calico-typha.yaml 

echo -e "\n---------------------------------- Node List ---------------------------\n"
kubectl get nodes
echo "       Note: if node is not in Ready state then try to install below calico network cni "
echo "                  RUN: kubectl apply -f https://docs.projectcalico.org/manifests/calico-typha.yaml"
echo "                  RUN: kubectl get nodes"
echo -e "\n-----------------------------------------------------------------------------------"
fi  

if [[ $1 == 'worker' ]]; then 
sudo su - <<EOF
systemctl daemon-reload 
systemctl restart docker 
EOF

echo "Run the kubeadm join <TOKEN> command which we get from kubeadm init from master"
fi
