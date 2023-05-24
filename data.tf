data oci_identity_regions regions {}

data oci_identity_tenancy tenancy {
    tenancy_id = var.tenancy_ocid
}



# get service ocid for region
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


# get the availability domains for the region
data "oci_identity_availability_domains" "ad" {
  compartment_id =  var.compartment_id
}


# get the fault domains of the availability domain
data "oci_identity_fault_domains" "fd" {
  compartment_id    = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
}



data "oci_containerengine_cluster_kube_config" "virtual_cluster_kube_config" {
    #Required
    cluster_id = oci_containerengine_cluster.generated_oci_containerengine_cluster.id

}
