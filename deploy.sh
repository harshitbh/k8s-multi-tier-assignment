#!/bin/bash
set -e

echo "===================================================="
echo "📦 PHASE 0: SYSTEM INITIALIZATION & PROJECT FETCHING"
echo "===================================================="

# Check and setup Git environment dependency dynamically
echo "🌿 Checking Git availability..."
if ! command -v git &> /dev/null; then
    echo "📥 Installing Git core utilities engine..."
    sudo dnf install git -y
else
    echo "✅ Git execution engine is already active."
fi

# Automate repository downloading safely
REPO_DIR="k8s-multi-tier-assignment"
REPO_URL="https://github.com/harshitbh/k8s-multi-tier-assignment.git"

if [ ! -d "$REPO_DIR" ]; then
    echo "📥 Cloning project repository fresh from cloud source..."
    git clone "$REPO_URL"
    cd "$REPO_DIR"
else
    echo "🔄 Existing project workspace detected. Syncing head changes..."
    cd "$REPO_DIR"
    git pull origin main || echo "⚠️ Working directory detached or branch mismatched. Proceeding with active directory content."
fi

echo "===================================================="
echo "🛠️  PHASE 1: INSTANCE UTILITIES & CLUSTER TOOLING SETUP"
echo "===================================================="

# 1. Setup container virtualization host runtime engine dynamically
echo "🐳 Checking Docker engine availability..."
if ! command -v docker &> /dev/null; then
    sudo dnf install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo "⚠️ Docker installed. If group permissions fail, please run 'newgrp docker' manually."
else
    echo "✅ Docker container visualization host is active."
fi

# 2. Provision lightweight cloud-native K3s node runtime engine
echo "☸️ Checking K3s runtime setup..."
if ! command -v k3s &> /dev/null; then
    echo "📥 Downloading and spinning up K3s Cluster..."
    curl -sfL https://get.k3s.io | sh -
else
    echo "✅ K3s engine layer is already active."
fi

# 3. Sync up cluster access credentials securely with local user context environment profile
echo "🔐 Synchronizing Kubeconfig parameters for local execution context..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

echo "===================================================="
echo "🐳 PHASE 2: APPLICATION PACKAGING & INTERNAL ROUTING"
echo "===================================================="

# 4. Compile the local python application into a structured docker container image
echo "🔨 Compiling Docker image locally from active root path..."
sudo docker build -t hbhargava2/api-service:v2 .

# ===================================================================
# 🔑 SECURITY ENGINE: AUTHENTICATE AND PUSH TO DOCKER HUB REGISTRY
# ===================================================================
echo "🔐 Authenticating with public cloud registry..."
if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
    # 'sudo -E' passes your exported terminal variables directly into the root command context
    echo "$DOCKER_PASSWORD" | sudo -E docker login -u "$DOCKER_USERNAME" --password-stdin
    
    echo "📤 Synchronizing and pushing image to remote Docker Hub..."
    sudo -E docker push hbhargava2/api-service:v2
else
    echo "❌ ERROR: DOCKER_USERNAME or DOCKER_PASSWORD is not set in your terminal environment!"
    echo "👉 Please run 'export DOCKER_USERNAME=...' and 'export DOCKER_PASSWORD=...' before executing this script."
    exit 1
fi
# ===================================================================

# 5. Force import the image directly into K3s containerd local cache layer to bypass Docker Hub
echo "📦 Injecting image directly into K3s internal registry archive cache..."
sudo docker save hbhargava2/api-service:v2 | sudo k3s ctr images import -

echo "===================================================="
echo "🚀 PHASE 3: DEPLOYING RESILIENT KUBERNETES MANIFESTS"
echo "===================================================="

# 6. Create target deployment namespace workspace safely
echo "📦 Setting up Kubernetes Namespace..."
kubectl create namespace assignment --dry-run=client -o yaml | kubectl apply -f -

# 7. Apply split configuration arrays out of the manifests/ folder
echo "🔐 Injecting ConfigMaps and Opaque Secrets..."
kubectl apply -f manifests/app-config.yaml
kubectl apply -f manifests/app-secret.yaml

# 8. Provision stable storage and stateful set database instance
echo "🗄️ Initializing Stateful PostgreSQL Cluster..."
kubectl apply -f manifests/postgres.yaml

# ===================================================================
# 🛡️ POSTGRES POD REGISTRATION SAFETY CHECK
# ===================================================================
echo "⏳ Waiting for Kubernetes control plane to register the database pod..."
until kubectl get pod postgres-db-0 -n assignment &>/dev/null; do
    echo "⏱️ Pod object not registered yet. Re-checking in 2 seconds..."
    sleep 2
done
# ===================================================================

# 9. Wait loop engine for database pod readiness before launching the API
echo "⏱️ Waiting for database pod to reach a healthy status..."
kubectl wait --namespace=assignment \
  --for=condition=Ready pod/postgres-db-0 \
  --timeout=60s

# 10. Spin up multi-replica API microservice deployment arrays from the manifests/ folder
echo "⚡ Deploying stateless API (4 replicas) and Routing Engine..."
kubectl apply -f manifests/api.yaml
kubectl apply -f manifests/hpa-ingress.yaml

# ===================================================================
# 📥 AUTOMATED K9S MONITORING SETUP
# ===================================================================
if ! command -v k9s &> /dev/null; then
    echo "📥 Installing K9s Terminal Monitoring Interface..."
    wget -q https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
    tar -xzf k9s_Linux_amd64.tar.gz k9s
    sudo mv k9s /usr/local/bin/
    rm -f k9s_Linux_amd64.tar.gz
    echo "✅ K9s Monitoring Engine compiled successfully."
fi
# ===================================================================

echo "===================================================="
echo "✅ DEPLOYMENT SYSTEM ONLINE AND READY FOR EVALUATION!"
echo "👉 Type 'k9s' in your terminal to view the dashboard."
echo "===================================================="