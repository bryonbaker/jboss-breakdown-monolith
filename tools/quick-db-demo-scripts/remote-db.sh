#Run these commands one by one at this stage
#Use oc or kubectl to login
#oc login ...
# Install skupper in a RHEL 8/9 VM
#curl https://skupper.io/install.sh | sh

oc new-project app-modernisation

skupper init --enable-console --enable-flow-collector --site-name onpremises --console-auth=internal --console-user=admin --console-password=password

oc apply -f https://raw.githubusercontent.com/bfarr-rh/jboss-breakdown-monolith/master/yaml/all.yaml

podman run --rm=true --name pgdb -e POSTGRES_USER=demo -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=demo-db -d -p 5432:5432 docker.io/library/postgres:10

skupper gateway expose db 127.0.0.1 5432 --type podman

# Go to ui

echo "Select * from Registrant" | podman exec -i pgdb psql -U demo -d demo-db

#clean up
skupper gateway delete

rm -rf ~/.local/share/skupper

podman kill --all 

podman system prune --force

oc delete project app-modernisation
