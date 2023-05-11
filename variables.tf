
# Compartment to deploy OKE Virual Node Cluster
variable "compartment_id" {
    type = string
    default = "ocid1.compartment.oc1..aaaaaaaaucuuv3bavrptzr563nq5bpo55t7lk5p4zvr25n77i54jl2eykhbq"
}

variable "tenancy_ocid" {
type = string
default = "ocid1.tenancy.oc1..aaaaaaaajznex5attydtrmrgudwayqu7kn4krasw2ct4h4pwz7nwbfxoyd4q"
}


variable "kubernetes_version" { 
    type = string
    default ="v1.25.4" 
    }

variable "region" {
    type = string
    default = "us-sanjose-1"
}

# Shape of Virtual Nodes
variable "pod_shape"{
    type = string
    default = "Pod.Standard.E4.Flex"
}


# number of Virtual Nodes
variable "virtual_node_count" {
    type = number
    default = 3
}

# set to true to create the Serverless OKE policy in root compartment, required for Virtual Node Operation
# https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengvirtualnodes-Required_IAM_Policies.htm
variable "create_IAM_policy" {
  description = "Set to true to create the resource, false to skip it."
  type        = bool
  default     = false
}

# set to true to add metrics server to Virtual Nodes
variable "deploy_metrics_server" {
  description = "Set to true to create the resource, false to skip it."
  type        = bool
  default     = true
}


# set to true to add Kubernetes_dashboard to Virtual Nodes
variable "deploy_kubernetes_dashboard" {
  description = "Set to true to create the resource, false to skip it."
  type        = bool
  default     = false
}


# set to true to deploy ingress controller to Virtual Nodes
variable "deploy_ingress_controller" {
  description = "Set to true to create the resource, false to skip it."
  type        = bool
  default     = true
}


# map for services oci_service_gateway for different regions
variable "oci_service_gateway" {
  type = map(string)
  default = {
    ap-seoul-1 = "all-seo-services-in-oracle-services-network"
    ap-tokyo-1 = "all-hnd-services-in-oracle-services-network"
    ca-toronto-1 = "all-yyz-services-in-oracle-services-network"
    eu-frankfurt-1 = "all-fra-services-in-oracle-services-network"
    uk-london-1 = "all-lhr-services-in-oracle-services-network"
    us-ashburn-1 = "all-iad-services-in-oracle-services-network"
    us-phoenix-1 = "all-phx-services-in-oracle-services-network"
    us-sanjose-1 = "all-sjc-services-in-oracle-services-network"
    us-us-chicago-1 = "all-ord-services-in-oracle-services-network"
  }
}

