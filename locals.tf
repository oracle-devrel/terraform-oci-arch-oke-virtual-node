locals {
    region_map = { for r in data.oci_identity_regions.regions.regions : r.key => r.name }
}

# put availability domains in a list
locals {
  # Get the list of availability domain names for the region
  ad_names = [for ad in data.oci_identity_availability_domains.ad.availability_domains : ad.name]

}
 
locals {
  ad_number_to_name = {
    for ad in data.oci_identity_availability_domains.ad.availability_domains :
    parseint(substr(ad.name, -1, -1), 10) => ad.name
  }
  ad_numbers = keys(local.ad_number_to_name)
}

# put FAULT domains in a list
locals {
  fd_names = [for fd in  data.oci_identity_fault_domains.fd.fault_domains : fd.name]
}