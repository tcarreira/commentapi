provider "kubernetes" {}
resource "kubernetes_namespace" "commentapi" {
  metadata {
    annotations = {
      name = "commentapi"
    }
    name = "commentapi"
  }
}

resource "kubernetes_secret" "database-secret" {
  metadata {
    name      = "database-secret"
    namespace = "commentapi"
  }

  data = {
    DATABASE_URL      = "postgres://${var.POSTGRES_USER}:${var.POSTGRES_PASSWORD}@${var.POSTGRES_HOST}:5432/${var.POSTGRES_DB}?sslmode=disable"
    POSTGRES_HOST     = var.POSTGRES_HOST
    POSTGRES_PORT     = "5432"
    POSTGRES_DB       = var.POSTGRES_DB
    POSTGRES_USER     = var.POSTGRES_USER
    POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
  }
}


resource "kubernetes_deployment" "commentapi" {
  metadata {
    name      = "commentapi"
    namespace = "commentapi"
    labels = {
      App = "CommentAPI"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "CommentAPI"
      }
    }
    template {
      metadata {
        labels = {
          App = "CommentAPI"
        }
      }
      spec {
        container {
          # image = "tcarreira/commentapi:sha-cc54cfd"
          image = "tutum/hello-world"
          name  = "commentapi"

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = "database-secret"
                key  = "DATABASE_URL"
              }
            }
          }

          port {
            container_port = 80
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
      }
    }
  }
}

resource "kubernetes_service" "commentapi" {
  metadata {
    name      = "commentapi"
    namespace = "commentapi"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      App = "CommentAPI"
    }
    
    port {
      name     = "http"
      port     = 80
      target_port = 80
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


resource "kubernetes_ingress" "commentapi" {
  metadata {
    name      = "commentapi"
    namespace = "commentapi"
  }

  wait_for_load_balancer = true

  spec {
    backend {
      service_name = "commentapi"
      service_port = 8080
    }

    rule {
      host = "commentapi.dev"
      http {
        path {
          backend {
            service_name = "commentapi"
            service_port = 8080
          }

          path = "/*"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}
