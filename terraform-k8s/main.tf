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

module "nginx" {
  source          = "./modules/nginx"
  namespace       = module.namespace.name
  node_port       = 30080
  index_html_path = "${path.module}/nginx-html/index.html"
}

module "nginx_hpa" {
  source          = "./modules/hpa"
  namespace       = module.namespace.name
  deployment_name = module.nginx.deployment_name
}
