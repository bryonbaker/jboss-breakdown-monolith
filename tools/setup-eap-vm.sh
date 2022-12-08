#! /bin/bash

JBOSS_HOME=../../jboss-eap-7.4

cp ../original-monolith/original-ear/target/obank.ear $JBOSS_HOME/standalone/deployments
cp ../modular/modular-ear/target/modular-ear.ear $JBOSS_HOME/standalone/deployments
cp ../refactored/refactored-ear-frontend/target/frontend.ear $JBOSS_HOME/standalone/deployments
cp ../refactored/refactored-ear-backend/target/backend.ear $JBOSS_HOME/standalone/deployments
cp ../files/standalone.xml $JBOSS_HOME/standalone/configuration/standalone.xml
mkdir -p $JBOSS_HOME/modules/org/postgresql/main
cp ../files/pgdatasource/module.xml $JBOSS_HOME/modules/org/postgresql/main/module.xml
cp ../files/pgdatasource/postgresql-42.5.0.jar $JBOSS_HOME/modules/org/postgresql/main/postgresql-42.5.0.jar

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

$CONTAINER_RUNTIME run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -d -p 5432:5432 docker.io/library/postgres:10
echo "Pausing for 3 seconds until starting eap"
sleep 3
export POSTGRES_SERVICE_HOST=localhost
export BACKEND_PROVIDER_URL=remote+http://localhost:8080
export POSTGRES_DB=postgres
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=mypassword123

$JBOSS_HOME/bin/add-user.sh -a -u 'jboss' -p 'jboss'

$JBOSS_HOME/bin/standalone.sh -b 0.0.0.0


# curl https://skupper.io/install.sh | sh (install skupper)
# install oc and kubectl as well