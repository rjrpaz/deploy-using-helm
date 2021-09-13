# Configure providers
# kubernetes: to control kubernetes cluster
#   according to what is configured in "~/.kube/config"
# helm: to install helm packages
#
provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create namespace
resource "kubernetes_namespace" "tr-webapp-ns" {
  metadata {
    name = var.namespace
  }
}

# Install traefik
resource "helm_release" "traefik_ingress" {
  name       = "traefik"

  repository = "https://helm.traefik.io/traefik/"
  chart      = "traefik"
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  depends_on = [ kubernetes_namespace.tr-webapp-ns ]
}

# Install app package
resource "helm_release" "tr-webapp" {
  name       = "tr-webapp"

  repository = "https://www.robertopaz.com.ar/deploy-using-helm/"
  chart      = "tr-webapp"
  namespace  = var.namespace

  depends_on = [ kubernetes_namespace.tr-webapp-ns ]
}

# Create ingress entry point
resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = "traefik"
    namespace  = var.namespace
  }

  spec {
    backend {
      service_name = "tr-webapp"
      service_port = 8080
    }

    rule {
      host = "hello-world.local"
      http {
        path {
          backend {
            service_name = "tr-webapp"
            service_port = 8080
          }

          path = "/"
        }
      }
    }
  }
}

