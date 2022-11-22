#! /bin/bash

# Check that one of Podman or Docker is installed.
echo "Checking for container runtime..."
runtime=$(which podman)
inst_status=$?
if [ $inst_status -eq 0 ]; then
   echo "Podman is installed"
   CONTAINER_RUNTIME="podman"
else
  runtime=$(which docker)
  inst_status=$?
  if [ $inst_status -eq 0 ]; then
    echo "Docker is installed"
    CONTAINER_RUNTIME="docker"
   else
      echo "ERROR: No container runtime found."
      exit
   fi
fi

$CONTAINER_RUNTIME run --rm -d --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgresdb -p 5432:5432 postgres

$CONTAINER_RUNTIME run --rm -d -e POSTGRES_SERVICE_HOST=$(hostname) -e POSTGRES_DB=postgresdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8080:8080 --name backend quay.io/bfarr/jboss-demo-backend

$CONTAINER_RUNTIME run --rm -d -e BACKEND_PROVIDER_URL=remote+http://$(hostname):8080 -p 8180:8080 --name frontend quay.io/bfarr/jboss-demo-frontend
