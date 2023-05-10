resource "oci_core_security_list" "service_lb_sec_list" {
	compartment_id = var.compartment_id
	display_name = "oke-svclbseclist-cluster"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
    
	egress_security_rules {
		description = "Access to all"
		destination = oci_core_network_security_group.pod_network_security_group.id
		destination_type = "NETWORK_SECURITY_GROUP"
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

# Security rules Load Balancer to Pod communication
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


# Security rules Pod to Pod communication
resource "oci_core_network_security_group_security_rule" "api_network_pod_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow all from Pod Network"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false
}




# Security rules API to Pod network

resource "oci_core_network_security_group_security_rule" "lb_network_pod_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "allow all from Kubernetes API"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = oci_core_network_security_group.KubeAPI_server_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}

# Security rules Pod network Egress

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

# Security rule for Virtual Node Network Egress
resource "oci_core_network_security_group_security_rule" "virtual_node__network_egress" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "allow all outbound traffic"
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  }


# Security rules Pods to Virtual Node network TCP 10250

resource "oci_core_network_security_group_security_rule" "pod_to_virtual_network1" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "allow TCP 10250 from Pod Network"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false


tcp_options {

        destination_port_range {
            max = "10250"
            min = "10250"
        }

}

# Security rules Kubernetes API subnet to Virtual Node network TCP 10250

resource "oci_core_network_security_group_security_rule" "api_network_virtual_network1" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "allow TCP 10250 from Pod Network"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.KubeAPI_server_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

tcp_options {

        destination_port_range {
            max = "10250"
            min = "10250"
        }

}

resource "oci_core_network_security_group_security_rule" "api_network_virtual_network_icmp" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "allow icmp from kube API Network"
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = oci_core_network_security_group.KubeAPI_server_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false


}



# Security Group Kubernetes API Server ###################################################

resource "oci_core_network_security_group" "KubeAPI_server_security_group" {
    #Required
    compartment_id = var.compartment_id
	display_name = "kubeAPI_Server_security_group"
    vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

# Security rules kubeAPI server ingress TCP 6443

resource "oci_core_network_security_group_security_rule" "kubeAPI_server_ingress_TCP_6443" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "allow KubeAPI ingress TCP 6443"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false

   tcp_options {

        destination_port_range {
            max = "6443"
            min = "6443"
        }

}

# Security rules kubeAPI server ingress TCP 6443 from pod security group

resource "oci_core_network_security_group_security_rule" "kubeAPI_server_ingress_TCP_6443_pod" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "allow KubeAPI ingress TCP 6443"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

   tcp_options {

        destination_port_range {
            max = "6443"
            min = "6443"
        }

}


# Security rules kubeAPI server ingress TCP 6443 from node security group

resource "oci_core_network_security_group_security_rule" "kubeAPI_server_ingress_TCP_6443_node" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "allow KubeAPI ingress TCP 6443"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.virtual_node_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

   tcp_options {

        destination_port_range {
            max = "6443"
            min = "6443"
        }

}
}


# Security rules kubeAPI server ingress from pod security group TCP 12250
resource "oci_core_network_security_group_security_rule" "kubeAPI_server_pod_12250" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "allow pod security group TCP 12250"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

   tcp_options {
        destination_port_range {
            max = "12250"
            min = "12250"
        }

}
}

# Security rules kubeAPI server ingress from node security group TCP 
resource "oci_core_network_security_group_security_rule" "kubeAPI_server_node_12250" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "allow node security group TCP 12250"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.virtual_node_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

   tcp_options {
        destination_port_range {
            max = "12250"
            min = "12250"
        }

}

}

# Security rules kubeAPI server ingress from node security group ICMP
resource "oci_core_network_security_group_security_rule" "kubeAPI_server_node_12250_icmp_node" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "allow node security group ICMP"
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}

# Security rules kubeAPI server ingress from node security group ICMP
resource "oci_core_network_security_group_security_rule" "kubeAPI_server_node_12250_icmp_pod" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "allow pod security group ICMP"
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = oci_core_network_security_group.virtual_node_network.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}
