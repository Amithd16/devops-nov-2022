#!/bin/bash
echo $USER
function unkown_option() {
echo "Unknown K8S node type: $1"; 
echo "    This bash script will setup K8S cluster using kubeadm"
echo "       preffered Ubuntu 20.04_LTS with bellow requirement"
echo "       Master node:  minimum - 2GB RAM & 2Core CPU" 
echo "       Worker node:  Any"
echo "------------------------------ Master setup ------------------------------"
echo "       "
echo "    Enter the type node to setup (master / worker): master"
echo "       Save the kubeadm join <token> command to run on worker node"
echo "------------------------------ Master setup ------------------------------"
echo "    Enter the type node to setup (master / worker): worker"
echo "       Run the kubeadm join <token> command which we get from master node"
echo "--------------------------------------------------------------------------"
}

[[ "$1" == "--help" || "$1" == "help" || "$1" == "-h" ]] && { unkown_option; exit 0;}

read -p "    Enter the type node to setup (master / worker): " ntype
ntype="$(echo "$ntype" | awk '{print tolower($0)}')"
if [[ "$ntype" == 'master' ]]; then 
echo -e "\n-------------------------- K8S Master node setup --------------------------"
elif [[ "$ntype" == 'worker' ]]; then 
echo -e "\n-------------------------- K8S Worker node setup --------------------------"
else 
unkown_option $ntype
exit 0
fi

echo -e "\n-------------------------- Updating OS --------------------------\n"
sudo apt update
echo -e "\n-------------------------- APT transport for downloading pkgs via HTTPS --------------------------\n"
sudo apt-get install -y apt-transport-https

sudo su - <<EOF
echo -e "\n--------------------------  Adding K8S packgaes to APT list --------------------------\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list
EOF

echo -e "\n-------------------------- Installing docker.io --------------------------\n"
sudo apt update
sudo apt install -y docker.io

sudo su - <<EOF
echo -e "\n-------------------------- Updating container.io --------------------------\n"
wget https://github.com/containerd/containerd/releases/download/v1.6.12/containerd-1.6.12-linux-amd64.tar.gz
tar xvf containerd-1.6.12-linux-amd64.tar.gz
systemctl stop containerd
cd bin
cp * /usr/bin/
systemctl start containerd
EOF

echo -e "\n-------------------------- Starting and enabling docker.service --------------------------\n"
sudo systemctl start docker && echo "    Docker started"
sudo systemctl enable docker.service && echo "    docker.service enabled"

echo -e "\n-------------------------- Install kubeadm, kubelet, kubectl and kubernetes-cni --------------------------\n"
sudo apt-get install -y kubeadm kubelet=1.25.5-00 kubectl kubernetes-cni

if [[ "$ntype" == 'master' ]]; then 
echo -e "\n-------------------------- Initiating kubeadm (master node) --------------------------\n"
sudo su - <<EOF
kubeadm init
EOF

echo -e "\n-------------------------- Setiing-up Kubeconfig  --------------------------\n"
sleep 4
if [[ -d "/home/ubuntu" ]]; then 
mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config 
sudo chown $(id -u):$(id -g) /home/ubuntu/.kube/config
[[ -f "/home/ubuntu/.kube/config" ]] || echo "     Kubeconfig copied /home/ubuntu/.kube/config"
else 
echo "     Failed to setup Kubeconfig"
fi


sudo sysctl net.bridge.bridge-nf-call-iptables=1 &>/dev/null

echo -e "\n-------------------------- Copy the join <token> command --------------------------\n" 
echo "    We need to run this command in the worker node which we need to add to this node "
echo "      1. (Better save the join command in a seperate file for future use )"
echo "      2. To generate new join command:  kubeadm token create --print-join-command"
echo -e "\n-----------------------------------------------------------------------------------\n"

echo -e "\n-------------------------- Install weaveworks network cni --------------------------\n"
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
#kubectl apply -f https://docs.projectcalico.org/manifests/calico-typha.yaml 

echo -e "\n---------------------------------- Checking mater node status ---------------------------\n"
kubectl get nodes
echo -e "\n Waiting to master node to get Ready ...........\n"
sleep 15
kubectl get nodes
echo
echo "    Note: wait to for 5-10 minutes, if node is still not in Ready state then try to install below calico network cni "
echo "          RUN: kubectl apply -f https://docs.projectcalico.org/manifests/calico-typha.yaml"
echo "          RUN: kubectl get nodes"
echo -e "\n-----------------------------------------------------------------------------------"
fi  

if [[ "$ntype" == 'worker' ]]; then 
sudo su - <<EOF
systemctl daemon-reload 
systemctl restart docker 
EOF

echo "Run the kubeadm join <TOKEN> command which we get from kubeadm init from master"
fi
