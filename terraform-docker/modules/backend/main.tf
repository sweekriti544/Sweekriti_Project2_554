terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "db_host" {}
variable "db_user" {}
variable "db_pass" {}
variable "db_name" {}
variable "network_name" {}

resource "docker_image" "backend" {
  name = "demo-backend"

  build {
    context = "${path.root}/backend"
  }
}

resource "docker_container" "backend" {
  name  = "demo-backend"
  image = docker_image.backend.name

  env = [
    "DB_HOST=${var.db_host}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_pass}",
    "DB_NAME=${var.db_name}",
  ]

  networks_advanced {
    name = var.network_name
  }
}
