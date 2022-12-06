# jboss-breakdown-monolith
An example of splitting the monolith to allow independence between layers in deployment and scaling

The example highlights stages of breaking down the the orginal monolith 
1. Original-war-monolith - all code within a single source directory and build into a war file 
2. Modular - code split into seperate projects with a frontend and backend but built into a single deployable ear file
3. Refactored - separate frontend and backend deployable artifacts. The are independently deployable EAR files and the web component uses http remoting to lookup EJBs on the backend.

The intention is to demonstrate Red Hat Application Interconnect in how a monolith running in a VM can be split in components with those components being able to be redeployed where needed.

![Front screen](./docs/images/frontscreen.png)

## Instructions

[Setup instructions](./docs/setup.md)  
[Refactor the Monolith](./docs/demo-script.md)  
[Move the Frontend to OpenShift On-Premises and public cloud](./docs/move-the-frontend.md)  
[Move the Backend to OpenShift On-Premises](./docs/move-the-backend.md)
