variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy to"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type to use for the VM"
  type        = string
  default     = "e2-medium"
}

variable "create_standalone_vm" {
  description = "Set to true to create  standalone VM instance, false to skip"
  type        = bool
  default     = true
}

variable "create_template_vm" {
  description = "Set to true to create the VM instance, false to skip"
  type        = bool
  default     = true
}

variable "create_static_ip" {
  description = "Set to true to create a static IP address, false to skip"
  type        = bool
  default     = true
}
