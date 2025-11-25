resource "kubernetes_config_map" "nginx_html" {
  metadata {
    name      = "nginx-html"
    namespace = var.namespace
  }

  data = {
    "index.html" = file(var.index_html_path)
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "demo-nginx"
    namespace = var.namespace
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
    namespace = var.namespace
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
      node_port   = var.node_port
    }
  }
}
