terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "network_name" {}

resource "docker_container" "nginx" {
  name  = "demo-nginx"
  image = "nginx:latest"

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 80
    external = 8080
  }

  mounts {
    source = abspath("${path.module}/nginx.conf")
    target = "/etc/nginx/conf.d/default.conf"
    type   = "bind"
  }
}

