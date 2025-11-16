terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "namespace" {
  source = "./modules/namespace"
  name   = "demo"
}

resource "kubernetes_config_map" "nginx_html" {
  metadata {
    name      = "nginx-html"
    namespace = module.namespace.name
  }

  data = {
    "index.html" = file("${path.module}/nginx-html/index.html")
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "demo-nginx"
    namespace = module.namespace.name
    labels = {
      app = "demo-nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "demo-nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo-nginx"
        }
      }

      spec {
        # New volume for custom HTML
        volume {
          name = "html"
          config_map {
            name = kubernetes_config_map.nginx_html.metadata[0].name
          }
        }

        container {
          name  = "nginx"
          image = "nginx:1.27"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html"
            name       = "html"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "nginx" {
  metadata {
    name      = "demo-nginx"
    namespace = module.namespace.name
  }

  spec {
    type = "NodePort"

    selector = {
      app = "demo-nginx"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      node_port   = 30080
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "nginx_hpa" {
  metadata {
    name      = "demo-nginx-hpa"
    namespace = module.namespace.name
  }

  spec {
    min_replicas = 1
    max_replicas = 3

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.nginx.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}
