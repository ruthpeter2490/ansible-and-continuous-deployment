### Tooling ###

### Host Operating System Details ###
Operating System: MacOS Ventura, Version 13.0.1 
Chipset: Apple M1 Pro


### Software Used ###
Hypervisor details: UTM, Version 4.0.3
SHA256 checksum command: shasum, Version 6.02
Ubuntu OS Details: Ubuntu 20.04.5 LTS (Focal Fossa), 64-bit ARM


1. Docker Installation
The entire setup runs on docker and docker-compose
However, docker and docker-compose can be installed on the system using brew 
Command : brew install docker docker-compose
Docker version 20.10.22, build 3a2c30b
Docker Compose version v2.15.1

2. Versions Used
Jenkins version: 2.426.1
Ansible version: 2.10.17
Python version: 3.10.12 (for ansible)


## Step by step instructions ##

1. Install docker and docker-compose based on the above versions 

2. Build containers

3. build project on jenkins pipeline, copy war to production server and deploy project on production server using ansible

a. Unzip the assignment file (rpeter_assignment1.zip)
b. Give privileges to the automation script file using 
    chmod 777 automation.sh 
c. Run the given script file using ./automation.sh
    Wait for a few minutes for the automation to complete


3. Access jenkins to view the build pipline

a. Jenkins can be accessed at the following url 
    http://localhost:8080/

    If prompted : 
    username : admin
    Password : admin


4. Access petclinic project 

a. Petclinic project can be accessed at the following location
    http://localhost:8082/

5. Ansible Environment can be viewed using command 
   docker exec -it server bash, where all the ansible playbooks are run

5. Termination of processes 
    a. Use Ctrl+C to exit the script
    b. use docker-compose down to stop all containers



## Scripting Files used - additional details ##

1. automation.sh 
    This file contains the entire start to end process to set up the pipeline and deploy the process. *These are also the steps to setting up the project*

    Further details on the script :

    a. Runs the docker compose build and up command to deploy all the containers

    b. Run docker exec command to run the first ansible notebook which runs on the local ansible server to setup the ssh keys. (ssh-key-setup.yaml)

    c. Run docker exec command to setup the ssh keys for the production server, which is adding them to the ssh authorized keys. These keys are stored in a common volume shared by the 2 containers.
    
    d. Restart the ssh service on the production server with the newly added authorized key.

    e. Run docker exec command to setup the jenkins installation using ansible notebook. (jenkins-installation.yaml)
        i. Setup the jenkins server
        ii. Fetch crumb for authentication purposes(to send along every request)
        iii. log into the server and call the setup wizard 
        iv. Setup the pipeline using the mylocalconfig.xml (This was downloaded from a manually setup jenkins pipeline- reference included)
        v. Start the build process on the pipeline
    
    f. Run docker exec command to monitor the jenkins job build (jenkins-job.yaml)
        i. Wait for the process to finish by monitoring the jenkins job (every 25 secs)
        ii. If the process is success, run the host-deploy.yaml which deploys the petclini war on the production server
        iii. Else, it throws a failure stating job has failed
    

2.  ansible/Dockerfile
    This is the ansible dockerfile, which uses the ubuntu image, installs ssh to let ansible establish a connection with the other container, and installs ansible.
    We keep this container running to execute all the ansible playbooks

3. ansible/ansible_playbook/ssh-key-setup.yaml
   This file copies the public key of ansible ssh setup onto the shared volume. (This volume is shared between ansible and server)

4. ansible/ansible_playbook/jenkins-installation.yaml  
    This file does the following steps:
    i. Wait till the jenkins server is ready for requests.
    ii. Fetch crumb for authentication purposes(to send along every request)
    iii. log into the server and call the setup wizard 
    iv. Setup the pipeline using the mylocalconfig.xml (This was downloaded from a manually setup jenkins pipeline- reference included)
    v. Start the build process on the pipeline

5. ansible/ansible_playbook/jenkins-job.yaml  
    This file does the following steps:
    i. Wait till the triggered job has completed build
    ii. If job status returned is SUCCESS, then trigger host-deploy.yaml playbook
    iii. Else, gracefully exit the job and notify the job failure status

6. ansible/ansible_playbook/host-deploy.yaml
    This playbook executes on the server (host=server)
    i. It copies the war file from the jenkins location and runs the jar on te server

