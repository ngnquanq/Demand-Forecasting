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
# resource "google_container_cluster" "application-gke" {
#   name     = var.gke_name
#   location = var.region

#   enable_autopilot = true
#   deletion_protection = true
#   }

resource "google_container_cluster" "application-cluster" {
  name                     = "application-cluster-primary"
  location                 = "us-central1"
  remove_default_node_pool = false
  initial_node_count       = 1
  deletion_protection = false
  # initial_cluster_version  = "1.30.4-gke.1348000"
}
resource "google_container_cluster" "application_gke" {
  name                    = "application-gke-primary"
  location                = "asia-southeast1-a"           # Zonal cluster
  initial_node_count      = 2                              # Default node pool size = 2 :contentReference[oaicite:2]{index=2}

  # Disable Autopilot to use standard node pools
  enable_autopilot        = false

  # (Optional) You can omit network/subnetwork to use “default”
}

# resource "google_container_node_pool" "application-cluster-pool" {
#   name       = "application-cluster-pool"
#   cluster    = google_container_cluster.application-cluster.name
#   location   = google_container_cluster.application-cluster.location
#   node_count = 2

#   node_config {
#     machine_type = "e2-medium"
#     oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
#   }
# }

