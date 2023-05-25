provider "kubernetes" {
    config_path = "/tmp/kubeconfig"
}

# wait for /tmp/kubeconfig to be written"
resource "time_sleep" "wait_1min_demo2" {
  count = var.deploy_ingress_controller ? 1 : 0 
  depends_on = [
  local_file.kubeconfig
  ]
  create_duration = "20s"
}


resource "null_resource" "create_ingress_controller" {
  count = var.deploy_ingress_controller ? 1 : 0 
  depends_on = [time_sleep.wait_1min_demo2]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig create -f https://raw.githubusercontent.com/oracle-devrel/oci-oke-virtual-nodes/main/ingress-nginx/deploy.yaml" 
  }
}

# wait for ingress controller to be deployed"
resource "time_sleep" "wait_1min_demo3" {
  count = var.deploy_ingress_controller ? 1 : 0 
  depends_on = [
  null_resource.create_ingress_controller
  ]
  create_duration = "20s"
}

# Annotate Ingress controller with security group
resource "null_resource" "annotate_ingress_controller" {
  count = var.deploy_ingress_controller ? 1 : 0 
  depends_on = [time_sleep.wait_1min_demo3]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig  -n ingress-nginx annotate svc ingress-nginx-controller oci.oraclecloud.com/oci-network-security-groups=${oci_core_network_security_group.ingress_controller.id}"
  }
}


 

