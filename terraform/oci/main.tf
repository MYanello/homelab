locals {
  tenancy                        = data.sops_file.oci.data["tenancy_ocid"]
  instance_shape                 = "VM.Standard.E2.1.Micro"
  memory_in_gbs                  = 1
  ocpus                          = 1
  arm_instance_shape             = "VM.Standard.A1.Flex"
  arm_memory_in_gbs              = 12
  arm_ocpus                      = 2
  instance_boot_volume_size      = 50
  image_operating_system         = "Canonical Ubuntu"
  image_operating_system_version = "26.04 Minimal"
  arm_availability_domain_index  = 1
  instance_public_key_path       = "/home/marcus/.ssh/id_ed25519.pub"
}

data "oci_core_images" "instance_images" {
  compartment_id           = data.sops_file.oci.data["tenancy_ocid"]
  operating_system         = local.image_operating_system
  operating_system_version = local.image_operating_system_version
  shape                    = local.instance_shape
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
}

data "oci_core_vnic_attachments" "free_1" {
  compartment_id = oci_identity_compartment.free_compartment.id
  instance_id    = oci_core_instance.free_instance_1.id
}

data "oci_core_private_ips" "free_1" {
  vnic_id = data.oci_core_vnic_attachments.free_1.vnic_attachments[0].vnic_id
}

data "oci_core_vnic_attachments" "free_arm" {
  compartment_id = local.tenancy
  instance_id    = oci_core_instance.free_arm_1.id
}

data "oci_core_private_ips" "free_arm" {
  vnic_id = data.oci_core_vnic_attachments.free_arm.vnic_attachments[0].vnic_id
}

resource "oci_identity_compartment" "free_compartment" {
  compartment_id = local.tenancy
  description    = "Oracle Cloud Free Tier compartment"
  name           = "always-free"
  enable_delete  = true
}

resource "oci_core_vcn" "free_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = oci_identity_compartment.free_compartment.id
  display_name   = "freeVCN"
  dns_label      = "freevcn"
}

resource "oci_core_subnet" "free_subnet" {
  cidr_block      = "10.1.20.0/24"
  display_name    = "freeSubnet"
  dns_label       = "freesubnet"
  compartment_id  = oci_identity_compartment.free_compartment.id
  vcn_id          = oci_core_vcn.free_vcn.id
  route_table_id  = oci_core_vcn.free_vcn.default_route_table_id
  dhcp_options_id = oci_core_vcn.free_vcn.default_dhcp_options_id
  security_list_ids = [
    oci_core_security_list.free_subnet.id,
    oci_core_security_list.wan_exporter.id,
  ]
}

resource "oci_core_internet_gateway" "free_internet_gateway" {
  compartment_id = oci_identity_compartment.free_compartment.id
  display_name   = "freeIG"
  vcn_id         = oci_core_vcn.free_vcn.id
}

resource "oci_core_security_list" "free_subnet" {
  compartment_id = oci_identity_compartment.free_compartment.id
  vcn_id         = oci_core_vcn.free_vcn.id
  display_name   = "freeSubnetHomelab"

  ingress_security_rules {
    protocol    = "all"
    source      = "192.168.0.0/16"
    description = "homelab LAN and infrastructure"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "10.1.0.0/16"
    description = "VCN"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "10.10.8.0/22"
    description = "cluster load balancer addresses"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "10.42.0.0/16"
    description = "cluster pod network"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "wan_exporter" {
  compartment_id = oci_identity_compartment.free_compartment.id
  vcn_id         = oci_core_vcn.free_vcn.id
  display_name   = "freeSecurityList"

  ingress_security_rules {
    protocol = "all"
    source   = "127.0.0.1/32"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  lifecycle {
    ignore_changes = [ingress_security_rules]
  }
}

resource "oci_core_default_route_table" "free_vcn" {
  manage_default_resource_id = oci_core_vcn.free_vcn.default_route_table_id
  display_name               = "freeRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.free_internet_gateway.id
  }

  route_rules {
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.free_1.private_ips[0].id
  }

  route_rules {
    destination       = "10.10.8.0/22"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.free_1.private_ips[0].id
  }

  route_rules {
    destination       = "10.42.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.free_1.private_ips[0].id
  }

  route_rules {
    destination       = "10.42.3.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.free_arm.private_ips[0].id
  }
}

resource "oci_core_instance" "free_instance_1" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  compartment_id      = oci_identity_compartment.free_compartment.id
  shape               = local.instance_shape
  display_name        = "free_1"

  shape_config {
    memory_in_gbs = local.memory_in_gbs
    ocpus         = local.ocpus
  }

  source_details {
    source_id               = data.oci_core_images.instance_images.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = local.instance_boot_volume_size
  }

  create_vnic_details {
    assign_public_ip       = true
    subnet_id              = oci_core_subnet.free_subnet.id
    display_name           = "free_1"
    skip_source_dest_check = true
  }

  metadata = {
    ssh_authorized_keys = file(local.instance_public_key_path)
  }
}

resource "oci_core_instance" "free_arm_1" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[local.arm_availability_domain_index].name
  compartment_id      = local.tenancy
  shape               = local.arm_instance_shape
  display_name        = "free-arm"

  shape_config {
    memory_in_gbs = local.arm_memory_in_gbs
    ocpus         = local.arm_ocpus
  }

  source_details {
    source_id               = "ocid1.image.oc1.iad.aaaaaaaagcccqesxzyiuok6mglwa4lprh55x4ynf2i6rakwneutaljkttyha"
    source_type             = "image"
    boot_volume_size_in_gbs = local.instance_boot_volume_size
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.free_subnet.id
  }

  metadata = {
    ssh_authorized_keys = file(local.instance_public_key_path)
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
