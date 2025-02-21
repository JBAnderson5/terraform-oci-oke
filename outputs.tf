# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# for reuse

output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = module.oke.cluster_id
}

output "nodepool_ids" {
  description = "Map of Nodepool names and IDs"
  value       = module.oke.nodepool_ids
}


output "ig_route_id" {
  description = "id of route table to vcn internet gateway"
  value       = module.vcn.ig_route_id
}

output "nat_route_id" {
  description = "id of route table to nat gateway attached to vcn"
  value       = module.vcn.nat_route_id
}

output "subnet_ids" {
  description = "map of subnet ids (worker, int_lb, pub_lb) used by OKE."
  value       = module.network.subnet_ids
}

output "vcn_id" {
  description = "id of vcn where oke is created. use this vcn id to add additional resources"
  value       = module.vcn.vcn_id
}

# convenient output

output "bastion_public_ip" {
  description = "public ip address of bastion host"
  value       = module.bastion.bastion_public_ip
}

output "operator_private_ip" {
  description = "private ip address of operator host"
  value       = module.operator.operator_private_ip
}

#TODO: move this logic from base module in datasources.tf
/* skipping for now
output "ssh_to_operator" {
  description = "convenient command to ssh to the operator host"
  value       = module.operator.ssh_to_operator
}

#TODO: move this logic from base module in datasources.tf
output "ssh_to_bastion" {
  description = "convenient command to ssh to the bastion host"
  value       = module.bastion.ssh_to_bastion
}
*/

output "kubeconfig" {
  description = "convenient command to set KUBECONFIG environment variable before running kubectl locally"
  value       = "export KUBECONFIG=generated/kubeconfig"
}
