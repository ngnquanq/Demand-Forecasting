resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type       # e2‑micro → shared‑core
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 15   # GB
    }
  }

  network_interface {
    network = "default"
    access_config {}   # allocates 1 ephemeral public IP
  }

  metadata_startup_script = <<-EOS
    #!/bin/bash
    sudo apt-get update -y && sudo apt-get install -y nginx
  EOS
}

resource "google_compute_firewall" "default" {
  name    = "${var.vm_name}-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080","50000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# resource "google_container_cluster" "primary" {
#   name     = "application-gke"
#   location = var.zone

#   // Enabling Autopilot for this cluster
#   enable_autopilot = false

#   //Delete protetion false
#   deletion_protection = false

#   // Specify the initial number of nodes
#   initial_node_count = 2

#   // Node configuration
#   node_config {
#     machine_type = "e2-standard-2" // 2 vCPUs, 8 GB RAM
#     disk_size_gb = 20
#   }
# }
