
resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
    namespace = "commentapi"
    labels = {
      App = "postgres"
    }
  }


  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          App = "postgres"
        }
      }
      spec {
        container {
          image = "postgres:11-alpine"
          name  = "postgres"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_DB"
            value = "commentapi"
          }
          env {
            name = "POSTGRES_USER"
            value = "user"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "secretpass"
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name = "pgdata"
          }

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
          name = "pgdata"
          host_path {
            path = "/commentapi-pgdata"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    namespace = "commentapi"
  }
  spec {
    selector = {
      App = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }

    type = "NodePort"
  }
}

