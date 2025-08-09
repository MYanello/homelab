locals {
  admin_user_id = "ocid1.user.oc1..aaaaaaaakfe6mukfk43qlbvnwsajk2qpatdxihiipbb67556ur3ei2c2nv7a"
}

resource "oci_kms_vault" "hcl_vault" {
  compartment_id = oci_identity_compartment.vault_autounseal.id
  display_name   = "hc-vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "vault_autounseal" {
  compartment_id = oci_identity_compartment.vault_autounseal.id
  display_name   = "hc-key"
  key_shape {
    algorithm = "AES"
    length    = "32"
  }
  management_endpoint = oci_kms_vault.hcl_vault.management_endpoint
  protection_mode     = "HSM"
}

resource "oci_identity_compartment" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal"
  description    = "Compartment for Vault auto-unseal resources"
}

resource "oci_identity_user" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal-user"
  description    = "Service user for Vault auto-unseal operations"
  email          = "vault-autounseal@yanello.net"
}

resource "oci_identity_group" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal-group"
  description    = "Group with permissions for Vault auto-unseal"
}

resource "oci_identity_user_group_membership" "vault_autounseal" {
  group_id = oci_identity_group.vault_autounseal.id
  user_id  = oci_identity_user.vault_autounseal.id
}

resource "oci_identity_user_group_membership" "vault_autounseal_admin_user" {
  group_id = oci_identity_group.vault_autounseal.id
  user_id  = local.admin_user_id
}

resource "oci_identity_policy" "vault_autounseal" {
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
  name           = "vault-autounseal-policy"
  description    = "Policy for Vault auto-unseal KMS operations"

  statements = [
    "Allow group ${oci_identity_group.vault_autounseal.name} to manage keys in compartment ${oci_identity_compartment.vault_autounseal.name}",
    "Allow group ${oci_identity_group.vault_autounseal.name} to manage vaults in compartment ${oci_identity_compartment.vault_autounseal.name}",
    "Allow group ${oci_identity_group.vault_autounseal.name} to use key-delegate in compartment ${oci_identity_compartment.vault_autounseal.name}",
    "Allow group ${oci_identity_group.vault_autounseal.name} to manage objects in compartment ${oci_identity_compartment.vault_autounseal.name}"
  ]
}

data "sops_file" "vault-autounseal-private" {
  source_file = "sops/vault-autounseal-private.enc.pem"
  input_type  = "raw"
}
data "sops_file" "vault-autounseal-public" {
  source_file = "sops/vault-autounseal-public.enc.pem"
  input_type  = "raw"
}

resource "oci_identity_api_key" "vault_autounseal" {
  user_id   = oci_identity_user.vault_autounseal.id
  key_value = data.sops_file.vault-autounseal-public.raw
}

module "free_compartment" {
  source = "./free_compartment"

  tenancy                   = data.sops_file.oci.data["tenancy_ocid"]
  instance_hostname         = "free_1"
  instance_ocpus            = 1
  instance_memory           = 1
  instance_boot_volume_size = 50
  instance_public_key_path  = local.instance_public_key_path
  personal_ip               = "162.194.16.64/32"
  name                      = "free_instance_0"
}


locals {
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

resource "oci_core_instance" "free_instance_1" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  compartment_id      = module.free_compartment.compartment-id
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
    subnet_id        = module.free_compartment.subnet-id
    display_name     = "free_1"
  }

  metadata = {
    ssh_authorized_keys = file(local.instance_public_key_path)
  }
}
