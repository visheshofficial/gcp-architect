

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a static IP address
# resource "google_compute_address" "static_ip" {
#   name   = "my-static-ip"
#   region = var.region
# }


# Create a Google Compute Engine instance
resource "google_compute_instance" "my_first_vm" {
  name         = "my-first-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata_startup_script = <<-EOT
              #!/bin/bash
              sudo su
              apt update
              apt install -y apache2
              # ls /var/www/html
              # echo "Hello World!"
              # echo "Hello World!" > /var/www/html/index.html
              # echo $(hostname)
              # echo $(hostname -i)
              # echo "Hello World from $(hostname)"
              # echo "Hello World from $(hostname) $(hostname -i)"
              echo "Hello world from $(hostname) $(hostname -i)" > /var/www/html/index.html
              sudo service apache2 start
              EOT
}

# Create a firewall rule to allow HTTP traffic
resource "google_compute_firewall" "default" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
