terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "postgres_user" {}
variable "postgres_password" {}
variable "postgres_db" {}
variable "network_name" {}

resource "docker_image" "postgres" {
  name = "postgres:15"
}

resource "docker_volume" "pgdata" {
  name = "pgdata"
}

resource "docker_container" "postgres" {
  name  = "demo-postgres"
  image = docker_image.postgres.name

  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}",
  ]

  mounts {
    target = "/var/lib/postgresql/data"
    source = docker_volume.pgdata.name
    type   = "volume"
  }

  networks_advanced {
    name = var.network_name
  }
}
