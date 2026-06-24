# NAGP Band 3 Assignment: Resilient Multi-Tier Cloud-Native Architecture

This repository contains the complete source code, deployment manifests, and operational lifecycle configurations for a resilient, self-healing, multi-tier employee management microservice architecture orchestrated on Kubernetes (K3s/EKS).

---

## 🔗 Core Delivery Index Links
* Code Repository URL: [https://github.com/harshitbh/k8s-multi-tier-assignment](https://github.com/harshitbh/k8s-multi-tier-assignment)
* Docker Hub Target Image URL: [https://hub.docker.com/r/hbhargava2/api-service/tags](https://hub.docker.com/r/hbhargava2/api-service/tags)
* Service API Tier Public URL: [http://54.196.28.22/employees](http://54.196.28.22/employees) (Note: Cleaned up post AWS validation)

---

## 🚀 Repository Contents
* main.py - FastAPI CRUD Application handling core business logic, connection pooling, and error resilience loops.
* Dockerfile - Ultra-lightweight multi-stage container build optimized for micro-footprints.
* requirements.txt - Core Python dependency matrix.
* deploy.sh - Master orchestration engine that bootstraps K3s, handles registry auth, builds images, and coordinates cluster rollout phases.
* app-config.yaml - Externalized structural configurations (ConfigMap) decoupled from runtime code.
* app-secret.yaml - Cryptographically isolated database credentials (Opaque Secret).
* postgres.yaml - Stateful database tier driven by a StatefulSet, persistent volume tracking, and automated schema init seeding.
* api.yaml - Highly available stateless application tier with fine-tuned FinOps resource allocations, liveness probes, and a RollingUpdate rollout engine.
* hpa-ingress.yaml - Dynamic auto-scaling metrics controller (HPA) paired with a native Traefik Ingress Controller framework.

---

## 📦 Automated Deployment Pipeline (deploy.sh)

The entire environment setup, image compilation, registry synchronization, and cluster orchestration lifecycle is completely automated using the deploy.sh engine script. 

### 🚀 One-Touch Automation Run Book
To bootstrap your local runtime sandbox, sync up cloud credentials, and initialize the entire production-ready application tier seamlessly, execute the following commands:

# Step 1: Export your secure Docker Hub credentials into the active terminal session
export DOCKER_USERNAME="hbhargava2"
export DOCKER_PASSWORD="your_secure_dockerhub_access_token"

# Step 2: Grant execution permissions and run the master deployment pipeline script
chmod +x deploy.sh
./deploy.sh

### ⚙️ Core Pipeline Workflows Executed Behind the Scenes
Behind the scenes, the deploy.sh script automates the following phases sequentially:
* Host Setup & Dependencies: Automatically checks and provisions the local Docker runtime environment on the host machine.
* K3s Cluster Bootstrapping: Installs and configures a localized cloud-native K3s node instance.
* Context Synchronization: Copies and permissions the local kubeconfig parameter path to grant effortless cluster administrative control.
* Image Compilation: Builds the optimized multi-stage Python container application tagged as hbhargava2/api-service:v2.
* Registry Synchronization: Authenticates directly with Docker Hub using your exported token variables and pushes the image asset.
* Internal Image Injection: Force-saves and imports the compiled image directly into K3s's internal containerd image cache to guarantee rapid pod scheduling cycles.
* Namespace & Resource Isolation: Dynamically provisions the independent, application-dedicated namespace (assignment) along with all ConfigMap and base64-encoded Secret manifests.
* Stateful Persistence Initialization: Applies the StatefulSet storage profile (postgres-db-0) backed by a 1Gi local storage volume claim and seeds exactly 5 initial records automatically via an embedded schema initiation script.
* Resilience Verification Loop: Runs a synchronous watch loop that pauses downstream deployment steps until the database pod moves into a verified Ready condition.
* Stateless Scale & Routing Rollout: Provisions your 4 high-availability API deployment replicas configured with non-disruptive RollingUpdate parameters, scales up to 8 based on a 50% CPU metric threshold using the HorizontalPodAutoscaler, and hooks up path-based public traffic routing via the native Traefik Ingress Controller.
* Dashboard Tooling Integration: Automatically downloads and sets up the k9s terminal UI client to provide instantaneous observability into cluster health.

---

## ☸️ Manual Alternative Step-by-Step Manifest Pipeline

If you need to troubleshoot individual component layers or prefer applying the manifests manually step-by-step into an existing pre-configured cluster instead of running the automated script, use the following execution flow:

# Step 1: Establish Namespace Boundaries and Configuration Maps
kubectl apply -f app-config.yaml
kubectl apply -f app-secret.yaml

# Step 2: Initialize the Stateful Storage Persistence Layer & Database Engine
kubectl apply -f postgres.yaml

# Step 3: Deploy the High-Availability Stateless API Microservice Tier
kubectl apply -f api.yaml

# Step 4: Scale and Route Traffic via HPA Metrics and Traefik Ingress Rules
kubectl apply -f hpa-ingress.yaml

---

## 📊 Infrastructure Verification & Architectural Specifications

### 1. Ingress Class & Routing
Traffic ingestion utilizes "ingressClassName: traefik" mapped to external domain path lines. It completely avoids proprietary cloud provider load-balancer overhead by maintaining software-defined path routing profiles natively inside the single EC2 node space.

### 2. High Availability & Rolling Update Controls
* Replica Baseline: The stateless API microservice launches with a guaranteed baseline of 4 active pod replicas.
* Rollout Boundaries: Controlled via zero-downtime constraints:
  - maxSurge: 1
  - maxUnavailable: 0

### 3. Strict FinOps Resource Bounds
To stay safely inside low-cost limits and lightweight footprints, strict resource parameters have been calculated and enforced inside the application specification sheet:
* CPU Requests: 40m | Memory Requests: 32Mi
* CPU Limits: 80m | Memory Limits: 64Mi
* Autoscaling Target: Scales horizontally from a minimum of 4 pods to a maximum of 8 pods as soon as the cluster experiences an average CPU utilization threshold of 50%.