terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "demo" {
  name = "demo-net"
}

resource "docker_container" "nginx" {
  name  = "demo-nginx"
  image = "nginx:latest"

  networks_advanced {
    name = docker_network.demo.name
  }

  ports {
    internal = 80
    external = 8080
  }
}
