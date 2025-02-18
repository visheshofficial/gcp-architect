

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
              echo "Hello world from $(hostname) $(hostname -i)" > /var/www/html/index.html
              sudo service apache2 start
              EOT
}

# Create an instance template
resource "google_compute_instance_template" "instance_template_bye" {
  name         = "my-instance-template-bye"
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
              echo "Bye world from $(hostname) $(hostname -i)" > /var/www/html/index.html
              sudo service apache2 start
              EOT
}
# Create a managed instance group using the instance template
resource "google_compute_instance_group_manager" "instance_group_manager" {
  count              = var.create_template_vm ? 1 : 0
  name               = "my-instance-group"
  base_instance_name = "my-instance"
  zone               = var.zone
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.instance_template.id
  }

  version {
    instance_template = google_compute_instance_template.instance_template_bye.id
    name              = "new-template-bye"
    target_size {
      fixed = 1
    }
  }
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
    # min_ready_sec         = 60
  }


  named_port {
    name = "http"
    port = 80
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 30
  }
}

# Create a health check
resource "google_compute_health_check" "default" {
  name                = "my-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    request_path = "/"
    port         = 80
  }
}

# Create an autoscaler for the instance group
resource "google_compute_autoscaler" "instance_group_autoscaler" {
  depends_on = [google_compute_instance_group_manager.instance_group_manager]
  name       = "my-instance-group-autoscaler"
  zone       = var.zone
  target     = google_compute_instance_group_manager.instance_group_manager[0].id

  autoscaling_policy {
    max_replicas    = 1
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }

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
