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

module "postgres" {
  source = "./modules/postgres"

  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  postgres_db       = var.postgres_db

  network_name = docker_network.demo.name
}

module "backend" {
  source = "./modules/backend"

  db_host = "demo-postgres"
  db_user = var.postgres_user
  db_pass = var.postgres_password
  db_name = var.postgres_db

  network_name = docker_network.demo.name
}

module "nginx" {
  source = "./modules/nginx"

  network_name = docker_network.demo.name
}

module "redis" {
  source = "./modules/redis"

  network_name = docker_network.demo.name
}
