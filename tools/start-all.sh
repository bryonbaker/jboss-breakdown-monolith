#! /bin/bash

podman run --rm -d --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgresdb -p 5432:5432 postgres

podman run --rm -d -e POSTGRES_SERVICE_HOST=$(hostname) -e POSTGRES_DB=postgresdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8080:8080 --name backend quay.io/bfarr/jboss-demo-backend

podman run --rm -d -e BACKEND_PROVIDER_URL=remote+http://$(hostname):8080 -p 8180:8080 --name frontend quay.io/bfarr/jboss-demo-frontend
