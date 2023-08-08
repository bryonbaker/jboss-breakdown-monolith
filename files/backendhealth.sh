#!/bin/bash

echo "Executing Healthcheck"
#Localhost check
java -jar /home/jboss/backendhealthcheck-jar-with-dependencies.jar
error=$?
if [ $error -ne 0 ]; then
exit 1
fi
echo "Finished Executing Healthcheck"
exit 0