#!/bin/bash

echo "Starting all containers"
docker-compose up --build -d

docker exec ansible ansible-playbook /ansible_playbook/ssh-key-setup.yaml
docker exec server bash -c 'cat shared_ssh_keys/connection-key.pub >> ~/.ssh/authorized_keys'
docker exec server service ssh restart

docker exec ansible ansible-playbook /ansible_playbook/jenkins-installation.yaml
docker exec ansible ansible-playbook /ansible_playbook/jenkins-job.yaml

