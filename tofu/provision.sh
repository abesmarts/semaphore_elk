#!/bin/bash
set -e
cd /path/to/tofu   # adjust to where main.tf lives in the runner
tofu init
tofu apply -auto-approve
