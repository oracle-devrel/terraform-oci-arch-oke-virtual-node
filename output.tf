data "oci_containerengine_cluster_kube_config" "virtual_cluster_kube_config" {
    #Required
    cluster_id = oci_containerengine_cluster.generated_oci_containerengine_cluster.id

}


/*
output "kubeconfig" {
  value = data.oci_containerengine_cluster_kube_config.virtual_cluster_kube_config
  description = "kubeconfig for virtual node cluster "
}
*/



output "kube_config" {
  value = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.generated_oci_containerengine_cluster.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT"
}

output "ingress_controller_ip_address" {
  value = "kubectl -n default get svc ingress-nginx"
}
