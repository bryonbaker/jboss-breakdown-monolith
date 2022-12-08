# Environment Setup Instructions

## Running on EAP

To demonstrate it running it on a single EAP server in a VM the following steps are required.

1. Download EAP 7.4 Zip file. The ZIP file is located at the following URL: https://developers.redhat.com/products/eap/download
Scroll down to the 7.4.0 release and click **Download** on the Zip file. 

You should now have a place where this is unzipped like so
/jboss-eap-7.4/

2. Build the project
use Java 8 and install Maven
```mvn clean install```  


3. For the Server to run the refactored Backend - JBoss server we will need to setup some configuration 

a. Postgres Driver
In the jboss-eap-7.4/bin directory  
```wget https://jdbc.postgresql.org/download/postgresql-42.5.0.jar```

Start the server in the background  
```./standalone.sh &```

Invoke the CLI and connect to the management console and add the postgressql module and datasource driver  

```./jboss-cli.sh --connect```  

```
module add --name=org.postgresql --resources=postgresql-42.5.0.jar --dependencies=javax.api,javax.transaction.api
```  
Then enter this command:
```
/subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql,driver-module-name=org.postgresql,driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)
```


Now shutdown the server and exit from the CLI  
```shutdown```  
```exit```

4. The standalone.xml now needs to adjust, the following standalone.xml can be used

```./refactored-ear-backend/standalone.xml```
 and copied to the directory /jboss-eap-7.4/standalone/configuration/standalone.xml

The new standalone file has the following snippets added

```xml
<datasource jndi-name="java:jboss/datasources/KitchensinkEarQuickstartPGDS" pool-name="kitchensink-quickstartpg" enabled="true" use-java-context="true">
                    <connection-url>jdbc:postgresql://${env.POSTGRES_SERVICE_HOST}:5432/${env.POSTGRES_DB}</connection-url>
                    <driver>postgresql</driver>
                    <security>
                        <user-name>${env.POSTGRES_USER}</user-name>
                        <password>${env.POSTGRES_PASSWORD}</password>
                    </security>
                </datasource>

```

```xml
    <driver name="postgresql" module="org.postgresql">
        <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>
    </driver>
```

4. Run a containerised postgres on the VM matching the values in the datasource like so
```docker run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 postgres```

5. You can now verify the datasource works by setting the environment variables and starting up JBoss in the foreground like so and see if any errors
export POSTGRES_SERVICE_HOST=localhost
export BACKEND_PROVIDER_URL=remote+http://localhost:8080   
export POSTGRES_DB=postgres
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=mypassword123
/bin/standalone.sh 

Stop JBOSS

6. Add a user that the frontend is using to connect to the backend
/jboss-eap-7.4/bin/add-user.sh -a -u 'jboss' -p 'jboss'

7. Copy the artifacts into the standalone/deployments directory


All dependencies have separated web contexts and can be run in parallel. The original and modular use an in memeory H2 database and not postgres.

```cp ./modular/modular-ear/target/modular-ear.ear ./jboss-eap-7.4/standalone/deployments```  (use http://localhost:8080/obank )
```cp ./original-war-monolith/target/orginal-war-monolith.war ./jboss-eap-7.4/standalone/deployments```  (use http://localhost:8080/ibank )
```cp ./refactored/refactored-ear-backend/target/backend.ear ./jboss-eap-7.4/standalone/deployments```  (use http://localhost:8080/rbank )
```cp ./refactored/refactored-ear-frontend/target/frontend.ear ./jboss-eap-7.4/standalone/deployments``` 

8. Start JBoss

You can now verify it works by starting up JBoss and check the different applications
/bin/standalone.sh 


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
```docker run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 postgres```

3. Build the images - The jboss-eap-7.4.0.zip file is expected to be in the current directory

```./buildcontainers.sh```

4. To run the images for the original  
```docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8100:8080 --name original localhost/jboss-demo-original```

Navigate to http://localhost:8100/obank

5. To run the images for the modular 
```docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8090:8080 --name modular localhost/jboss-demo-modular```

Navigate to http://localhost:8090/mbank

6. To run the images for the refactored

```docker run --rm=true -d --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 postgres```

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
```docker run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 postgres```
```docker run --rm -d -e BACKEND_PROVIDER_URL=remote+http://host.docker.internal:8180 -p 8080:8080 --name frontend quay.io/bfarr/jboss-demo-backend```
```docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8180:8080 --name backend quay.io/bfarr/jboss-demo-backend```

Navigate to http://localhost:8080/rbank


### To demonstrate it running it with Red Hat Application Interconnect and OpenShift



docker run -e POSTGRES_SERVICE_HOST=localhost -e BACKEND_PROVIDER_URL=remote+http://localhost:8080 -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8080:8080 localhost/jboss-monolith 


docker run -e POSTGRES_SERVICE_HOST=host.docker.internal -e BACKEND_PROVIDER_URL=remote+http://localhost:8080 -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8080:8080 localhost/jboss-monolith 



docker run --rm -d --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgres -p 5432:5432 postgres
 docker run --rm -d -e POSTGRES_SERVICE_HOST=host.docker.internal -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -p 8080:8080 --name backend quay.io/bfarr/jboss-demo-backend
 docker run --rm -d -e BACKEND_PROVIDER_URL=remote+http://host.docker.internal:8080 -p 8180:8080 --name frontend quay.io/bfarr/jboss-demo-frontend