#! /bin/bash

# Clean up the environment
rm -rf ~/.local/share/skupper
podman kill --all
podman system prune --force

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

PGSQL_USER=demo
PGSQL_PASSWORD=mypassword123
PGSQL_DB=demo-db
POSTRES_IMAGE=registry.redhat.io/rhel8/postgresql-13:1-56.1654147925
BACKEND_IMAGE=quay.io/bfarr/jboss-demo-backend
FRONTEND_IMAGE=quay.io/bfarr/jboss-demo-frontend
HOST=host.containers.internal
echo $HOST

podman network create banking-app

# If you want the data to persist across sessions use this option:
# -v /host/db/path:/var/lib/pgsql/data
#$CONTAINER_RUNTIME run --rm -d --name pgdb -e POSTGRESQL_USER=$PGSQL_USER -e POSTGRESQL_PASSWORD=$PGSQL_PASSWORD -e POSTGRESQL_DATABASE=$PGSQL_DB -p 5432:5432 $POSTRES_IMAGE
$CONTAINER_RUNTIME run --rm -d --name pgdb --hostname pgdb --network banking-app -e POSTGRESQL_USER=$PGSQL_USER -e POSTGRESQL_PASSWORD=$PGSQL_PASSWORD -e POSTGRESQL_DATABASE=$PGSQL_DB -p 5432:5432 $POSTRES_IMAGE
sleep 5

#$CONTAINER_RUNTIME run --rm -d -e POSTGRES_SERVICE_HOST=$(hostname) -e POSTGRES_DB=$PGSQL_DB -e POSTGRES_USER=$PGSQL_USER -e POSTGRES_PASSWORD=$PGSQL_PASSWORD -p 8080:8080 --name backend $BACKEND_IMAGE
$CONTAINER_RUNTIME run --rm -d -e POSTGRES_SERVICE_HOST=pgdb -e POSTGRES_DB=$PGSQL_DB -e POSTGRES_USER=$PGSQL_USER -e POSTGRES_PASSWORD=$PGSQL_PASSWORD -p 8080:8080 --name backend --hostname backend  --network banking-app  $BACKEND_IMAGE

#$CONTAINER_RUNTIME run --rm -d -e BACKEND_PROVIDER_URL=remote+http://$(hostname):8080 -p 8180:8080 --name frontend $FRONTEND_IMAGE
$CONTAINER_RUNTIME run --rm -d -e BACKEND_PROVIDER_URL=remote+http://backend:8080 -p 8180:8080 --hostname frontend --name frontend  --network banking-app $FRONTEND_IMAGE
