terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Build Docker image from our fixed Dockerfile
resource "docker_image" "custom_ubuntu" {
  name = "custom_ubuntu:latest"

  build {
    context    = abspath("../docker")
    dockerfile = "Dockerfile"
  }
}

# Create the Ubuntu container
resource "docker_container" "ubuntu_container" {
  name  = "ubuntu_monitor"
  image = docker_image.custom_ubuntu.name

  ports {
    internal = 22
    external = 2222
  }

  # Mount the python scripts into /opt/python-scripts
  mounts {
    target    = "/opt/python-scripts"
    source    = abspath("../python-scripts")
    type      = "bind"
    read_only = false
  }

  # Mount Filebeat config
  mounts {
    target    = "/etc/filebeat/filebeat.yml"
    source    = abspath("../filebeat/filebeat.yml")
    type      = "bind"
    read_only = true
  }

  # Keep container running (SSH server)
  command = ["/usr/sbin/sshd", "-D"]
}

# Output SSH connection info
output "ssh_connection_command" {
  value = "ssh root@localhost -p 2222"
}

# Output container ID
output "container_id" {
  value = docker_container.ubuntu_container.id
}
