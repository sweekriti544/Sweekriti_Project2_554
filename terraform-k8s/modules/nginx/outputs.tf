output "deployment_name" {
  value = kubernetes_deployment.nginx.metadata[0].name
}
