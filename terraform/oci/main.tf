locals {
  tenancy                        = data.sops_file.oci.data["tenancy_ocid"]
  instance_shape                 = "VM.Standard.E2.1.Micro"
  memory_in_gbs                  = 1
  ocpus                          = 1
  instance_boot_volume_size      = 50
  image_operating_system         = "Canonical Ubuntu"
  image_operating_system_version = "24.04"
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
  route_table_id  = oci_core_route_table.free_route_table.id
  dhcp_options_id = oci_core_vcn.free_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "free_internet_gateway" {
  compartment_id = oci_identity_compartment.free_compartment.id
  display_name   = "freeIG"
  vcn_id         = oci_core_vcn.free_vcn.id
}

resource "oci_core_route_table" "free_route_table" {
  compartment_id = oci_identity_compartment.free_compartment.id
  vcn_id         = oci_core_vcn.free_vcn.id
  display_name   = "freeRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.free_internet_gateway.id
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
    assign_public_ip = true
    subnet_id        = oci_core_subnet.free_subnet.id
    display_name     = "free_1"
  }

  metadata = {
    ssh_authorized_keys = file(local.instance_public_key_path)
  }
}
