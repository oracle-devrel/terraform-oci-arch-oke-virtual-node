
# Compartment to deploy OKE Virual Node Cluster
variable "compartment_id" {
    type = string
    default = ""
}

variable "tenancy_ocid" {
type = string
default = ""
}


variable "kubernetes_version" { 
    type = string
    default ="v1.25.4" 
    }

variable "region" {
    type = string
    default = ""
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
  default     = true
}

# set to true to add metrics server to Virtual Nodes
variable "deploy_metrics_server" {
  description = "Set to true to create the resource, false to skip it."
  type        = bool
  default     = false
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


