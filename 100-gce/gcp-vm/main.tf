

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a static IP address
resource "google_compute_address" "static_ip" {
  count  = var.create_static_ip ? 1 : 0
  name   = "my-static-ip"
  region = var.region
}

# Create an instance template
resource "google_compute_instance_template" "instance_template" {
  name         = "my-instance-template"
  machine_type = var.machine_type

  tags = ["http-server"]

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = var.create_static_ip ? google_compute_address.static_ip[0].address : null
    }
  }

  metadata_startup_script = <<-EOT
              #!/bin/bash
              # sudo su
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

# Create a managed instance group using the instance template
resource "google_compute_instance_group_manager" "instance_group_manager" {
  count              = var.create_template_vm ? 1 : 0
  name               = "my-instance-group"
  base_instance_name = "my-instance"
  version {
    instance_template = google_compute_instance_template.instance_template.id
  }
  zone        = var.zone
  target_size = 1
}



# Create a Google Compute Engine instance
resource "google_compute_instance" "my_first_vm" {
  count        = var.create_standalone_vm ? 1 : 0
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
      nat_ip = var.create_static_ip ? google_compute_address.static_ip[0].address : null
    }
  }

  metadata_startup_script = <<-EOT
              #!/bin/bash
              # sudo su
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
