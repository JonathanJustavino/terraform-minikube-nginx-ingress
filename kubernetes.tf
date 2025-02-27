resource "kubernetes_namespace" "nginx-ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "nginx-deployment" {
  metadata {
    name      = var.deployment-name
    namespace = kubernetes_namespace.nginx-ns.metadata[0].name
    labels = {
      app = var.app_label
    }
  }
  spec {
    selector {
      match_labels = {
        app = var.app_label
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_label
        }
      }
      spec {
        container {
          name  = var.container_name
          image = var.nginx-image-version
          port {
            container_port = 9988
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ingress-service" {
  metadata {
    name = var.ingress-service-name
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.app_label
    }
    port {
      port        = 9988
      target_port = 9988
      protocol    = "TCP"
    }
  }
}

# resource "kubernetes_ingress_v1" "nginx-ingress" {
#   metadata {
#     name      = var.ingress
#     namespace = var.namespace
#   }
#   spec {
#     rule {
#       # host = "backend.io"
#       http {
#         path {
#           path = "/*"
#           backend {
#             service {
#               name = var.ingress-service-name
#               port {
#                 number = 9988
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.1"  # Ensure the version fits your Kubernetes setup

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "NodePort"  # Change to LoadBalancer if you want that type
  }
}

