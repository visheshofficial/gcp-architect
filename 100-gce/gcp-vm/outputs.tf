output "vm_instance_name" {
  value = length(google_compute_instance.my_first_vm) > 0 ? google_compute_instance.my_first_vm[0].name : null
}

output "vm_instance_ip" {
  value = length(google_compute_instance.my_first_vm) > 0 ? google_compute_instance.my_first_vm[0].network_interface[0].access_config[0].nat_ip : null
}

output "static_ip_address" {
  value = var.create_static_ip ? google_compute_address.static_ip[0].address : null
}

