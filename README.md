# NAGP Band 3 Assignment: Resilient Multi-Tier Cloud-Native Architecture

This repository contains the complete source code, deployment manifests, and operational lifecycle configurations for a resilient, self-healing, multi-tier employee management microservice architecture orchestrated on Kubernetes (K3s/EKS).

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

## 🎬 Screen Recording Verification Playbook

Follow these exact steps to execute a flawless live video demonstration or evaluation walkthrough:

### 📥 Step 1: External API Tier Connectivity & Baseline Check
Establish a secure presentation tunnel directly into the cluster's internal network:
```bash
kubectl port-forward svc/api-service -n assignment 8080:8000
```
* **Action:** Open your web browser or Postman and hit: `http://localhost:8080/employees`
* **Proof:** Show the 5 baseline records cleanly loaded from the `init.sql` schema injection file.

### 📝 Step 2: Full CRUD State Execution (Insert & Update Data)
* **Action:** Send an HTTP `POST` to `http://localhost:8080/employees` to append a new employee record:
  ```json
  { "name": "Frank", "role": "Cloud Architect", "department": "Platform" }
  ```
* **Action:** Send an HTTP `PUT` to `http://localhost:8080/employees/1` to modify Alice's role from `'DevOps Lead'` to `'Director of Infrastructure'`.

### 🩺 Step 3: Demonstrate Stateless Self-Healing (API Pod Destruction)
* **Action:** Open `k9s` or run `kubectl get pods -n assignment`. Select one of the 4 running `api-service` pods and force-delete it:
  ```bash
  kubectl delete pod <api-pod-name> -n assignment
  ```
* **Proof:** Highlight that the old pod drops into a `Terminating` state while Kubernetes instantly spins up a pristine replacement container to maintain the strict 4-replica threshold. Show that executing a `GET` command during this window encounters **zero downtime** due to active service load-balancing.

### 💾 Step 4: Demonstrate Stateful Persistence (Database Pod Destruction)
* **Action:** Target and force-kill the single running database stateful instance:
  ```bash
  kubectl delete pod postgres-db-0 -n assignment
  ```
* **Proof:** Watch the pod terminate and regenerate under the exact same stable network identifier (`postgres-db-0`). Once it transitions back to a green `Running` status, refresh your browser at `http://localhost:8080/employees`. 
* **Evaluation Highlighting:** Point out that **ID 6 (Frank) still exists** and **Alice's role remains updated**. This proves the data layer is stateful and anchored permanently to the underlying `PersistentVolumeClaim` instead of being bound to the transient lifespan of the container disk.
