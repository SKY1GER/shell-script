#!/bin/bash
set -e

echo "=== Updating packages ==="
#sudo yum update -y
#sudo yum install -y git curl tar gzip

# --------------------------------------------------------
# Install kubectl
# --------------------------------------------------------
echo "=== Installing kubectl ==="
KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

# --------------------------------------------------------
# Install eksctl
# --------------------------------------------------------
echo "=== Installing eksctl ==="
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# --------------------------------------------------------
# Install kubectx & kubens
# --------------------------------------------------------
echo "=== Installing kubectx & kubens ==="
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens

echo "=== Installation completed successfully! ==="
