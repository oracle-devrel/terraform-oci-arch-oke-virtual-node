# Create the Serverless OKE policy in root compartment,

resource "oci_identity_policy" "oke_virtual_node_policy" {
  count = var.create_IAM_policy  ? 1 : 0  
  provider = oci.home
  compartment_id = var.root_compartment_id
  name           = "oke_virtual_node_policy"
  description = "policy to allow Virtual Nodes to use COntianer Instances"

  statements =  [format("define tenancy ske as ocid1.tenancy.oc1..aaaaaaaacrvwsphodcje6wfbc3xsixhzcan5zihki6bvc7xkwqds4tqhzbaq"), 
                 format("define compartment ske_compartment as ocid1.compartment.oc1..aaaaaaaa2bou6r766wmrh5zt3vhu2rwdya7ahn4dfdtwzowb662cmtdc5fea"),
                 format("endorse any-user to associate compute-container-instances in compartment ske_compartment of tenancy ske with subnets in tenancy where ALL {request.principal.type='virtualnode',request.operation='CreateContainerInstance',request.principal.subnet=2.subnet.id}"),
                 format("endorse any-user to associate compute-container-instances in compartment ske_compartment of tenancy ske with vnics in tenancy where ALL {request.principal.type='virtualnode',request.operation='CreateContainerInstance',request.principal.subnet=2.subnet.id}"),
                 format("endorse any-user to associate compute-container-instances in compartment ske_compartment of tenancy ske with network-security-group in tenancy where ALL {request.principal.type='virtualnode',request.operation='CreateContainerInstance'}")] 

    #Optional
    defined_tags = {}
    freeform_tags = {}
    
}