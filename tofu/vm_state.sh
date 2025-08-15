#!/usr/bin/env bash
set -euo pipefail

# Minimal, idempotent startup script.
# It installs Filebeat (placeholder for package install),
# creates the vm_state log dir, and fetches a bootstrap marker.

VM_STATE_DIR="/var/log/vm_state"
mkdir -p "${VM_STATE_DIR}"
chown root:root "${VM_STATE_DIR}"
chmod 0755 "${VM_STATE_DIR}"

# Install prerequisites for Filebeat (APT repository)
if ! command -v filebeat >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y wget apt-transport-https gnupg ca-certificates
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
  echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list
  apt-get update -y
  apt-get install -y filebeat
fi

# prevent long-running heavy config in startup; Ansible will take over
# write a marker so Semaphore/Ansible know the instance is up
touch /var/run/instance_bootstrap_complete
