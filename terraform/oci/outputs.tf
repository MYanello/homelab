output "free_instance_1_public_ip" {
  description = "The public IP address of the free_1 instance."
  value       = oci_core_instance.free_instance_1.public_ip
}
