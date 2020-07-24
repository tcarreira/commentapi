resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }
    name = "monitoring"
  }
}

resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus"
    annotations = {
      name = "prometheus"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "nodes", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = "monitoring"
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = "monitoring"
  }
}

resource "kubernetes_config_map" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = "monitoring"
  }

  data = {
    "prometheus.yml" = "${file("${path.module}/3.prometheus.yml")}"
  }
}


resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "prometheus"
      }
    }
    template {
      metadata {
        labels = {
          App = "prometheus"
        }
      }
      spec {
        service_account_name = "prometheus"
        container {
          image = "prom/prometheus:v2.19.2"
          name  = "prometheus"

          port {
            container_port = 9090
            name = "default"
          }

          volume_mount {
            name = "prometheus-config"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.prometheus.default_secret_name
            read_only  = true
          }

          # volume_mount {
          #   mount_path = "/var/run/secrets/kubernetes.io/serviceaccount/token:"
          #   name       = kubernetes_service_account.prometheus.default_secret_name
          #   read_only  = true
          # }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }

        volume {
          name = "prometheus-config"
          config_map {
            name = "prometheus"
          }
        }

        volume {
          name = kubernetes_service_account.prometheus.default_secret_name
          secret {
            secret_name = kubernetes_service_account.prometheus.default_secret_name
          }
        }


      }
    }
  }
}


resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      App = "prometheus"
    }
    
    port {
      name     = "http"
      port     = 9090
      target_port = 9090
      protocol = "TCP"
    }

    port {
      name     = "https"
      port     = 443
      target_port = 80
      protocol = "TCP"
    }

  }
}