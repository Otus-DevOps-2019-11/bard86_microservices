terraform {
  required_version = "0.12.19"
}

provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "runner" {
  count        = var.instance_count
  name         = "gitlab-ci-runner-${count.index + 1}"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["runner"]
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}
