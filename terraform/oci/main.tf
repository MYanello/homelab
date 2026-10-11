module "free_compartment" {
  source = "./free_compartment"

  tenancy                   = data.sops_file.oci.data["tenancy_ocid"]
  instance_hostname         = "free_1"
  instance_ocpus            = 1
  instance_memory           = 1
  instance_boot_volume_size = 50
  instance_public_key_path  = local.instance_public_key_path
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
