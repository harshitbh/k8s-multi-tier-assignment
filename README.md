# NAGP Band 3 Assignment: Resilient Multi-Tier Cloud-Native Architecture

This repository contains the complete source code, deployment manifests, and operational lifecycle configurations for a resilient, self-healing, multi-tier employee management microservice architecture orchestrated on Kubernetes (K3s/EKS).

---

## 🔗 Core Delivery Index Links
* **Code Repository URL:** `https://github.com/harshitbh/k8s-multi-tier-assignment`
* **Docker Hub Target Image URL:** `https://hub.docker.com/r/hbhargava2/api-service/tags`
* ** Service API Tier Public URL:** `http://54.196.28.22/employees` (deleted after aws resource deletion)

---

## 🚀 Repository Contents
* `main.py` - FastAPI CRUD Application handling business logic, database migrations, and connection resilience loops.
* `Dockerfile` - Ultra-lightweight multi-stage container build based on Alpine Linux.
* `requirements.txt` - Python dependency matrix.
* `app-config.yaml` - Externalized structural configurations (ConfigMap) decoupled from runtime code.
* `app-secret.yaml` - Cryptographically isolated database credentials (Opaque Secret).
* `postgres.yaml` - Stateful database tier driven by a **StatefulSet**, persistent volume tracking, and automated schema init scripting.
* `api.yaml` - Highly available stateless application tier with fine-tuned FinOps resource allocations, liveness probes, and a RollingUpdate rollout engine.
* `hpa-ingress.yaml` - Auto-scaling metrics controller (HPA) alongside NGINX unified cluster ingress routing.

---

## 📦 Container Lifecycle Management

### 1. Build and Package the Application Container
Execute the following commands from the root directory to bundle and tag the stateless API layer:
```bash
docker build -t hbhargava2/api-service:v2 .
```

### 2. Distribute to Container Registry
Push the pre-compiled application image up to Docker Hub:
```bash
docker push hbhargava2/api-service:v2
```

---

## ☸️ Cluster Deployment Pipeline

To deploy the entire production-ready stack into your Kubernetes cluster, run the following manifests sequentially:

```bash
# Step 1: Establish Namespace and Externalized Configuration Mappings
kubectl apply -f app-config.yaml
kubectl apply -f app-secret.yaml

# Step 2: Initialize the Stateful Storage & Database Engine
kubectl apply -f postgres.yaml

# Step 3: Deploy the High-Availability API Microservice Tier
kubectl apply -f api.yaml

# Step 4: Scale and Route Traffic via HPA and Ingress Controllers
kubectl apply -f hpa-ingress.yaml
```

---

