output "vm_instance_name" {
  value = google_compute_instance.my_first_vm.name
}

output "vm_instance_ip" {
  value = google_compute_instance.my_first_vm.network_interface[0].access_config[0].nat_ip
}
