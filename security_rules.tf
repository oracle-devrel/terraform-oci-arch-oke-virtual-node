


# Security Group for Pods Network ###################################################

resource "oci_core_network_security_group" "pod_network_security_group" {
    #Required
    compartment_id = var.compartment_id
	display_name = "pod_network_security_group"
    vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}


resource "oci_core_network_security_group_security_rule" "svc_network_pod_network_ingress" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "Ingress LB-->POD TCP Highport Access"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    =  oci_core_network_security_group.ingress_controller.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "30000"
      max = "32767"
    }
  }
}

# Security rules Load Balancer to Pod communication
resource "oci_core_network_security_group_security_rule" "svc_lb_pod_network_ingress1" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "Ingress LB--> POD Kube-proxy"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.ingress_controller.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "10256"
      max = "10256"
    }
  }
}


# Security rules Pod to Pod communication
resource "oci_core_network_security_group_security_rule" "pod_network_pod_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "Ingress POD--> POD allow all"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}




# Security rules API to Pod network

resource "oci_core_network_security_group_security_rule" "api_network_pod_network" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "Ingress KubeAPI--> POD allow all"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = oci_core_network_security_group.KubeAPI_server_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}


# Security rules Pod network Egress

  resource "oci_core_network_security_group_security_rule" "pod_network_egress" {
  network_security_group_id = oci_core_network_security_group.pod_network_security_group.id
  description               = "Egress Pod-->All IPs  allow all"
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

/*
resource "oci_core_network_security_group_security_rule" "virtual_node__network_egress" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "allow all outbound traffic"
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  }
*/


resource "oci_core_network_security_group_security_rule" "virtual_node__network_egress_api_server1" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "Egress Node-->KubeAPI server TCP 6443"
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.KubeAPI_server_security_group.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

	tcp_options {

        destination_port_range {
            max = "6443"
            min = "6443"
      }
	  }
  }


resource "oci_core_network_security_group_security_rule" "virtual_node__network_egress_api_server2" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "Egress Node-->KubeAPI server Keep Alive TCP 12250"
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.KubeAPI_server_security_group.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

	tcp_options {

        destination_port_range {
            max = "12250"
            min = "12250"
      }
	  }
  }


resource "oci_core_network_security_group_security_rule" "OCI_Services" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "Egress Node-->OCI services all traffic"
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "SERVICE_CIDR_BLOCK"
  destination 				=  lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block") 
  stateless                 = false
  }



resource "oci_core_network_security_group_security_rule" "virtual_node__network_egress_api_server3" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "Egress Node-->KubeAPI server ICMP"
  direction                 = "EGRESS"
  protocol                  = "1"
  destination               = oci_core_network_security_group.KubeAPI_server_security_group.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  }


# Security rules Pods to Virtual Node network TCP 10250

resource "oci_core_network_security_group_security_rule" "pod_to_virtual_network1" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "Ingress Pod-->Nodes Keep Alive TCP 10250"
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
}
# Security rules Kubernetes API subnet to Virtual Node network TCP 10250

resource "oci_core_network_security_group_security_rule" "api_network_virtual_network1" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "Ingress KubeAPI Server -->Nodes Keep Alive TCP 10250"
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
}

resource "oci_core_network_security_group_security_rule" "api_network_virtual_network_icmp" {
  network_security_group_id = oci_core_network_security_group.virtual_node_network_security_group.id
  description               = "allow KubeAPI server to virtual network icmp"
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
  description               = "Ingress allow all IPs to kubeAPI server on TCP 6443"
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
}	

# Security rules kubeAPI server ingress TCP 6443 from pod security group

resource "oci_core_network_security_group_security_rule" "kubeAPI_server_ingress_TCP_6443_pod" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "Ingress pod network to KubeAPI server on TCP 6443"
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
}

# Security rules kubeAPI server ingress TCP 6443 from node security group

resource "oci_core_network_security_group_security_rule" "kubeAPI_server_ingress_TCP_6443_node" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "Ingress  virtual network --> KubeAPI server on TCP 6443"
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
  description               = " Ingress pod--> KubeAPI server Keep Alive TCP 12250"
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
  description               = "Ingress node--> KubeAPI server security Keep Alive TCP 12250"
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
  description               = "Ingress node --> KubeAPI server ICMP"
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = oci_core_network_security_group.virtual_node_network_security_group.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}

# Security rules kubeAPI server ingress from node security group ICMP
resource "oci_core_network_security_group_security_rule" "kubeAPI_server_pod_12250_icmp_pod" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "Ingress pod --> KubeAPI server ICMP"
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = oci_core_network_security_group.pod_network_security_group.id
  source_type          		= "NETWORK_SECURITY_GROUP"
  stateless                 = false

}


# Security rules kubeAPI server TO POD NETWORK
resource "oci_core_network_security_group_security_rule" "kubeAPI_server_POD_ALL" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "Egress KubeAPI server ---> pod all protocols"
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.pod_network_security_group.id
  destination_type           = "NETWORK_SECURITY_GROUP"
  stateless                 = false

}

# Security rules kubeAPI server TO Node NETWORK
resource "oci_core_network_security_group_security_rule" "kubeAPI_server_Node_10250" {
  network_security_group_id = oci_core_network_security_group.KubeAPI_server_security_group.id
  description               = "Egress allow KubeAPI server--> Node Kubelet TCP 10250"
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.virtual_node_network_security_group.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false


 tcp_options {
        destination_port_range {
            max = "10250"
            min = "10250"
    }
	}
}

# Security Group Kubernetes Ingress Controller  ###################################################

resource "oci_core_network_security_group" "ingress_controller" {
    #Required
    compartment_id = var.compartment_id
	display_name = "Ingress_controller_security_group"
    vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}


# Security rules ingress controller to pod network high ports
resource "oci_core_network_security_group_security_rule" "ingress_to_pod1" {
  network_security_group_id = oci_core_network_security_group.ingress_controller.id
  description               = "Egress KubeAPI Server  Node Kubelet TCP 10250"
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.pod_network_security_group.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "30000"
      max = "32767"
    }
  }
}	

# Security rules ingress controller to pod network TCP 
resource "oci_core_network_security_group_security_rule" "ingress_to_pod2" {
  network_security_group_id = oci_core_network_security_group.ingress_controller.id
  description               = "Egress KubeAPI server to Node Kubeproxy TCP 10256 "
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.pod_network_security_group.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "10256"
      max = "10256"
    }
  }
}	


# Security rules allow TCP 80 ingress controller to pod network TCP 
resource "oci_core_network_security_group_security_rule" "TCP80_ingress" {
  network_security_group_id = oci_core_network_security_group.ingress_controller.id
  description               = "Ingress allow IP to  web TCP 80 to Ingress"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "80"
      max = "80"
    }
  }
}	


# Security rules allow TCP 80 ingress controller to pod network TCP 
resource "oci_core_network_security_group_security_rule" "TCP443_ingress" {
  network_security_group_id = oci_core_network_security_group.ingress_controller.id
  description               =  "Ingress allow IP to  web TCP 443 to Ingress"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "443"
      max = "443"
    }
  }
}	


# Security rules allow TCP 80 ingress controller to pod network TCP 
resource "oci_core_network_security_group_security_rule" "TCP8080_ingress" {
  network_security_group_id = oci_core_network_security_group.ingress_controller.id
  description               = "Ingress allow IP to  web TCP 8080 to Ingress"
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "8080"
      max = "8080"
    }
  }
}	