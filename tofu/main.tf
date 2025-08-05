terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "custom_ubuntu" {
  name = "custom_ubuntu:latest"

  build {
    context    = abspath("../docker")
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "ubuntu_container" {
  name  = "ubuntu_monitor"
  image = docker_image.custom_ubuntu.name

  ports {
    internal = 22
    external = 2222
  }

  mounts {
    target    = "/etc/filebeat/filebeat.yml"
    source    = abspath("../filebeat/filebeat.yml")
    type      = "bind"
    read_only = true
  }

  mounts {
    target = "/opt/python-scripts"
    source = abspath("../python-scripts")
    type   = "bind"
  }

  command = ["/usr/sbin/sshd", "-D"]
}

output "ssh_connection_command" {
  value = "ssh root@localhost -p 2222"
}

output "container_id" {
  value = docker_container.ubuntu_container.id
}
