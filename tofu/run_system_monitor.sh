#!/bin/bash
set -e

# Run system_monitor.py on the container via SSH
sshpass -p "tofuadmin" ssh -o StrictHostKeyChecking=no root@localhost -p 2222 \
    "python3 /opt/python-scripts/system_monitor.py"
