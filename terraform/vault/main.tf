

# resource "vault_mount" "pki_root" {
#   path                      = "pki"
#   type                      = "pki"
#   description               = "Root CA for Yanello Homelab"
#   default_lease_ttl_seconds = 86400
#   max_lease_ttl_seconds     = 315360000 # 10 years
# }

# resource "vault_mount" "pki_int" {
#   path                      = "pki_int"
#   type                      = "pki"
#   description               = "Intermediate CA for Yanello Homelab"
#   default_lease_ttl_seconds = 86400
#   max_lease_ttl_seconds     = 157680000 # 5 years
# }

# # Generate root CA
# resource "vault_pki_secret_backend_root_cert" "root" {
#   backend     = vault_mount.pki_root.path
#   type        = "internal"
#   common_name = "Yanello Homelab Root CA"
#   ttl         = "315360000" # 10 years
#   format      = "pem"
  
#   private_key_format = "der"
#   key_type          = "ec"
#   key_bits          = 256
  
#   exclude_cn_from_sans = true
#   organization         = "Yanello Homelab"
#   country             = "US"
  
#   # Name constraints (equivalent to your cert-manager setup)
#   permitted_dns_domains = ["yanello.net"]
# }

# resource "vault_pki_secret_backend_config_urls" "root_config" {
#   backend                 = vault_mount.pki_root.path
#   issuing_certificates    = ["https://vault.yanello.net/v1/pki/ca"]
#   crl_distribution_points = ["https://vault.yanello.net/v1/pki/crl"]
# }

# # Generate intermediate CSR
# resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
#   backend     = vault_mount.pki_int.path
#   type        = "internal"
#   common_name = "Yanello Homelab Intermediate CA"
  
#   key_type = "ec"
#   key_bits = 256
  
#   organization = "Yanello Homelab"
#   country     = "US"
# }

# # Sign intermediate with root
# resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
#   backend              = vault_mount.pki_root.path
#   csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
#   common_name          = "Yanello Homelab Intermediate CA"
#   exclude_cn_from_sans = true
#   ttl                  = "157680000" # 5 years
  
#   organization = "Yanello Homelab"
#   country     = "US"
# }

# # Set the signed intermediate certificate
# resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
#   backend     = vault_mount.pki_int.path
#   certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
# }

# # Configure intermediate CA URLs
# resource "vault_pki_secret_backend_config_urls" "int_config" {
#   backend                 = vault_mount.pki_int.path
#   issuing_certificates    = ["https://vault.yanello.net/v1/pki_int/ca"]
#   crl_distribution_points = ["https://vault.yanello.net/v1/pki_int/crl"]
# }

# # Create roles for different certificate types
# resource "vault_pki_secret_backend_role" "internal_services" {
#   backend          = vault_mount.pki_int.path
#   name             = "internal-services"
#   ttl              = "86400"   # 24 hours
#   max_ttl          = "604800"  # 7 days
#   allow_ip_sans    = true
#   key_type         = "ec"
#   key_bits         = 256
#   allowed_domains  = [
#     "yanello.net",
#     "internal.yanello.net", 
#     "yanello.internal",
#     "svc.cluster.local",
#     "cluster.local"
#   ]
#   allow_subdomains = true
#   allow_localhost  = true
#   server_flag      = true
#   client_flag      = true
# }

# resource "vault_pki_secret_backend_role" "web_services" {
#   backend          = vault_mount.pki_int.path
#   name             = "web-services"
#   ttl              = "2592000"  # 30 days
#   max_ttl          = "7776000"  # 90 days
#   allow_ip_sans    = false
#   key_type         = "ec"
#   key_bits         = 256
#   allowed_domains  = ["yanello.net"]
#   allow_subdomains = true
#   server_flag      = true
#   client_flag      = false
# }