


# wait for /tmp/kubeconfig to be wirtten"
resource "time_sleep" "wait_1min_demo1" {
  count = var.deploy_kubernetes_dashboard ? 1 : 0 
  depends_on = [
  local_file.kubeconfig
  ]
  create_duration = "30s"
}


resource "null_resource" "create_kubernetes_dashboard_admin" {
  count = var.deploy_kubernetes_dashboard ? 1 : 0 
  depends_on = [time_sleep.wait_1min_demo1]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig create -f https://raw.githubusercontent.com/oracle-devrel/oci-oke-virtual-nodes/main/kubernetes-dashboard/admin-user.yaml"

}
}


resource "null_resource" "create_kubernetes_dashboard" {
  count = var.deploy_kubernetes_dashboard ? 1 : 0 
  depends_on = [time_sleep.wait_1min_demo1]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig create -f https://raw.githubusercontent.com/oracle-devrel/oci-oke-virtual-nodes/main/kubernetes-dashboard/recommended.yaml" 

}
}






