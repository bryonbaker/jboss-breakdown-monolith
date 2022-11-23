# Demo Script

## Part 1
The demonstration starts with a tour of the Java monolith.
<Ben to insert steps here>

## Part 2
The next phase of the demonstration is to refactor the monolith and take out the frontend into a container.
<Ben to insert steps here>

## Part 3
Now we have the monolithic application and the refactored front end. The monolith may still have the front end as part of it (**TODO: Need to discuss with Ben**), but now we want to deploy the front end on OpenShift.

The high-level steps will be:
1. Launch the monolithic application & database (if not already runnning)
2. Create a namespace on the on-premises OpenShift
3. Deploy Application Interconnect into the namespace
4. Deploy an Application Interconnect gateway on the same machine as the monolith
5. Expose the monolith on the RHAI Gateway
6. Deploy the Frontend to OpenShift
7. Demonstrate the applicaytion working from the monolith and via OpenShift.


### Set up the On-Premises OpenShift Environment
