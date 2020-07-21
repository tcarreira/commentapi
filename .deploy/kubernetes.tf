provider "kubernetes" {}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "scalable-nginx-example"
    labels = {
      App = "ScalableNginxExample"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "ScalableNginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableNginxExample"
        }
      }
      spec {
        container {
          image = "tcarreira/commentapi:sha-cc54cfd"
          # image = "tutum/hello-world"
          name  = "example"

          env {
            name = "DATABASE_URL"
            value = "postgres://user:secretpass@postgres:5432/commentapi_production?sslmode=disable"
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


resource "kubernetes_service" "nginx-example" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = "ScalableNginxExample"
    }
    port {
      port        = 8080
      target_port = 3000
    }

    type = "NodePort"
  }
}


resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = "example-ingress"
  }

  wait_for_load_balancer = true

  spec {
    backend {
      service_name = "nginx-example"
      service_port = 8080
    }

    rule {
      host = "commentapi.dev"
      http {
        path {
          backend {
            service_name = "nginx-example"
            service_port = 8080
          }

          path = "/app1/*"
        }

        path {
          backend {
            service_name = "nginx-example"
            service_port = 8080
          }

          path = "/app2/*"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}