7.  mylocalconfig.xml
    The xml configuration for the build pipeline, it contains information regarding the different pipeline stages

8. inventory.yaml
     This file contains the details of remote hosts/containers which can be connected via ansible.
     We have our production server mentioned in this file, and it uses ansible's private key to make a connection

9. jenkins/Dockerfile 
    This is the jenkins dockerfile, which uses the jenkins base image, for jdk17. To further enhance automation, the use of JCasC(Jenkins configuration as a code) has been implemented. Also a few security settings have been tweaked around with, such as disabling the startup run wizard for automation process, and disabling the default crumb issuer to ignore the session ids. 
    Additional jenkins plugins have been installed such as 
    a. ansible - for the ansible triggered jobs
    b. configuration-as-code - for setting jenkins configurations through code 
    c. strict-crumb-issuer - to disable session id for using crumb 
    d. credentials-binding - to pass secret tokens through the jenkins pipeline


10. jenkins/jenkins-configuration.yaml
    This includes the jenkins configuration details 
    a. security realm - to add the extra layer of security as the inital token security setup was disabled 
    b. crumbIssue - to remove session match check
    c. sonarqube server setup - to automate the set up of sonarqube server urls
    d.tool - installation of maven tool for the build pipeline

11. jenkins/pipeline.groovy 
    This script is not directly used anywhere but it shows the pipeline process 
    a. Checkout - to checkout the github branch 
    b. Initialize - to check the installations of maven
    c. Build - to build the project using maven
    d. sonarqube analysis - to start the sonarqube analysis, this step uses credentials from the jenkins global credentials

12. petjar/Dockerfile
    This dockerfile is to deploy the spring container on which the downloaded jar from the jenkins server would be hosted. Additionally we also install ssh on this container, and create folders to add the authorized known keys to allow ansible to execute commands on this server. This container is kept running.

13. petjar/deploy.sh
    This script runs the jar file on the server, which is triggered by the host-deploy.yaml playbook

14. docker-compose.yml 
    This orchestrates the deployment of 4 containers 
    a. docker-dind - to enable deployement of docker containers inside the docker container 
    b. jenkins - to run the jenkins server (it builds the dockerfile in the jenkins folder)
    c. ansible - to run the ansible server (it builds the dockerfile in the ansible folder)
    d. server - to run the production server (it builds the dockerfile in the petjar folder)
    d. networks - to connect all the containers under a common network (helpful in establishing connection between jenkins ansible and production server)
    e. volumes - local volume to store information regarding the builds, certificates, ssh keys, and war files.


## Journal ##

I faced an issue while establishing a connection between the ansible and production server using ssh. It later came to my attention how to create the hosts for ansible and then executin scripts on the ansible environment. Initially i was on the wrong path, where I was trying to establish a connection between the host machine's docker engine and ansible's docker machine, and executing docker commands. This invalidates the entire concept of containerization.

Additionally I needed to disable a few security steps while automation and fine workarounds for the same, which may not be the most secure thing for the production server.


## Text Capture ##

1. 0_initial_script.png - initial run script
2. 1_container_creation.png - captures the containers deployed
3. 2_ssh_setup_ansible.png - captures the ansible notebook running for ssh key setup (ssh-key-setup.yaml)
4. 3a_jenkins_installation.png - captures the ansible notebook running for jenkins installation setup (jenkins-installation.yaml)
5. 3b_jenkins_installation_build_setup.png - shows successful jenkins setup
6. 3c_jenkins_build_pipeline_setup.png - shows successful pipeline setup and run
7. 4_jenkins_job_monitoring.png - captures the ansible notebook running for jenkins job monitoring (jenkins-job.yaml)
8. 5_war_deployment_execution.png - captures the ansible notebook running for server deployment(host-deploy.yaml)
9. 6_petclinic_homepage.png - welcome page of petclinic


## References ##

1. (ansible installation) https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-rhel-centos-or-fedora
2. (Inventory management)https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
3. (Ansible Pipeline analysis) https://medium.com/appgambit/ansible-playbook-with-jenkins-pipeline-2846d4442a31
4. (Ansible REST APIs) https://opensource.com/article/21/9/ansible-rest-apis
5. (SSH Setup on ansible and server) https://www.reddit.com/r/docker/comments/7tdyo2/ansible_in_docker_ansible_server_container_cant/
