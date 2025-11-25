# CS554 Project 2 — Terraform Infrastructure as Code
---
## Author: Sweekriti Gautam

This project provides hands-on experience with **Terraform** for provisioning and managing infrastructure in two separate local environments: a multi-container **Docker stack** and a lightweight **Kubernetes cluster (k3d)**. The goal was to demonstrate core Infrastructure as Code concepts, including modules, variables, state management, outputs, dependency graphs, and repeatable automation.

---

## Repository Structure

The project is split into two main directories:

* **`terraform-docker/`**: Terraform configuration for the three-tier Docker environment
    * `main.tf`
    * `variables.tf`
    * `terraform.tfvars` (for secrets, and credentials) 
    * `modules/` (contains `nginx/`, `backend/`, `postgres/`, `redis/` modules) 
* **`terraform-k8s/`**: Infrastructure files for managing the k3d Kubernetes cluster.
    * `main.tf`
    * `modules/` (contains `hpa/`, `namespace/`, `nginx/` modules) 
    * `nginx-html/` (contains `index.html`): custom Nginx homepage injected into the Deployment.
* **`Sweekriti_GautamProject2.docx`**: Contains the project summary, verification screenshots, and reflection paragraph.
---

## PART 1 — Docker Terraform Project

The objective was to provision a small "local cloud" three-tier stack using the `kreuzwerker/docker` provider.

### Architecture

The final stack consists of four interconnected containers running on a custom network (`demo-net`).

| Component | Description | Resources | Requirement Status |
| :--- | :--- | :--- | :--- |
| **Frontend** | **Nginx** container, exposed on **localhost:8080**. | `docker_container`, `docker_image` | **Module** used. |
| **Backend** | A Flask API microservice (`demo-backend`). | `docker_container`, `docker_image` | Connected internally. |
| **Database** | **PostgreSQL 15** container (`demo-postgres`). | `docker_volume` (`pgdata`), `docker_image`, `docker_container`. | Secrets passed via `.tfvars`. |
| **Enhancement** | **Redis 7** container (`demo-redis`). | `docker_image`, `docker_container` | Successfully deployed as an enhancement. |

### Setup and Verification

1.  **Initialize Terraform and Providers:**
    ```bash
    cd terraform-docker
    terraform init # Installs the docker provider
    ```

2.  **Apply Configuration (Iteratively):**
    ```bash
    # Apply initial network, Nginx, and other components
    terraform apply
    
    # Verify the running stack and custom network
    docker ps
    docker network ls 
    ```

3.  **Full Stack Verification:**
    ```bash
    # Test internal connectivity to the backend API 
    docker run --rm --network=demo-net curlimages/curl:latest curl http://demo-backend:5000
    
    # Verify Nginx external proxy to the backend
    # Access http://localhost:8080 in a browser
    ```

---

## PART 2 — Kubernetes Terraform Project

The objective is to use the **Kubernetes provider** to manage resources on a local `k3d` cluster.

### Cluster and Resources

The cluster used is named `demo-cluster`. All Kubernetes resources are deployed into a dedicated `demo` namespace.

| Resource | Type | Exposure | Requirement Status |
| :--- | :--- | :--- | :--- |
| **Namespace** | `demo` | N/A | Created successfully. |
| **Deployment** | `demo-nginx` | N/A | Deploys an Nginx pod with a custom index page. |
| **Service** | `demo-nginx` | **NodePort** on **30080** | Exposes the Nginx service externally. |
| **Enhancement** | **Horizontal Pod Autoscaler (HPA)** | N/A | Scales `demo-nginx` between 1 and 3 replicas based on CPU target. |

### Setup and Verification

1.  **Ensure k3d Cluster is Running:**
    ```bash
    k3d kubeconfig get demo-cluster
    kubectl get nodes # Should show 'k3d-demo-cluster-server-0' as Ready.
    ```

2.  **Initialize and Apply Configuration:**
    ```bash
    cd terraform-k8s
    terraform init # Initializes the Kubernetes provider
    
    # Apply all resources (Namespace, Deployment, Service, HPA)
    terraform apply
    ```

3.  **Verify Resources:**
    ```bash
    # Check Deployment and Pod status
    kubectl get deploy -n demo # Checks if Nginx Deployment exists and is running correctly.
    kubectl get pods -n demo # Checks if the actual Nginx Pod is running and healthy.
    
    # Check Service and HPA status
    kubectl get svc -n demo # Shows NodePort 30080 
    kubectl get hpa -n demo # Shows HPA configured for the deployment 
    ```

---

##  Reflection

This project helped me gain practical experience with Terraform by deploying infrastructure in a structured and repeatable way. In the **Docker part**, I learned how to build a fully modular setup that manages Nginx, a backend API, Postgres, and Redis, all connected through a custom Docker network. Using variables and a .tfvars file made the configuration more organized, secure, and easier to maintain. In the **Kubernetes part**, I learned how to create and manage a k3d cluster, configure kubectl, and use Terraform to deploy a namespace, deployment, service, and an HPA. I also created a custom index.html page and served it through the Nginx deployment, which helped me better understand how file mounting and container customization work in Kubernetes. Verifying each component step-by-step strengthened my understanding of how Terraform interacts with container orchestration systems. Overall, this project increased my confidence in Infrastructure as Code and showed me the value of automation across both Docker and Kubernetes environments.