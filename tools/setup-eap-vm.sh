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

podman run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgresdb -d -p 5432:5432 docker.io/library/postgres:latest

export POSTGRES_SERVICE_HOST=localhost
export BACKEND_PROVIDER_URL=remote+http://localhost:8080
export POSTGRES_DB=postgresdb
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=mypassword123

$JBOSS_HOME/bin/standalone.sh -b 0.0.0.0