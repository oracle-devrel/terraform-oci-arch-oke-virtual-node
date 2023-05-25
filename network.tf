# VCN For OKE cluster
resource "oci_core_vcn" "generated_oci_core_vcn" {
	cidr_block = "10.0.0.0/16"
	compartment_id = var.compartment_id
	display_name = "oke-vcn-cluster"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
	compartment_id = var.compartment_id
	display_name = "oke-igw-cluster"
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
	display_name = "oke-private-routetable-demo-cluster"
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
	display_name = "oke-svclb-subnet"
	#dns_label = "oke-svclb-subnet"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "node_subnet" {
	cidr_block = "10.0.10.0/24"
	compartment_id = var.compartment_id
	display_name = "oke-node-subnet"
	#dns_label = ""
	prohibit_public_ip_on_vnic = "true"
	route_table_id = "${oci_core_route_table.generated_oci_core_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "pod_subnet" {
	cidr_block = "10.0.11.0/24"
	compartment_id = var.compartment_id
	display_name = "oke-pod-subnet"
	#dns_label = ""
	prohibit_public_ip_on_vnic = "true"
	route_table_id = "${oci_core_route_table.generated_oci_core_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}


resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
	cidr_block = "10.0.0.0/28"
	compartment_id = var.compartment_id
	display_name = "oke-k8sApi-server-subnet"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
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