resource "kubernetes_namespace" "nginx-ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "nginx-deployment" {
  metadata {
    name      = var.deployment-name
    namespace = var.namespace
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
          volume_mount {
            name       = "nginx-config-volume"
            mount_path = "etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
            read_only  = true
          }
        }
        volume {
          name = "nginx-config-volume"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx-service" {
  metadata {
    name      = var.ingress-service-name
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
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "nginx-ingress" {
  metadata {
    name      = var.ingress
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = var.ingress-service-name
              port {
                number = 9988
              }
            }
          }
        }
      }
    }
  }
}

resource "helm_release" "nginx-ingress" {
  name = "nginx-ingress"
  # namespace  = "kube-system"
  namespace  = var.namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.1" # Ensure the version fits your Kubernetes setup
  # timeout = 600

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "NodePort" # Change to LoadBalancer if you want that type
  }

  set {
    name  = "controller.scope.enabled"
    value = "false"
  }
}

resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-config"
    namespace = var.namespace
  }

  data = {
    "nginx.conf" = file("${path.module}/nginx-config/nginx.conf")
  }

}

