


# wait for /tmp/kubeconfig to be wirtten"
resource "time_sleep" "wait_1min_demo" {
  count = var.deploy_metrics_server ? 1 : 0 
  depends_on = [
  local_file.kubeconfig
  ]
  create_duration = "30s"
}


resource "null_resource" "create_metrics_server" {
  count = var.deploy_metrics_server ? 1 : 0 
  depends_on = [time_sleep.wait_1min_demo]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig create -f https://raw.githubusercontent.com/oracle-devrel/oci-oke-virtual-nodes/main/metrics-server/components.yml" 

}

}





