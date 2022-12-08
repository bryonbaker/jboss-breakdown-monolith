# Environment Setup Instructions

## Running on EAP

On a VM or your laptop the following will be required and available on the PATH

- Maven - ```sudo yum install maven```
- Java 8 or 11
- Skupper ```curl https://skupper.io/install.sh | sh```
- oc cli tool available from the OpenShift cluster 
- kubectl  - i.e. ```curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"```

To demonstrate it running it on a single EAP server in a VM the following steps are required.

1. Download EAP 7.4 Zip file. The ZIP file is located at the following URL: https://developers.redhat.com/products/eap/download
Scroll down to the 7.4.0 release and click **Download** on the Zip file. 

You should now have a place where this is unzipped like so
/jboss-eap-7.4/

2. Git Clone this project and build it
```mvn clean install```  

3. Run the script under tools to deploy and launch JBOSS EAP with all builds and a postgres DB running in a container , adjust the JBOSS_HOME if required
- ```cd tools```
- ```./setup-eap-vm.sh```

4. To shutdown the server in foreground press CTRL-C or if running in the background the JBOSS cli can be used to connect to the instance and shut it down.

```$JBOSS_HOME/bin/jboss-cli.sh --connect```  
```shutdown```  
```exit```

5. All dependencies have separated web contexts and can be run in parallel. The original and modular use an in memeory H2 database and not postgres.
Navigate to the following
- Original Code - http://localhost:8080/obank
- Modular Code - http://localhost:8080/mbank
- Refactored Code - http://localhost:8080/rbank

##To demonstrate it running it on mulitple EAP servers in a single VM the following steps are required.

1. Install a secondary JBOSS by unzipping into a different directory

2. Copy the frontend into the deployment directory

```cp ./refactored/refactored-ear-frontend/target/frontend.ear ./jboss-eap-7.4/standalone/deployments``` 
3. Set the following environment variable and direct it to the machine name where the backend is running
export BACKEND_PROVIDER_URL=remote+http://localhost:8080

4. Start the server with an offset if on the same machine 
```./standalone.sh -Djboss.socket.binding.port-offset=100 &```

5. Launch the frontend on the new EAP server
http://localhost:8180/rbank


## Running the Application in Containers

There are three containers that have been provided:
1. Postgres database
2. Application backend
3. Application frontend.

To run all the containers enter the following command in a Bash shell:
```
$ ./tools/start-all.sh 

Checking for container runtime...
Podman is installed
0a57b4233360797cc75956ad7959bfa2021ab97d3c8836238bcab5401ca7d374
794c9c2380db416d5968efab520d6836101b64ff493b9ba8df55a76f221e304c
38a53662803b497bddc63b03fca87e3b496e86357303e5d8bc4aa75b22cbe395
```

Note: The script detects both Docker and Podman and will launch the container with whicheverr is installed.

### Rebuilding the Container Images
Container or Dockerfiles have been provided and images are pre built and accessible. To rebuild images locally:  
1. Ensure you have built all the artifacts with an mvn clean install

2. Run a containerised postgres on the VM matching the values in the datasource like so
```docker run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 docker.io/library/postgres:10```

3. Build the images - The jboss-eap-7.4.0.zip file is expected to be in the current directory

```./buildcontainers.sh```

4. To run the images for the original  
```docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8100:8080 --name original localhost/jboss-demo-original```

Navigate to http://localhost:8100/obank

5. To run the images for the modular 
```docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8090:8080 --name modular localhost/jboss-demo-modular```

Navigate to http://localhost:8090/mbank

6. To run the images for the refactored

```docker run --rm=true -d --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 docker.io/library/postgres:10```

```docker run --rm -d -e BACKEND_PROVIDER_URL=remote+http://host.docker.internal:8180 -p 8080:8080 --name frontend localhost/jboss-demo-frontend```

```docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8180:8080 --name backend localhost/jboss-demo-backend```

Navigate to http://localhost:8080/rbank

### To demonstrate it running it in pre built Containers

1. To run the images for the original  
```docker run --rm -d -p 8100:8080 --name original quay.io/bfarr/jboss-demo-original```
Navigate to http://localhost:8100/obank

2. To run the images for the modular 
```docker run --rm -d -p 8090:8080 --name modular quay.io/bfarr/jboss-demo-modular```

Navigate to http://localhost:8090/ibank

3. To run the images for the refactored
```docker run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 docker.io/library/postgres:10```
```docker run --rm -d -e BACKEND_PROVIDER_URL=remote+http://host.docker.internal:8180 -p 8080:8080 --name frontend quay.io/bfarr/jboss-demo-backend```
```docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8180:8080 --name backend quay.io/bfarr/jboss-demo-backend```

Navigate to http://localhost:8080/rbank


## To demonstrate a progressive migration with Red Hat Application Interconnect and OpenShift

### DEMONSTRATE Current State
1. Run the refactored code builds Frontend/Backend/Postgres to run in a VM OR in containers as described above.


### REPLATFORM the FRONTEND
2. Create a new project in OpenShift and login with oc or kubectl
3. Initialise skupper in the environment
```skupper init --site-name mycloud  --console-auth=internal --console-user=admin --console-password=password```
4. Initialise the gateway on the VM and expose the running EAP service or Backend service (adjust port as required)
```skupper gateway init --type podman```
```skupper gateway expose backend 127.0.0.1:8080 --type podman```
5. Deploy the frontend on OpenShift
```oc apply -f ./yaml/frontend.yaml```
6. Navigate to the Frontend Route and it should connect to the backend. Demonstrate by looking at the queue in both frontends in the VM and OpenShift. 

### REPLATFORM the BACKEND
7. Remove the backend from skupper gateway - (the frontend on OCP will currently not work)
```skupper gateway unbind backend```
```skupper gateway unexpose backend```
8. Expose the Database via the gateway
```skupper gateway expose db 127.0.0.1 5432 --type podman```
9. Deploy the backend on OpenShift
```oc apply -f ./yaml/backend.yaml```
10. Launch the frontend route on OpenShift again, this time it should talk to the backend on OpenShift and the backend will communicate to the database on the VM.

### REPLATFORM the DATABASE and MIGRATE
The final step is we can run the database on OpenShift and migrate the data to the new container

11. Create a new postgres database in the OpenShift project
```oc new-app postgresql-ephemeral --name dbcloud --param DATABASE_SERVICE_NAME=dbcloud --param POSTGRESQL_DATABASE=postgres --param POSTGRESQL_USER=postgres --param POSTGRESQL_PASSWORD=mypassword123```
12. Once the pod is running rsh into the pod
```oc rsh <pod_name>```
13. Migrate the data and schema from our postgres in the VM which is still attached via the skupper gateway. Within the remote shell of the postgres pod dbcloud
```pg_dump postgresql://postgres:mypassword123@db:5432/postgres | PGPASSWORD=mypassword123 psql -h dbcloud -p 5432 -U postgres postgres```
```exit```
14. We now can switch the backend to point to the new database in the cloud. This will restart the backend, the frontend doesn't need to be restarted.
```oc set env deployment/backend POSTGRES_SERVICE_HOST=dbcloud```

15. You can now unbind the VM based database via the gateway
```skupper gateway unbind db```
```skupper gateway unexpose db```

16. Demonstrate how both the refactored and original are now using independent databases by adding a new value to the Queue and observing it doesnt appear on the other.
