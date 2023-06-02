# LB subnet Security list

resource "oci_core_security_list" "service_lb_sec_list" {
	compartment_id = var.compartment_id
	display_name = "svc_LB_sec_list"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
    egress_security_rules {
		description = "Egress pod subnet High Ports"
		destination = "10.0.11.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "32767"
            min = "30000"
            
	    }
    }

     egress_security_rules {
		description = "Egress pod subnet KubeProxy"
		destination = "10.0.11.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "10256"
            min = "10256"
            
	    }
    }


    ingress_security_rules {
		description = "ingress TCP 80"
		source = "0.0.0.0/0"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "80"
            min = "80"
            
	    }
    }

    ingress_security_rules {
		description = "ingress TCP 8080"
		source = "0.0.0.0/0"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "8080"
            min = "8080"
            
	    }
    }

ingress_security_rules {
		description = "ingress TCP 443"
		source = "0.0.0.0/0"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "443"
            min = "443"
            
	    }
    }
}



# Pod subnet Security list

resource "oci_core_security_list" "pod_subnet_sec_list" {
	compartment_id = var.compartment_id
	display_name = "pod_subnet_sec_list"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
    ingress_security_rules {
		description = "Ingress LB-->POD TCP Highport Access"
		source = "10.0.20.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "32767"
            min = "30000"
	    }
    }
    
    ingress_security_rules {
		description = "Ingress LB-->POD KubeProxy"
		source = "10.0.20.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "10256"
            min = "10256"
	    }
    }

    ingress_security_rules {
		description = "POD-->POD"
		source = "10.0.11.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
    }

    
    ingress_security_rules {
		description = "Ingress KubeAPI -->POD All"
		source = "10.0.3.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
    }



    egress_security_rules {
		description = "Allow All"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"

    }
}

# Node subnet Security list

resource "oci_core_security_list" "node_subnet_sec_list" {
	compartment_id = var.compartment_id
	display_name = "virtual_node_subnet_sec_list"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
     egress_security_rules {
		description = "Egress Kube API server TCP 6443"
		destination = "10.0.3.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = 6
		stateless = "false"
        tcp_options {
            max = "6443"
            min = "6443"
	    }

    }

    egress_security_rules {
		description = "Egress Kube API server TCP 12250"
		destination = "10.0.3.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = 6
		stateless = "false"
        tcp_options {
            max = "12250"
            min = "12250"
	    }

    }


    egress_security_rules {
		description = "Egress Service Gateway"
		destination = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block") 
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
    }

     egress_security_rules {
		description = "Egress ICMP to Kube API server"
		destination = "10.0.3.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "1"
		stateless = "false"
    }

    
    ingress_security_rules {
		description = "Ingress Pod-->Nodes Keep Alive"
		source = "10.0.11.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "10250"
            min = "10250"
	    }
	}
	
    ingress_security_rules {
		description = "Ingress Kube API -->Nodes Keep Alive"
		source = "10.0.3.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "10250"
            min = "10250"
	    }
    }


    ingress_security_rules {
		description = "Ingress Kube API -->Nodes Keep Alive"
		source = "10.0.3.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "1"
		stateless = "false"
        
    }
}


# API Server subnet Security list

resource "oci_core_security_list" "API_subnet_sec_list" {
	compartment_id = var.compartment_id
	display_name = "K8sApi_server_subnet_sec_list"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
    
     ingress_security_rules {
		description = "Ingress Kube API TCP 6443"
		source = "0.0.0.0/0"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "6443"
            min = "6443"
	    }
    }

    ingress_security_rules {
		description = "Ingress Pod --> Kube API Keep Alive"
		source = "10.0.11.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "12250"
            min = "12250"
	    }
    }

    ingress_security_rules {
		description = "Ingress Node subnet --> Kube API Keep Alive"
		source = "10.0.10.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "12250"
            min = "12250"
	    }
    }

    ingress_security_rules {
		description = "Ingress Node subnet --> Kube API ICMP"
		source = "10.0.10.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "1"
		stateless = "false"
        
    }

    ingress_security_rules {
		description = "Ingress pod subnet --> Kube API ICMP"
		source = "10.0.11.0/24"
		source_type = "CIDR_BLOCK"
		protocol = "1"
		stateless = "false"
        
    }

          
     egress_security_rules {
		description = "Egress Kube API Pod subnet all"
		destination = "10.0.11.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
        

    }

	egress_security_rules {
		description = "Egress Kube API all"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
        

    }

/*
	egress_security_rules {
		description = "Egress Kube API node subnet all"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
        

    }
*/
	egress_security_rules {
		description = "Egress Kube API Node subnet ICMP"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "1"
		stateless = "false"
        

    }

    egress_security_rules {
		description = "Egress Kube API Node subnet Kubelet"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
        tcp_options {
            max = "10250"
            min = "10250"
	    }

    }

}
