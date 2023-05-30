# oke-virtual-node-terraform


## Introduction


This Terraform stack facilitates the deployment of an Oracle Container Engine for Kubernetes (OKE) Virtual Nodes cluster in your tenancy. This stack will automatically provision the necessary network infrastructure components such as Virtual Cloud Network (VCN), subnets, Internet Gateway, NAT Gateway, and security rules. Additionally, you can deploy the relevant policies in the root compartment of your tenancy to enable operations of OKE Virtual Nodes and also includes the option to deploy a metrics server, ingress controller and the Kubernetes dashboard to the cluster.


## Pre-requisites

- [OCI CLI installed with the required credentials to deploy OKE in your tenancy](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- [kubectl installed](https://kubernetes.io/docs/tasks/tools/)
- [Terraform Installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)



[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://github.com/oracle-devrel/terraform-oci-arch-oke-virtual-node/archive/refs/tags/OKE-VN-V8.zip)



## Installation of Terraform stack

**1. Clone or download the contents of this repo** 
     
     git clone https://github.com/chiphwang1/terraform-oci-arch-oke-virtual-node.git

**2. Change to the directory that holds the Terraform stack** 

      cd ./oci_oke_virtual_nodes

**3. Populate the varaibles.tf file**


**4. Install the Terraform stack**

     terraform init
     terraform plan
     teraffrom apply
  

**5. Add Kubeconfig of Virtual Node cluster**

     
 run oci command in output of terraform apply

###  Sample Output 
![title](kubeconfig1.png)


**7. To remove Terraform stack**

     terraform destroy
     
 
##  variables.tf specification


| Variables                          | Description                                                         | Type   | Mandatory |
| ---------------------------------- | ------------------------------------------------------------------- | ------ | --------- |
| `compartment_id` | Compartment to deploy OKE Virtual Nodes cluster | string | yes  |
| `tenancy_ocid` | Tenancy ocid| string | yes  |
| `region` | region to deploy the OKE Virtual Nodes Cluster  | string | yes     |
| `pod_shape` | The shape of Virtual Nodes | string | yes       |
| `virtual_node_count` | The number of Virtual Nodes in the node pool  | number | yes       |
| `create_IAM_policy` | To create the policy for for Virtual Node operations set to "true". The IAM policy is created in the root compartment in customer's home region. Customer must have access to create a policy in this compartment.| bool | yes       |
| `deploy_metrics_server` | install metrics server. Set to "true" to create the policy | bool | yes  |
| `deploy_kubernetes_dashboard` | install Kubernetes dashboard. Set to "true" to create the policy | bool | yes  |
| `deploy_ingress_controller` | install ingnx ingress controller. Set to "true" to create the policy | bool | yes  |


## Useful commands 


**1. Check Virtual Nodes status**
     
     kubectl get nodes -o wide

**1. Get IP address of Nginx ingress controller**

     kubectl -n ingress-nginx get svc ingress-nginx-controller

## Additional Resources

- [OKE Virtual Nodes deliver a serverless Kubernetes experience](https://blogs.oracle.com/cloud-infrastructure/post/oke-virtual-nodes-deliver-serverless-experience)
- [Oracle Container Engine for Kubernetes(OKE)](https://www.oracle.com/cloud/cloud-native/container-engine-kubernetes/#:~:text=Oracle%20Cloud%20Infrastructure%20Container%20Engine,complexities%20of%20the%20Kubernetes%20infrastructure.)
- [OKE Virtual Nodes documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm)
- [Get started with Oracle Cloud Infrastructure today with our Oracle Cloud Free Trial](https://www.oracle.com/cloud/free/)
