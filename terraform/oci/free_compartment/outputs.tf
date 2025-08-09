# Outputs for compartment

output "compartment-name" {
  description = "The name you assign to the compartment during creation. The name must be unique across all compartments in the parent."
  value       = oci_identity_compartment.free_compartment.name
}

output "compartment-id" {
  description = "The OCID of the compartment."
  value       = oci_identity_compartment.free_compartment.id
}

output "subnet-id" {
  description = "The OCID of the subnet created in the compartment."
  value       = oci_core_subnet.free_subnet.id
}