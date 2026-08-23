variable "name" {
  description = "Display name for the provider and application"
  type        = string
}

variable "slug" {
  description = "Application slug"
  type        = string
}

variable "authorization_flow" {
  description = "Authorization flow ID"
  type        = string
}

variable "invalidation_flow" {
  description = "Invalidation flow ID"
  type        = string
}

variable "property_mappings" {
  description = "List of property mapping IDs"
  type        = list(string)
}

variable "external_host" {
  description = "External host URL"
  type        = string
}

variable "internal_host" {
  description = "Internal backend URL"
  type        = string
}

variable "meta_launch_url" {
  description = "Application launch URL"
  type        = string
}

variable "open_in_new_tab" {
  description = "Open launch URL in new tab"
  type        = bool
  default     = false
}

variable "access_token_validity" {
  description = "Access token validity duration"
  type        = string
  default     = "hours=720"
}
