FROM registry.access.redhat.com/ubi8/openjdk-8:1.14-5.1666624658

USER root
WORKDIR /home/jboss
RUN microdnf update
RUN microdnf install unzip

COPY jboss-eap-7.4.0.zip ./jboss-eap-7.4.0.zip

USER jboss
RUN unzip jboss-eap-7.4.0.zip
RUN chgrp -R 0 /home/jboss/jboss-eap-7.4 && chmod -R g=u /home/jboss/jboss-eap-7.4
WORKDIR /home/jboss/jboss-eap-7.4
COPY ./target/orginal-war-monolith.war /home/jboss/jboss-eap-7.4/standalone/deployments/orginal-war-monolith.war

EXPOSE 8080
CMD ["/home/jboss/jboss-eap-7.4/bin/standalone.sh","-b","0.0.0.0"]