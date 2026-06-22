#!/bin/bash
set -e

echo "===================================================="
echo "🚀 STARTING RESILIENT MICROSERVICE DEPLOYMENT PIPELINE"
echo "===================================================="

# 1. Create target deployment namespace workspace safely
echo "📦 Setting up Kubernetes Namespace..."
kubectl create namespace assignment --dry-run=client -o yaml | kubectl apply -f -

# 2. Apply split configuration arrays out of the manifests/ folder
echo "🔐 Injecting ConfigMaps and Opaque Secrets..."
kubectl apply -f manifests/app-config.yaml
kubectl apply -f manifests/app-secret.yaml

# 3. Provision stable storage and stateful set database instance
echo "🗄️ Initializing Stateful PostgreSQL Cluster..."
kubectl apply -f manifests/postgres.yaml

# 4. Wait loop engine for database pod readiness before launching the API
echo "⏱️ Waiting for database pod to reach a healthy status..."
kubectl wait --namespace=assignment \
  --for=condition=Ready pod/postgres-db-0 \
  --timeout=60s

# 5. Spin up multi-replica API microservice deployment arrays from the manifests/ folder
echo "⚡ Deploying stateless API (4 replicas) and Routing Engine..."
kubectl apply -f manifests/api.yaml
kubectl apply -f manifests/hpa-ingress.yaml

echo "===================================================="
echo "✅ DEPLOYMENT SYSTEM ONLINE AND READY FOR EVALUATION!"
echo "===================================================="