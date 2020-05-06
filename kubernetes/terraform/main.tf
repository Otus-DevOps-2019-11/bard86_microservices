terraform {
  required_version = ">= 0.12.9"
}

provider "google" {
  version = "3.0.0"
  project = var.project
  region  = var.region
}

resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = var.cluster_node_count

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "cluster-nodes" {
  name     = var.pool_name
  location = var.zone

  cluster    = google_container_cluster.cluster.name
  node_count = var.pool_node_count

  node_config {
    preemptible  = true
    machine_type = var.machine_type
    tags         = var.tags

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_firewall" "firewall-k8s" {
  name    = "allow-k8s"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = var.ports
  }
  direction     = "INGRESS"
  source_ranges = var.source_ranges
  target_tags   = var.tags
}
