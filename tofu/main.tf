terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

provider "google" {
  project = "my-gcp-project-id"            # <-- CHANGE
  region  = "us-central1"
  zone    = "us-central1-a"
}

# -------- VM --------
resource "google_compute_instance" "ubuntu_vm" {
  name         = "semaphore-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {} # external IP
  }

  metadata = {
    # Uses your local public key; user "ubuntu" must match your SSH user
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"   # <-- CHANGE if needed
  }

  tags = ["allow-ssh"]
}

# -------- Firewall (SSH) --------
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

# -------- Upload your python_scripts dir --------
# Make sure a local folder named "python_scripts" exists next to main.tf
resource "null_resource" "upload_python_scripts" {
  depends_on = [google_compute_instance.ubuntu_vm]

  # 1) Ensure destination directory exists
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/monitoring/scripts",
      "sudo chown -R ubuntu:ubuntu /opt/monitoring",
      "sudo chmod -R 755 /opt/monitoring"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")  # <-- Path to your private key
      host        = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
    }
  }

  # 2) Upload directory recursively
  provisioner "file" {
    source      = "python_scripts"          # <-- local folder (relative to main.tf)
    destination = "/opt/monitoring/scripts" # <-- remote dir

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
    }
  }

  # 3) Fix permissions after upload
  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ubuntu:ubuntu /opt/monitoring/scripts",
      "sudo chmod -R 755 /opt/monitoring/scripts"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
    }
  }
}

# -------- Output --------
output "vm_ip" {
  description = "Public IP of the VM"
  value       = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
}
