#!/bin/bash
set -e
cd tofu   
tofu init
tofu apply -auto-approve
