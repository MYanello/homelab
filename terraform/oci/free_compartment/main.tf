data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy
}

resource "oci_identity_compartment" "free_compartment" {
  compartment_id = var.tenancy
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
  cidr_block        = "10.1.20.0/24"
  display_name      = "freeSubnet"
  dns_label         = "freesubnet"
  security_list_ids = [oci_core_security_list.free_security_list.id]
  compartment_id    = oci_identity_compartment.free_compartment.id
  vcn_id            = oci_core_vcn.free_vcn.id
  route_table_id    = oci_core_route_table.free_route_table.id
  dhcp_options_id   = oci_core_vcn.free_vcn.default_dhcp_options_id
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

resource "oci_core_security_list" "free_security_list" {
  compartment_id = oci_identity_compartment.free_compartment.id
  vcn_id         = oci_core_vcn.free_vcn.id
  display_name   = "freeSecurityList"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.personal_ip

    tcp_options {
      max = "22"
      min = "22"
    }
  }
}

resource "tls_private_key" "instance_ssh_key" {
  count     = var.instance_public_key_path != "" ? 1 : 0
  algorithm = "ED25519"
}
