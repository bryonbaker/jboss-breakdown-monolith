# Partially Migrate the Application Backend to Cloud

In this demonstration we will deploy the backend onto OpenShift on-premises, and decommission the backend application running on the VM.

## High-Level Steps:
1. Deploy the backend to OpenShift
2. Expose the database as a service to the on-premises and Sydney clusters
3. Remove the backend from the Gateway
4. Expose the backend's Deployment to the RHAI network

## Steps

1. Deploy the backend
   ```
   ONPREM: jboss-breakdown-monolith$ oc apply -f ./yaml/backend.yaml 
   Warning: would violate PodSecurity "restricted:v1.24": allowPrivilegeEscalation != false (container "backend" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "backend" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "backend" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "backend" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
   deployment.apps/backend created
   ONPREM: jboss-breakdown-monolith$ 
   ```

2. Expose the database to the network
   ```skupper gateway expose db 127.0.0.1 5432 --type podman```

3. Remove the backend from the gateway
   ```skupper gateway unexpose backend```

4. Expose the backend to the RHAI network
   ```skupper expose deployment backend --port 8080```

5. Demonstrate the application working