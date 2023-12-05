# Use an official OpenJDK runtime as the base image
FROM openjdk:17-jdk-slim

# Set the working directory in the container
WORKDIR /app

# COPY ./app/shared_ssh_key/inventory.ini /home/inventory.ini

# Copy the JAR file from your host to the container at the working directory
# COPY spring-petclinic-3.1.0-SNAPSHOT.jar /app/petclinic.jar

# Expose the port your Spring Boot application will run on
EXPOSE 8082

# Define an environment variable for Spring profiles (if needed)
# ENV SPRING_PROFILES_ACTIVE=production

RUN apt-get update -y && apt-get install -y openssh-server openssh-client
RUN apt-get install -y python3
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN mkdir /run/sshd
# RUN chmod 755 /run/sshd
# Create SSH directory and authorized_keys

#cat shared_ssh_keys/connection-key.pub >> ~/.ssh/authorized_keys
#service ssh restart
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    touch ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys

RUN mkdir -p /petclinic-app

COPY deploy.sh /petclinic-app
RUN chmod 777 /petclinic-app/deploy.sh

CMD ["/usr/sbin/sshd", "-D"]

# Command to run your application
# CMD ["java", "-jar", "petclinic.jar"]