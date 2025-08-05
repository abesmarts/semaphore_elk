terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Build Docker image from Dockerfile
resource "docker_image" "custom_ubuntu" {
  name = "custom_ubuntu:latest"
  build {
    context    = "${abspath("../docker")}
    dockerfile = "Dockerfile"
  }
}

# Create container from custom image
resource "docker_container" "ubuntu_container" {
  name  = "ubuntu_ansible_ready"
  image = docker_image.custom_ubuntu.name
  tty   = true

  ports {
    internal = 22
    external = 2222
  }
  volumes = [
    "${abspath("../filebeat/filebeat.yml")}:/etc/filebeat/filebeat.yml",
    "${abspath("../python-scripts")}:/opt/python-scripts"
  ]
  
  # Optional: auto-remove stopped container (uncomment if needed)
  # must_run = false
  # restart = "no"
}

# Optional output to display SSH connection info
output "ssh_connection_command" {
  value = "ssh root@localhost -p 2222"
}

output "container_id" {
  value = docker_container.ubuntu_container.id
}
