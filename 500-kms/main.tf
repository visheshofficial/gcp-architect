## This is not working and need to be improved

provider "google" {
  project = var.project_id
  region  = var.region
}

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

resource "google_kms_key_ring" "my_key_ring" {
  name     = "my-key-ring"
  location = var.region # can be gloabl as well.
}

resource "google_kms_crypto_key" "my_first_key" {
  name            = "my-first-key"
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = "86400s" # Minimum rotation period is 1 day (86400 seconds)

  lifecycle {
    prevent_destroy = false
  }

  version_template {
    protection_level = "SOFTWARE"
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

### Create Cloud Engine VM that uses the KMS key to encrypt the disk data ###
resource "google_compute_instance" "vm_instance" {
  name         = "my-vm-instance"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"

    }
    kms_key_self_link = google_kms_crypto_key.my_first_key.id
  }

  network_interface {
    network = "default"
  }

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }
}



resource "google_service_account" "vm_service_account" {
  account_id   = "vm-service-account"
  display_name = "VM Service Account"
}

# resource "google_project_iam_binding" "kms_key_binding" {
#   project = var.project_id
#   role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

#   members = [
#     "serviceAccount:${google_service_account.vm_service_account.email}"
#   ]
# }

resource "google_kms_crypto_key_iam_member" "my_key_binding" {
  crypto_key_id = google_kms_crypto_key.my_first_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.vm_service_account.email}"
}


output "key_name" {
  value = google_kms_crypto_key.my_first_key.name
}
output "key_ring_name" {
  value = google_kms_key_ring.my_key_ring.name
}
