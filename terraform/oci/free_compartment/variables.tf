variable "tenancy" {
  description = "The tenancy OCID for a user. The tenancy OCID can be found at the bottom of user settings in the Oracle Cloud Infrastructure console. Required if auth is set to 'ApiKey', ignored otherwise."
  type        = string
}

variable "instance_hostname" {
  description = "A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information."
  type        = string
  default     = "free"
}


variable "instance_ocpus" {
  description = "The total number of OCPUs available to the instance."
  type        = number
  default     = 4
}

variable "instance_memory" {
  description = "The total amount of memory available to the instance, in gigabytes."
  type        = number
  default     = 24
}

variable "instance_boot_volume_size" {
  description = "The size of the boot volume in GBs. Minimum value is 50 GB and maximum value is 32,768 GB (32 TB)."
  type        = number
  default     = 200
}

variable "instance_public_key_path" {
  description = "Public SSH key to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
  type        = string
  default     = ""
}

variable "personal_ip" {
  description = "Your personal IP address to allow ingress access to the instance."
  type        = string
}

variable "name" {
  description = "A user-friendly name for the instance. Does not have to be unique, and it's changeable."
  type        = string
  default     = "free_instance"
}