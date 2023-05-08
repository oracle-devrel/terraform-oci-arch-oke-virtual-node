
resource "local_file" "kubeconfig" {
  count = var.create_metrics_server ? 1 : 0  
   depends_on = [
  oci_containerengine_virtual_node_pool.create_node_pool_details0
  ] 
  content  = data.oci_containerengine_cluster_kube_config.virtual_cluster_kube_config.content
  filename = "/tmp/kubeconfig"
}



provider "kubernetes" {
  config_path = "/tmp/kubeconfig"
  config_context = "my-context"
}


resource "kubernetes_service_account" "metrics_server" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"

    labels = {
      k8s-app = "metrics-server"
    }
  }
}

resource "kubernetes_cluster_role" "system_aggregated_metrics_reader" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name = "system:aggregated-metrics-reader"

    labels = {
      k8s-app = "metrics-server"

      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"

      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"

      "rbac.authorization.k8s.io/aggregate-to-view" = "true"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
  }
}

resource "kubernetes_cluster_role" "system_metrics_server" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name = "system:metrics-server"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["nodes/metrics"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods", "nodes"]
  }
}

resource "kubernetes_role_binding" "metrics_server_auth_reader" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name      = "metrics-server-auth-reader"
    namespace = "kube-system"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
}

resource "kubernetes_cluster_role_binding" "metrics_server_system_auth_delegator" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name = "metrics-server:system:auth-delegator"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
}

resource "kubernetes_cluster_role_binding" "system_metrics_server" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name = "system:metrics-server"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:metrics-server"
  }
}

resource "kubernetes_service" "metrics_server" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  spec {
    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "https"
    }

    selector = {
      k8s-app = "metrics-server"
    }
  }
}

resource "kubernetes_deployment" "metrics_server" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "metrics-server"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "metrics-server"
        }
      }

      spec {
        volume {
          name      = "tmp-dir"
          empty_dir = {}
        }

        container {
          name  = "metrics-server"
          image = "registry.k8s.io/metrics-server/metrics-server:v0.6.3"
          args  = ["--cert-dir=/tmp", "--secure-port=4443", "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname", "--kubelet-use-node-status-port", "--metric-resolution=15s"]

          port {
            name           = "https"
            container_port = 4443
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu = "100m"

              memory = "200Mi"
            }

            requests = {
              cpu = "100m"

              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user     = 1000
            run_as_non_root = true
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "metrics-server"
        priority_class_name  = "system-cluster-critical"
      }
    }
  }
}

resource "kubernetes_api_service" "v_1_beta_1__metrics_k_8_s_io" {
  count = var.create_metrics_server ? 1 : 0 
  metadata {
    name = "v1beta1.metrics.k8s.io"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  spec {
    service {
      namespace = "kube-system"
      name      = "metrics-server"
    }

    group                    = "metrics.k8s.io"
    version                  = "v1beta1"
    insecure_skip_tls_verify = true
    group_priority_minimum   = 100
    version_priority         = 100
  }
}

