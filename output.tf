




output "command_for_kube_config" {
  value = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.generated_oci_containerengine_cluster.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT"
}

output "ingress_controller_ip_address" {
  value = "kubectl -n ingress-nginx get svc ingress-nginx-controller"
}




