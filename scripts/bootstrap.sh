#!/bin/bash
cd terraform
terraform init
terraform apply -auto-approve

cd ../ansible
ansible-playbook -i inventory.ini playbook.yml

cd ../docker
docker stack deploy -c docker-compose.yml myapp
