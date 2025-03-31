terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.27.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project_id
  region      = var.region_name
}

resource "google_storage_bucket" "flights_bucket" {
  name     = var.bucket_name
  location = var.region_name
  public_access_prevention = "enforced"
  storage_class = "STANDARD"
}

resource "google_bigquery_dataset" "flights_dataset" {
  dataset_id = var.dataset_name
  location   = var.region_name
}

resource "google_compute_instance" "flights_vm" {

  name = var.vm_name
  zone = var.zone_name
  machine_type = "e2-standard-2"
  tags = ["https-server"]

  depends_on = [
    google_storage_bucket.flights_bucket,
    google_bigquery_dataset.flights_dataset
  ]

  boot_disk {
    auto_delete = true
    device_name = var.vm_name

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250312"
      size  = 40
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src           = "vm_add-tf"
    goog-ops-agent-policy = "v2-x86-template-1-4-0"
  }

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys = "${var.ssh_user}:${file("${var.ssh_public_key_path}")}"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/${var.project_id}/regions/${var.region_name}/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = self.network_interface[0].access_config[0].nat_ip
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  provisioner "file" {
    source      = var.kestra_flow_path
    destination = "/home/${var.ssh_user}/${var.kestra_flow_name}"
  }
  provisioner "file" {
    source      = var.pipeline_script_path
    destination = "/home/${var.ssh_user}/${var.pipeline_script_name}"
  }
    provisioner "file" {
    source      = var.credentials_file_path
    destination = "/home/${var.ssh_user}/${var.credentials_file_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/${var.pipeline_script_name}",
      "/home/${var.ssh_user}/${var.pipeline_script_name} ${var.project_id} ${var.region_name} ${var.bucket_name} ${var.dataset_name}",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

}
