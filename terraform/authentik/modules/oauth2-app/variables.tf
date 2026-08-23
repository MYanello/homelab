variable "name" {
  description = "Display name for the provider and application"
  type        = string
}

variable "slug" {
  description = "Application slug"
  type        = string
}

variable "client_id" {
  description = "OAuth2 client ID"
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

variable "redirect_uris" {
  description = "List of redirect URI configs"
  type = list(object({
    matching_mode     = string
    url               = string
    redirect_uri_type = string
  }))
}

variable "access_code_validity" {
  description = "Authorization code validity duration"
  type        = string
  default     = "minutes=1"
}

variable "access_token_validity" {
  description = "Access token validity duration"
  type        = string
  default     = "minutes=5"
}

variable "refresh_token_validity" {
  description = "Refresh token validity duration"
  type        = string
  default     = "days=7"
}

variable "refresh_token_threshold" {
  description = "Refresh token threshold duration"
  type        = string
  default     = "seconds=30"
}

variable "sub_mode" {
  description = "Subject mode"
  type        = string
  default     = "hashed_user_id"
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

variable "grant_types" {
  description = "OAuth2 grant types"
  type        = list(string)
  default = [
    "authorization_code", "hybrid", "implicit", "client_credentials",
    "password", "urn:ietf:params:oauth:grant-type:device_code", "refresh_token"
  ]
}

variable "signing_key" {
  description = "Signing key ID"
  type        = string
  default     = "26f428c7-9534-4ea6-a839-9a6cf003c9c6"
}
