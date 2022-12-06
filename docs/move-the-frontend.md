# Move the Front End to OpenShift On-Premises

This demo script shows how to launch the Refactored monolith and deploy the frontend on the on-premises OpenShift.  

**Note 1:** This demonstration works with both Docker and Podman. The steps in these instructions will refer to Podman. Simply replace ```podman``` for ```docker``` and the commands remain the same.


**Note 2:** Unless specifically described otherwise, all commands in this script are relative to the root directory of the Git repository.

## Environment Summary

This demonstration has been tested using:
1. macOS ```<insert version number>``` and Fedora Linux 36.
2. Docker or Podman to run the "on-premises" database and monolithic backend.
3. OpenShift Local to run the frontend.
4. Application Interconnect (Skupper) to provide the connectivity between the frontend and the monolith running in a container.

### Preconditions:  
1. The demo repository (https://github.com/bfarr-rh/jboss-breakdown-monolith) has been cloned to the demonstration machine.
2. You have the latest container images for the demonstration:
   ```
   $ podman pull quay.io/bfarr/jboss-demo-frontend
   $ podman pull quay.io/bfarr/jboss-demo-backend
   $ podman pull docker.io/library/postgress:latest
    ```  
**TODO:** Change this for Postgress from Red Hat Congtainer Catalog.

## High-Level Summary of Demonstration

1. Install RHAI.
2. Start OpenShift Local
3. Start the database and Backend components
4. Set up the OpenShift Project Environment
5. Install RHAI in the namespace
6. Create an RHAI Gateway to expose the Backend to the Frontend's namespace.
7. Deploy the Frontend to OpenShift
8. Demonstrate the Appication
9. Examine the RHAI network in the Admin COnsole

## Initial Setup

### Install Red Hat Application Interconnect on the demo machine

1. Download and install RHAI using the instructions located at: https://skupper.io/releases/index.html

### Start OpenShift Local

1. Open a new terminal window and start OpenSHift Local:  
```crc start```

### Start the Database and Backend Application

1. Ensure a clean container environment by deleting all running containers:  
```podman kill --all```  
The system stops all running containers.
    ```
    $ podman kill --all
    7290f08ad7572a37fec8c2538ee0f43b98d115e9105bac2fec79e83d671d277b
    a68ccebf827af96b227c9bdd79c1e75cb652693113dd6ee30d7ca1cb058a78f6
    c462586b7101af6b430ae287e055eb53f0bc85b0bb58143823df73642d49887e
    ```

2. Start the containers used in this demonstration:  
   ```./tools/start-all.sh```  
   The system starts the database, backend, and refactored frontend containers.  

   **Note:** While the Frontend is not necessary for this demonstration, having it running as a container is a useful way to demonstrate the frontend and backend running on the same host. You can also use this to shake out the backend and database to make sure they are working.

   ```
   $ ./tools/start-all.sh 
   Checking for container runtime...
   Podman is installed
   5d2724f6f3d2c9cdd1c7f733eef23132b12e3751e9304b5e55d33fcd6e5cd0ce
   1d16a407b2b9a56e7fc82d768abe4f00bd89a7661f89ff187839f0961b346541
   1ab6ba81df4e5ffee7d5fb312c6a15cb10f9738ce6488d080eb71e86ab45b0f6
    ```

## Start of Demonstration
The story starts with a tour of the application running on the host machine.

1. Demonstrate how the refactored application is running on a single host machine.
   Type ```podman ps``` in a terminal window  
   ```
   $ podman ps
   CONTAINER ID  IMAGE                                     COMMAND               CREATED         STATUS             PORTS                   NAMES
   3ef007bee8db  docker.io/library/postgres:latest         postgres              11 minutes ago  Up 12 minutes ago  0.0.0.0:5432->5432/tcp  pgdb
   1d87d76cd837  quay.io/bfarr/jboss-demo-backend:latest   /home/jboss/jboss...  11 minutes ago  Up 12 minutes ago  0.0.0.0:8080->8080/tcp  backend
   20e90eae5cc7  quay.io/bfarr/jboss-demo-frontend:latest  /home/jboss/jboss...  11 minutes ago  Up 12 minutes ago  0.0.0.0:8180->8080/tcp  frontend
   ``` 
   Observe the database, backend and frontend components all running on the same host. In this case thery are in three containers, but the front and back ends could equally be all running on the same app server.

2. Demonstrate the application running on the demo host machine uing the url:  
   Open a browser and navigate to the following url: http://localhost:8180/rbank  
   The system will display the app's main screen 
   ![Front screen](./images/frontscreen.png)  

   Test the app by creating a booking and then view the queue by clicking **View Queue.**

### Set up the OpenShift Project Environment
The next phase of the demonstration will create a new OpenShift project to host the application

1. Open a new Terminal window and change into the project directory.  
2. Set up the On-Premises OpenShift environment:  
   ```. ./tools/setup-onprem-k8s-env.sh```  
   The system will create a new shell and isolated Kubernetes environment for you to work in.  
   ```
   $ . ./tools/setup-onprem-k8s-env.sh 
   Setting up isolated Kubernetes environment in: /home/username/.kube/app-modernisation-onprem

   ONPREM: jboss-breakdown-monolith$ 
   ```  
   The system sets up a new Kubernetes environment and updates the system prompt to indicate which environment you  are working in. **Pay special attention to this prompt** as you start working with multiple clusters. This prompt tells you which cluster you are working in.

3. Log on to the ONPREM cluster:  
   ```oc login -u developer  https://api.crc.testing:6443 ```
   **Note:** Substitute the username ```developer``` for the username you are using.

4. Create a project for the demonstration  
   ```oc new-project app-modernisation```  
   The system creates a new OpenShift project

   ```
   ONPREM: jboss-breakdown-monolith$ oc login -u developer https://api.crc.testing:6443 
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.

   You have access to the following projects and can switch between them with 'oc project <projectname>':

     * default

   Using project "default".
   ```

5. Create the project for the demonstration:  
   ```oc new-project app-modernisation```

   The system crete a new project for the demonstration:
   ```
   ONPREM: jboss-breakdown-monolith$ oc new-project app-modernisation
   Now using project "app-modernisation" on server "https://api.crc.testing:6443".

   You can add applications to this project with the 'new-app' command. For example, try:

       oc new-app rails-postgresql-example

   to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

       kubectl create deployment hello-node --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 -- /agnhost serve-hostname

   ```

### Install RHAI into the OpenShift project
Now we have a new project, install Application Interconnect

1. Install RHAI into the project:  
```skupper init --site-name local --console-auth=internal --console-user=admin --console-password=password```

The system installes RHAI and assignes the username and password for the administrator console.

2. Check the install status of RHAI. Wait until all pods are Running:  
```watch oc get svc,pods```

   ```
   Every 2.0s: oc get svc,pods                                                       rh-brbaker: Fri Nov 25 15:36:10 2022

   NAME                           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)               AGE
   service/skupper                ClusterIP   10.217.4.49    <none>        8080/TCP,8081/TCP     44s
   service/skupper-router         ClusterIP   10.217.5.159   <none>        55671/TCP,45671/TCP   46s
   service/skupper-router-local   ClusterIP   10.217.4.111   <none>        5671/TCP              46s

   NAME                                            READY   STATUS    RESTARTS   AGE
   pod/skupper-router-f85775498-n2ddd              2/2     Running   0          46s
   pod/skupper-service-controller-55876c99-9m8mr   1/1     Running   0          44s
   ```

### Open the RHAI Admin Console
Demonstrate the Admin console

1. Get the url for the console  
   Type ```oc get route/skupper``` and press Enter.
   OpenShift displays the route details
   ```
   $ oc get route/skupper
   NAME      HOST/PORT                                    PATH   SERVICES   PORT      TERMINATION          WILDCARD
   skupper   skupper-app-modernisation.apps-crc.testing          skupper    metrics   reencrypt/Redirect   None
   ```
2. Copy the HOST/PORT and paste it into a browser. Accept any https warnings.
3. When prompted, enter the username/password combination as: ```admin/password```  
   RHAI displays the admin console.  
   ![RHAI Console](./images/rhai-console-1.png)  

### Create an RHAI Gateway to expose the Backend

This section will create a Gateway on the same machine that the Backend is running. The Gateway will be configured to expose the Backend application as one or more services on OpenShift. This will enable any app running on OpenShift to access the backend as though it is a local service.

1. Install the Gateway   
   ```skupper gateway expose backend 127.0.0.1 8080 --type podman```

   ```
   $ skupper gateway expose backend 127.0.0.1 8080 --type podman
   2022/11/25 15:41:15 CREATE io.skupper.router.tcpConnector rh-brbaker-bryon-egress-backend:8080 map[address:backend:8080 host:127.0.0.1 name:rh-brbaker-bryon-egress-backend:8080 port:8080 siteId:ed553929-9e58-484e-9a9a-898fcf7c3e51
   ```

   The system installs the Gateway and publishes the backend as a service on OpenShift.

2. Open the RHAI Console and observe the change in topology  
   ![RHAI Console](./images/rhai-console-2.png)  

3. Show how the service is available on OPenShift, but there are no deployments or pods for the backend.  
   Type ```oc get svc,pods``` and press **Enter**  

   ```
   $ oc get svc,pods
   NAME                           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)               AGE
   service/backend                ClusterIP   10.217.4.236   <none>        8080/TCP              106s
   service/skupper                ClusterIP   10.217.4.49    <none>        8080/TCP,8081/TCP     7m26s
   service/skupper-router         ClusterIP   10.217.5.159   <none>        55671/TCP,45671/TCP   7m28s
   service/skupper-router-local   ClusterIP   10.217.4.111   <none>        5671/TCP              7m28s

   NAME                                            READY   STATUS    RESTARTS   AGE
   pod/skupper-router-f85775498-n2ddd              2/2     Running   0          7m28s
   pod/skupper-service-controller-55876c99-9m8mr   1/1     Running   0          7m26s
   ```

   Observe that the backend is available as a service, but there are no pods running for it.

4. Show how the service's implementation is the RHAI router.  
   Type ```oc get svc/backend -o yaml``` and press **Enter**
   ```
   $ oc get svc/backend -o yaml
    apiVersion: v1
    kind: Service
    metadata:
    annotations:
        internal.skupper.io/controlled: "true"
    creationTimestamp: "2022-11-25T04:41:06Z"
    labels:
        internal.skupper.io/gateway: rh-brbaker-bryon
    name: backend
    namespace: app-modernisation
    ownerReferences:
    - apiVersion: apps/v1
        kind: Deployment
        name: skupper-router
        uid: 0d8fe133-01df-43cb-8db9-9af957d63725
    resourceVersion: "60483"
    uid: c3587027-a78b-4532-9632-9285855e5a40
    spec:
    clusterIP: 10.217.4.236
    clusterIPs:
    - 10.217.4.236
    internalTrafficPolicy: Cluster
    ipFamilies:
    - IPv4
    ipFamilyPolicy: SingleStack
    ports:
    - name: port8080
        port: 8080
        protocol: TCP
        targetPort: 1024
    selector:
        application: skupper-router
        skupper.io/component: router
    sessionAffinity: None
    type: ClusterIP
    status:
    loadBalancer: {}
   ```
   Observe the ```annotations``` and the ```selector``` attributes are pointing the service to the RHAI router. This is what enables RHAI to intercept calls to the service and send them out over the router.

5. View the RHAI Network Status  
   ```skupper network status```  

   ```
   $ skupper network status
    Sites:
    ╰─ [local] 6d18150 - local 
    mode: interior
    name: local
    namespace: app-modernisation
    version: 1.2.0
    ╰─ Services:
        ╰─ name: backend
            address: backend: 8080
            protocol: tcp
   ```

   The system displays the services that have been published in OpenShift to the RHAI mesh network, and the port they are accessed via.

6. View the RHAI Gateway status
   ```skupper gateway status```

   ```
   $ skupper gateway status
     Gateway Definition:
     ╰─ rh-brbaker-bryon type:podman  
     version:2.2.0
     ╰─ Bindings:
        ╰─ backend:8080 tcp backend:8080 127.0.0.1 8080
   ```
   The system shows how the backend service is bound to an ip address and port on the virtual machine.

### Deploy the Frontend to OpenShift
Now that we have made the backend available to OpenShift we are able to deploy the frontend and have it seamlessly connect to ther backend. Highlight how this is being done without the need to create DNS entries. This is a perfect example of how, when breaking something apart, you need to do this with the internal referencdes and not convert everything to DNS.

1. Deploy the Frontend to OpenShift on premises
   ```oc apply -f ./yaml/frontend.yaml```  
   **Note:** Ignore any Warning regarding violation of PodSecurity.
   ```
   $ oc apply -f ./yaml/frontend.yaml 

   deployment.apps/frontend created
   service/frontend created
   route.route.openshift.io/frontend created
   ```

### Demonstrate the Appication
1. Find the route to the Frontend  
   ```oc get route/frontend```

   ```
   $ oc get route/frontend
   NAME       HOST/PORT                                     PATH   SERVICES   PORT   TERMINATION   WILDCARD
   frontend   frontend-app-modernisation.apps-crc.testing          frontend   8080                 None
   ```

2. Copy the url to the Clipboard
   ```frontend-app-modernisation.apps-crc.testing```

3. Open a browser and paste the url into the address box and append the following to the url and press **Enter**: ```/rbank```  
   I.e. ```http://frontend-app-modernisation.apps-crc.testing/rbank```

   The system displays the main App window.  
   ![Front screen](./images/frontscreen.png)  

4. Create a booking and test the data is persisted.

### Examine the RHAI Network in the Admin Console

1. Find the url for the admin Console:
   ```oc get route/skupper```

   ```
   $ oc get route/skupper
   NAME      HOST/PORT                                    PATH   SERVICES   PORT      TERMINATION          WILDCARD
   skupper   skupper-app-modernisation.apps-crc.testing          skupper    metrics   reencrypt/Redirect   None
   ```

2. Open a new tab on a Browser and paste the route into the address box of your Browser.  
   RHAI prompts you for the username and password.

3. Enter a username/password of ```admin/password```
   RHAI displays the admin console.

4. Browse the different perspectives to view the services and topology:

![Admin Console 1](./images/admin-console1.png)  
![Admin Console 2](./images/admin-console2.png)  
![Admin Console 3](./images/admin-console3.png)  

### Summary
In this part of the demonstration we have taken a refactored monolith and moved part of it to OpenShift. We did this without the application being aware that it had been factored out or moved.

In the next step we will take the frontend out to the public cloud.

## Install RHAI in the public cloud

1. Open a new terminal window
2. Create a new OpenShift isolated environment.  
   Type: ```. ./tools/setup-sydney-k8s-env.sh``` and press **Enter**  
   ```
   $ . ./tools/setup-sydney-k8s-env.sh 
   Setting up isolated Kubernetes environment in: /home/bryon/.kube/app-modernisation-sydney
   NOTE: The command format to run this script is: ". ./tools/setup-sydney-k8s-env.sh"
   SYDNEY: jboss-breakdown-monolith$
   ```
   Observe the prompt indicates you are using the Sydney cluster

3. Create the application namespace  
   Type ```oc new-project app-modernisation``` and press **Enter**  
   OpenShift creates the new project.  

4. Install RHAI
   ```skupper init --site-name sydney --console-auth=internal --console-user=admin --console-password=password```  
   Skupper is installed in the project.  
   At this point skupper is installed, but the mesh network is not established.

5. Connect the sites
   At the SYDNEY site, type:  
   ```skupper token create --token-type cert sydney-token.yaml```  
   and press **Enter**
   ```
   SYDNEY: jboss-breakdown-monolith$ skupper token create --token-type cert sydney-token.yaml
   Connection token written to sydney-token.yaml 
   SYDNEY: jboss-breakdown-monolith$
   ```

6. Import the token at the on-premises OpenShift  
   Open the ON-PREM terminal, type the following command:
   ```
   skupper link create sydney-token.yaml
   ```
   and press **Enter**
   ```
   ONPREM: jboss-breakdown-monolith$ skupper link create sydney-token.yaml
   Site configured to link to skupper-inter-router-app-modernisation.apps.cluster-2k5sp.2k5sp.sandbox1764.opentlc.com:443 (name=link1)
   Check the status of the link using 'skupper link status'.
   ONPREM: jboss-breakdown-monolith$ 
   ```

7. View the network status.  
   Type: ```skupper network status``` and press **Enter**  
   ```
   **REVISIT**
   ```

8. Examine the workloads at the SYDNEY cluster
   Type ```oc get svc,pods``` and press **Enter**  
   ```
   SYDNEY: jboss-breakdown-monolith$ oc get svc,pods
   NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
   service/backend                ClusterIP   172.30.234.59    <none>        8080/TCP              115s
   service/skupper                ClusterIP   172.30.56.78     <none>        8080/TCP,8081/TCP     8m27s
   service/skupper-router         ClusterIP   172.30.89.142    <none>        55671/TCP,45671/TCP   8m32s
   service/skupper-router-local   ClusterIP   172.30.156.196   <none>        5671/TCP              8m32s

   NAME                                              READY   STATUS    RESTARTS   AGE
   pod/skupper-router-b45dc66d9-vkbhk                2/2     Running   0          8m30s
   pod/skupper-service-controller-84c9c7d857-txnbg   1/1     Running   0          8m25s
   SYDNEY: jboss-breakdown-monolith$
   ```
   Observe that the backend is available as a service in SYDNEY, but there are no pods deployed. Application Interconnect has made the on-premises backend application available as a service in every location that is part of the application's mesh network.

9. Continue the progressive migration by deploying the frontend application to SYDNEY.
   Type ```oc apply -f ./yaml/frontend.yaml``` and press **Enter**
   ```
   SYDNEY: jboss-breakdown-monolith$ oc apply -f ./yaml/frontend.yaml 
   deployment.apps/frontend created
   service/frontend created
   route.route.openshift.io/frontend created
   SYDNEY: jboss-breakdown-monolith$
   ```

10. Open the frontend from the SYDNEY cluster.
    Get the url of the frontend: ```oc get route/frontend''' and press **Enter**
    ```
    SYDNEY: jboss-breakdown-monolith$ oc get route/frontend
    NAME       HOST/PORT                                                                     PATH   SERVICES   PORT   TERMINATION   WILDCARD
    frontend   frontend-app-modernisation.apps.cluster-2k5sp.2k5sp.sandbox1764.opentlc.com          frontend   8080                 None
    SYDNEY: jboss-breakdown-monolith$ 
    ```

11. Copy the url and paste it in a browser. Append the ```/rbank```. E.g.:  
    ```http://frontend-app-modernisation.apps.cluster-2k5sp.2k5sp.sandbox1764.opentlc.com/rbank```
    The application is started from the SYDNEY cluster.
    View the queue to demonstrate how it is accessing the backend and database on-premises.