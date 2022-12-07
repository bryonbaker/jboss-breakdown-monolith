#! /bin/bash

JBOSS_HOME=../../jboss-eap-7.4

cp ../original-monolith/original-ear/target/obank.ear $JBOSS_HOME/standalone/deployments
cp ../modular/modular-ear/target/modular-ear.ear $JBOSS_HOME/standalone/deployments
cp ../refactored/refactored-ear-frontend/target/frontend.ear $JBOSS_HOME/standalone/deployments
cp ../refactored/refactored-ear-backend/target/backend.ear $JBOSS_HOME/standalone/deployments

podman run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgresdb -d -p 5432:5432 docker.io/library/postgres:latest

export POSTGRES_SERVICE_HOST=localhost
export BACKEND_PROVIDER_URL=remote+http://localhost:8080
export POSTGRES_DB=postgresdb
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=mypassword123

../../jboss-eap-7.4/bin/standalone.sh