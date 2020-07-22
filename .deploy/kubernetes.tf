provider "kubernetes" {}

resource "kubernetes_namespace" "application-namespace" {
  metadata {
    annotations = {
      name = "application-namespace"
    }

    name = "application-namespace"
  }
}

variable "POSTGRES_HOST" {}
variable "POSTGRES_PORT" {}
variable "POSTGRES_DB" {}
variable "POSTGRES_USER" {}
variable "POSTGRES_PASSWORD" {}

resource "kubernetes_secret" "database-secret" {
  metadata {
    name = "database-secret"
    namespace = "application-namespace"
  }

  data = {
    DATABASE_URL      = "postgres://${var.POSTGRES_USER}:${var.POSTGRES_PASSWORD}@${var.POSTGRES_HOST}:${var.POSTGRES_PORT}/${var.POSTGRES_DB}?sslmode=disable"
    POSTGRES_HOST     = var.POSTGRES_HOST
    POSTGRES_PORT     = var.POSTGRES_PORT
    POSTGRES_DB       = var.POSTGRES_DB
    POSTGRES_USER     = var.POSTGRES_USER
    POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
  }
}


resource "kubernetes_deployment" "application-deployment" {
  metadata {
    name      = "application-deployment"
    namespace = "application-namespace"
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
          image = "tcarreira/commentapi:sha-cc54cfd"
          # image = "tutum/hello-world"
          name = "commentapi"

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = "database-secret"
                key  = "DATABASE_URL"
              }
            }


            # value = "postgres://user:secretpass@postgres:5432/commentapi?sslmode=disable"
          }

          port {
            container_port = 80
          }
          port {
            container_port = 3000
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


resource "kubernetes_service" "application-service" {
  metadata {
    name      = "application-service"
    namespace = "application-namespace"
  }

  spec {
    selector = {
      App = "CommentAPI"
    }
    port {
      port        = 8080
      target_port = 3000
    }

    type = "NodePort"
  }
}


resource "kubernetes_ingress" "application-ingress" {
  metadata {
    name      = "application-ingress"
    namespace = "application-namespace"
  }

  wait_for_load_balancer = true

  spec {
    backend {
      service_name = "application-service"
      service_port = 8080
    }

    rule {
      host = "commentapi.dev"
      http {
        path {
          backend {
            service_name = "application-service"
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
