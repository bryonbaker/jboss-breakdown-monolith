# jboss-breakdown-monolith
An example of splitting the monolith to allow independence between layers in deployment and scaling


For postgres setup and installing in JBoss EAP 7.4
In the jboss-eap-7.4/bin directory
wget https://jdbc.postgresql.org/download/postgresql-42.5.0.jar

Start JBoss with
/bin/standalone.sh

/bin/jboss-cli.sh
module add --name=org.postgresql --resources=postgresql-42.5.0.jar --dependencies=javax.api,javax.transaction.api

/subsystem=datasources/jdbc-driver=postgres:add(driver-name=postgres,driver-module-name=org.postgresql,driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)

<datasources xmlns="http://www.jboss.org/ironjacamar/schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.jboss.org/ironjacamar/schema http://docs.jboss.org/ironjacamar/schema/datasources_1_0.xsd">
   <!-- The datasource is bound into JNDI at this location. We reference
      this in META-INF/persistence.xml -->
    <datasource jndi-name="java:jboss/datasources/KitchensinkEarQuickstartPGDS" pool-name="kitchensink-quickstartpg"  enabled="true" use-java-context="true">
        <connection-url>jdbc:postgresql://${env.POSTGRESQL_SERVICE_HOST}:${env.POSTGRESQL_SERVICE_PORT}/${env.POSTGRESQL_DATABASE}</connection-url>
        <driver>postgres</driver>
        <security>
            <user-name>${env.POSTGRESQL_USER}</user-name>
            <password>${env.POSTGRESQL_PASSWORD}</password>
        </security>
        <!--
        <validation>
            <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker"></valid-connection-checker>
            <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter"></exception-sorter>
        </validation>
        -->
    </datasource>

</datasources>


/subsystem=ee:write-attribute(name=jboss-descriptor-property-replacement,value=true)
/subsystem=ee:write-attribute(name=spec-descriptor-property-replacement,value=true)

   docker run --rm=true --name pgdb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mypassword123 -e POSTGRES_DB=postgresdb -p 5432:5432 postgres
   
./jboss-cli.sh -c -DPOSTGRESQL_SERVICE_HOST=localhost -DPOSTGRESQL_SERVICE_PORT=5432 -DPOSTGRESQL_DATABASE=postgresdb -DPOSTGRESQL_USER=postgres -DPOSTGRESQL_PASSWORD=mypassword123