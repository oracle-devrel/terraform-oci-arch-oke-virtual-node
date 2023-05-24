


resource "oci_containerengine_cluster" "generated_oci_containerengine_cluster" {
	cluster_pod_network_options {
		cni_type = "OCI_VCN_IP_NATIVE"
	}
	compartment_id = var.compartment_id
	endpoint_config {
		is_public_ip_enabled = "true"
		subnet_id = "${oci_core_subnet.kubernetes_api_endpoint_subnet.id}"
		nsg_ids = [oci_core_network_security_group.KubeAPI_server_security_group.id]
	}
	freeform_tags = {
		"OKEclusterName" = "oke-cluster"
	}
	kubernetes_version = var.kubernetes_version
	name = "oke-cluster-virtual-nodes"
	options {
		admission_controller_options {
			is_pod_security_policy_enabled = "false"
		}
		persistent_volume_config {
			freeform_tags = {
				"OKEclusterName" = "oke-cluster"
			}
		}
		service_lb_config {
			freeform_tags = {
				"OKEclusterName" = "oke-cluster"
			}
		}
		service_lb_subnet_ids = ["${oci_core_subnet.service_lb_subnet.id}"]
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
	
	 # cluster type "ENHANCED_CLUSTER" or "BASIC_CLUSTER"
	type = "ENHANCED_CLUSTER"
}


resource "oci_containerengine_virtual_node_pool" "multi_ad" {
	count = length(local.ad_names) != 1 ? 1 : 0 
	cluster_id = "${oci_containerengine_cluster.generated_oci_containerengine_cluster.id}"
	compartment_id = var.compartment_id
	freeform_tags = {
		"OKEnodePoolName" = "pool1"
	}
	
	dynamic "placement_configurations" {
        #Required
        iterator = ad
		for_each = local.ad_number_to_name
		content {
        availability_domain = ad.value
        subnet_id = "${oci_core_subnet.node_subnet.id}"
		fault_domain = [data.oci_identity_fault_domains.fd.fault_domains[0].name]
        }	  
    }

	 nsg_ids = [oci_core_network_security_group.virtual_node_network_security_group.id]
	 
	 pod_configuration {
        #Required
        shape = var.pod_shape
        subnet_id = "${oci_core_subnet.pod_subnet.id}"
		nsg_ids = [oci_core_network_security_group.pod_network_security_group.id]

    }	

	# number of Virtual Nodes
	size = var.virtual_node_count
	display_name = "Oke_virtual_node"	
}



resource "oci_containerengine_virtual_node_pool" "single_ad" {
	count = length(local.ad_names) == 1 ? 1 : 0 
	cluster_id = "${oci_containerengine_cluster.generated_oci_containerengine_cluster.id}"
	compartment_id = var.compartment_id
	freeform_tags = {
		"OKEnodePoolName" = "pool1"
	}
	
	placement_configurations {		
        availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
        subnet_id = "${oci_core_subnet.node_subnet.id}"
		fault_domain = local.fd_names
         
    }

	 nsg_ids = [oci_core_network_security_group.virtual_node_network_security_group.id]
	 
	 pod_configuration {
        shape = var.pod_shape
        subnet_id = "${oci_core_subnet.pod_subnet.id}"
		nsg_ids = [oci_core_network_security_group.pod_network_security_group.id]

    }	

	# number of Virtual Nodes
	size = var.virtual_node_count
	display_name = "Oke_virtual_node"	
}



resource "local_file" "kubeconfig" { 
   depends_on = [
	oci_containerengine_cluster.generated_oci_containerengine_cluster
  ] 
  content  = data.oci_containerengine_cluster_kube_config.virtual_cluster_kube_config.content
  filename = "/tmp/kubeconfig"
}