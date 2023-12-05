FROM ubuntu:latest

# Install necessary packages (Python and Ansible)
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    && apt-get clean

RUN apt-get install -y vim
RUN apt-get install -y openssh-client

RUN mkdir /keys
RUN ssh-keygen -t rsa -b 4096 -f /keys/connection-key

# RUN ls /
# RUN cp /keys/connection-key.pub /app/shared_ssh_keys/
# RUN apt-get install openssh-client
RUN pip3 install 'ansible==2.10.4'



# Copy Ansible playbook and related files into the container
COPY ansible_playbook /ansible_playbook

EXPOSE 8086

# Run Ansible playbook
WORKDIR /ansible_playbook
# RUN ansible-playbook playbook.yaml
# RUN ansible-playbook ssh_key_setup.yaml

# Set the default command to be executed when the container starts
CMD ["/bin/bash"]