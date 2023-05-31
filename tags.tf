## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "random_id" "tag" {
  byte_length = 2
}

resource "oci_identity_tag_namespace" "blog_virtual_node" {
  provider = oci.home
  compartment_id = var.compartment_id
  description    = "blog_virtual_node_TagNamespace"
  name           = "blog_virtual_node\\deploy-microservices-${random_id.tag.hex}"

  provisioner "local-exec" {
    command = "sleep 10"
  }

}

resource "oci_identity_tag" "blog_virtual_node" {
  provider         = oci.home
  description      = "blog OKE Virtual Nodes"
  name             = "release"
  tag_namespace_id = oci_identity_tag_namespace.blog_virtual_node.id

  validator {
    validator_type = "ENUM"
    values         = ["release", "1.0.1"]
  }

  provisioner "local-exec" {
    command = "sleep 120"
  }
}