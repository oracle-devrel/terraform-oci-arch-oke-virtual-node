resource "oci_core_security_list" "service_lb_sec_list" {
	compartment_id = var.compartment_id
	display_name = "oke-svclbseclist-quick-demo-cluster"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
    
	egress_security_rules {
		description = "Access to all"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}

	ingress_security_rules {
		description = "Access to 80"
		source_type = "CIDR_BLOCK"
		source = "0.0.0.0/0"
		protocol = "6"
		stateless = "false"
		tcp_options {
		  min = 80
          max = 80
		}
	}

	ingress_security_rules {
		description = "Access to 443"
		protocol = "6"
		source_type = "CIDR_BLOCK"
		source = "0.0.0.0/0"
		stateless = "false"
		tcp_options {
		  min = 443
          max = 443
		}
	}

}



resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
	compartment_id = var.compartment_id
	display_name = "oke-k8sApiEndpoint-quick-demo-cluster"
	egress_security_rules {
		description = "Allow Kubernetes Control Plane to communicate with OKE"
		destination = var.oci_service_gateway[var.region]
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "All traffic to worker nodes"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	ingress_security_rules {
		description = "External access to Kubernetes API endpoint"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to Kubernetes API endpoint communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to control plane communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}



# Security Group for Pods Network ###################################################

resource "oci_core_network_security_group" "pod_network_security_group" {
    #Required
    compartment_id = var.compartment_id
	display_name = "pod_network_security_group"
    vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}


resource "oci_core_network_security_group_security_rule" "svc_network_pod_network_ingress" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow Highport Access"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    =  oci_core_subnet.service_lb_subnet.cidr_block 
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "30000"
      max = "30256"
    }
  }
}

# Security rules Load Balancer to Pod communication ###################################################
resource "oci_core_network_security_group_security_rule" "svc_lb_pod_network_ingress1" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow TCP 10256"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_subnet.service_lb_subnet.cidr_block
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "10256"
      max = "10256"
    }
  }
}


# Security rules Pod to Pod communication ###################################################
resource "oci_core_network_security_group_security_rule" "api_network_pod_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow all from Pod Network"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false
}




# Security rules API to Pod network ###################################################

resource "oci_core_network_security_group_security_rule" "lb_network_pod_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow all from Kubernetes API"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = oci_core_subnet.kubernetes_api_endpoint_subnet.cidr_block
  source_type               = "CIDR_BLOCK"
  stateless                 = false

}

# Security rules Pod network Egress ###################################################

  resource "oci_core_network_security_group_security_rule" "pod_network_egress" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow all outbound traffic"
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  }


# Security Group for Virtual Node Network ###################################################

resource "oci_core_network_security_group" "virtual_node_network_security_group" {
    #Required
    compartment_id = var.compartment_id
	display_name = "Virtual_node_security_group"
    vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

# Security rule for Virtual Node Network Egress ###################################################
resource "oci_core_network_security_group_security_rule" "virtual_node__network_egress" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "allow all outbound traffic"
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  }


# Security rules Pods to Virtual Node network ###################################################

resource "oci_core_network_security_group_security_rule" "pod_to_virtual_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow TCP 10250 from Pod Network"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}

# Security rules Kubernetes API subnet to Virtual Node network ###################################################

resource "oci_core_network_security_group_security_rule" "api_network_virtual_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow TCP 10250 from Pod Network"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_subnet.kubernetes_api_endpoint_subnet.cidr_block
  source_type               = "CIDR_BLOCK"
  stateless                 = false

}

