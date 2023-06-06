# VCN For OKE cluster
resource "oci_core_vcn" "generated_oci_core_vcn" {
	cidr_block = "10.0.0.0/16"
	compartment_id = var.compartment_id
	display_name = "oke-virtual-nodes-vcn"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
	compartment_id = var.compartment_id
	display_name = "virtual-nodes-vcn-igw"
	enabled = "true"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_nat_gateway" "generated_oci_core_nat_gateway" {
	compartment_id = var.compartment_id
	display_name = "oke-ngw-cluster"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_service_gateway" "generated_oci_core_service_gateway" {
	compartment_id = var.compartment_id
	display_name = "oke-sgw-cluster"
	services {
	service_id = lookup(data.oci_core_services.all_oci_services.services[0], "id")
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_route_table" "generated_oci_core_route_table" {
	compartment_id = var.compartment_id
	display_name = "oke-private-routetable"
	route_rules {
		description = "traffic to the internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = "${oci_core_nat_gateway.generated_oci_core_nat_gateway.id}"
	}
	route_rules {
		description = "traffic to OCI services"
		destination = lower(replace(data.oci_core_services.all_oci_services.services[0].name," ", "-"))
		destination_type = "SERVICE_CIDR_BLOCK"
		network_entity_id = "${oci_core_service_gateway.generated_oci_core_service_gateway.id}"
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "service_lb_subnet" {
	cidr_block = "10.0.20.0/24"
	compartment_id = var.compartment_id
	display_name = "svc-lb-subnet"
	#dns_label = "oke-svclb-subnet"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
	security_list_ids = ["${oci_core_security_list.service_lb_sec_list.id}"]
}

resource "oci_core_subnet" "node_subnet" {
	cidr_block = "10.0.10.0/24"
	compartment_id = var.compartment_id
	display_name = "virtual-node-subnet"
	#dns_label = ""
	prohibit_public_ip_on_vnic = "true"
	route_table_id = "${oci_core_route_table.generated_oci_core_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
	security_list_ids = ["${oci_core_security_list.node_subnet_sec_list.id}"]
}

resource "oci_core_subnet" "pod_subnet" {
	cidr_block = "10.0.11.0/24"
	compartment_id = var.compartment_id
	display_name = "pod-subnet"
	#dns_label = ""
	prohibit_public_ip_on_vnic = "true"
	route_table_id = "${oci_core_route_table.generated_oci_core_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
	security_list_ids = ["${oci_core_security_list.pod_subnet_sec_list.id}"]
}


resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
	cidr_block = "10.0.3.0/24"
	compartment_id = var.compartment_id
	display_name = "k8sApi-server-subnet"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
	security_list_ids = ["${oci_core_security_list.API_subnet_sec_list.id}"]
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
	display_name = "oke-public-routetable"
	route_rules {
		description = "traffic to/from internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = "${oci_core_internet_gateway.generated_oci_core_internet_gateway.id}"
	}
	manage_default_resource_id = "${oci_core_vcn.generated_oci_core_vcn.default_route_table_id}"
}