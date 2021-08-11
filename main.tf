# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

/*
module "base" {
  source  = "./modules/base"
  #version = "2.4.0"

  # general oci parameters
  oci_base_general = local.oci_base_general

  # identity
  oci_base_provider = local.oci_base_provider

  # vcn parameters
  oci_base_vcn = local.oci_base_vcn

  # bastion parameters
  oci_base_bastion = local.oci_base_bastion

  # operator server parameters
  oci_base_operator = local.oci_base_operator

}

*/

module "vcn" {
  source  = "../terraform-oci-vcn"
  #version = "2.3.0"

  # provider parameters
  region = var.region

  # general oci parameters
  compartment_id = var.compartment_id #TODO: should we change this to refer to network compartment?
  label_prefix   = var.label_prefix
  tags           = var.tags["vcn"]

  # vcn parameters
  create_drg               = var.create_drg
  drg_display_name         = var.drg_display_name
  internet_gateway_enabled = true
  lockdown_default_seclist = var.lockdown_default_seclist
  nat_gateway_enabled      = var.worker_mode == "private" || var.operator_enabled == true || (var.lb_subnet_type == "internal" || var.lb_subnet_type == "both") ? true : false
  nat_gateway_public_ip_id = var.nat_gateway_public_ip_id
  service_gateway_enabled  = true
  vcn_cidr                 = var.vcn_cidr
  vcn_dns_label            = var.vcn_dns_label
  vcn_name                 = var.vcn_name

  # routing rules
  internet_gateway_route_rules = var.internet_gateway_route_rules
  nat_gateway_route_rules      = var.nat_gateway_route_rules
}

module "bastion" {
  source  = "oracle-terraform-modules/bastion/oci"
  version = "2.1.0"

  # provider identity parameters
  api_fingerprint      = var.api_fingerprint
  api_private_key_path = var.api_private_key_path
  region               = var.region
  tenancy_id           = var.tenancy_id
  user_id              = var.user_id

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # network parameters

  availability_domain = var.availability_domains["bastion"]
  bastion_access      = var.bastion_access
  ig_route_id         = module.vcn.ig_route_id
  netnum              = var.netnum["bastion"]
  newbits             = var.newbits["bastion"]
  vcn_id              = module.vcn.vcn_id

  # bastion parameters
  bastion_enabled                  = var.bastion_enabled
  bastion_image_id                 = var.bastion_image_id
  bastion_operating_system_version = var.bastion_operating_system_version
  bastion_shape                    = var.bastion_shape
  bastion_state                    = var.bastion_state
  bastion_upgrade                  = var.bastion_package_upgrade
  ssh_public_key                   = var.ssh_public_key
  ssh_public_key_path              = var.ssh_public_key_path
  timezone                         = var.bastion_timezone

  # notification
  notification_enabled  = var.bastion_notification_enabled
  notification_endpoint = var.bastion_notification_endpoint
  notification_protocol = var.bastion_notification_protocol
  notification_topic    = var.bastion_notification_topic

  # tags
  tags = var.tags["bastion"]
}

module "operator" {
  source  = "oracle-terraform-modules/operator/oci"
  version = "2.2.0"

  # provider identity parameters
  api_fingerprint      = var.api_fingerprint
  api_private_key_path = var.api_private_key_path
  region               = var.region
  tenancy_id           = var.tenancy_id
  user_id              = var.user_id

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # network parameters
  availability_domain = var.availability_domains["operator"]
  nat_route_id        = module.vcn.nat_route_id
  netnum              = var.netnum["operator"]
  newbits             = var.newbits["operator"]
  vcn_id              = module.vcn.vcn_id

  # operator parameters
  operator_enabled            = var.operator_enabled
  operator_image_id           = var.operator_image_id
  operator_instance_principal = var.operator_instance_principal
  operator_shape              = var.operator_shape
  operator_state              = var.operator_state
  operating_system_version    = var.operator_version
  operator_upgrade            = var.operator_package_upgrade
  ssh_public_key              = var.ssh_public_key
  ssh_public_key_path         = var.ssh_public_key_path
  timezone                    = var.operator_timezone

  # notification
  notification_enabled  = var.operator_notification_enabled
  notification_endpoint = var.operator_notification_endpoint
  notification_protocol = var.operator_notification_protocol
  notification_topic    = var.operator_notification_topic

  # tags
  tags = var.tags["bastion"]
}

module "policies" {
  source = "./modules/policies"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # provider
  api_fingerprint      = var.api_fingerprint
  api_private_key_path = var.api_private_key_path
  region               = var.region
  tenancy_id           = var.tenancy_id
  user_id              = var.user_id

  ssh_keys = local.oci_base_ssh_keys

  operator = local.oke_operator

  dynamic_group = module.base.group_name

  oke_kms = local.oke_kms

  cluster_id = module.oke.cluster_id
}

# additional networking for oke
module "network" {
  source = "./modules/okenetwork"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # oke networking parameters
  oke_network_vcn = local.oke_network_vcn

  # control plane endpoint parameters
  cluster_access        = var.cluster_access
  cluster_access_source = var.cluster_access_source

  # oke worker network parameters
  oke_network_worker = local.oke_network_worker

  # oke load balancer network parameters
  lb_subnet_type = var.lb_subnet_type

  # oke load balancer ports
  public_lb_ports = var.public_lb_ports

  # waf integration
  waf_enabled = var.waf_enabled

}

# cluster creation for oke
module "oke" {
  source = "./modules/oke"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # region parameters
  ad_names = module.base.ad_names
  region   = var.region

  # ssh keys
  oke_ssh_keys = local.oci_base_ssh_keys

  # bastion details
  oke_operator = local.oke_operator

  # oke cluster parameters
  oke_cluster = local.oke_cluster

  # oke node pool parameters
  node_pools = local.node_pools

  # oke load balancer parameters
  lbs = local.lbs

  # ocir parameters
  oke_ocir = local.oke_ocir

  # calico parameters
  calico = local.calico

  # metric server
  metricserver_enabled = var.metricserver_enabled
  vpa                  = var.vpa

  # service account
  service_account = local.service_account

  #check worker nodes are active
  check_node_active = var.check_node_active

  nodepool_drain = var.nodepool_drain

  nodepool_upgrade_method = var.nodepool_upgrade_method

  node_pools_to_drain = var.node_pools_to_drain

}
