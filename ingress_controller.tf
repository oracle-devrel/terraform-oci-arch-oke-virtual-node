provider "kubernetes" {
    config_path = "/tmp/kubeconfig"
}



# wait for /tmp/kubeconfig to be wirtten"
resource "time_sleep" "wait_1min_demo2" {
  count = var.deploy_metrics_server ? 1 : 0 
  depends_on = [
  local_file.kubeconfig
  ]
  create_duration = "30s"
}


resource "null_resource" "create_ingress_controller" {
  count = var.deploy_ingress_controller ? 1 : 0 
  depends_on = [time_sleep.wait_1min_demo2]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig create -f https://raw.githubusercontent.com/oracle-devrel/oci-oke-virtual-nodes/main/ingress-nginx/deploy.yaml" 

}

}





