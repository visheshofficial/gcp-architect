variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  # default     = "us-central1"
}

variable "machine_type" {
  description = "The machine type to use for the GKE nodes"
  type        = string
  # default     = "e2-medium"
}
