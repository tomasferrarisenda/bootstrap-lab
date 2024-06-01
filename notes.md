# STEP BY STEP
1. General overview of task and files
1. Modify for deployment in k8s.
1. Create images, push to dockerhub
1. Create dpl, service, env vars, ingress, etc.
2. Deploy in my k8s env.
1. All green, but is this working? Frontend works fine
1. How is it supposed to work?
1. Go back to task and documentation
1. Test out following README, deploy with docker compose.
1. Java app not showing openapi info in /openapi. Why? log: ```[INFO] [] [fish.payara.microprofile.openapi.impl.rest.app.service.OpenApiResource] [tid: _ThreadID=82 _ThreadName=http-thread-pool::http-listener(1)] [timeMillis: 1717228058120] [levelValue: 800] No OpenAPI document found.```
1. /health showing: ```{"status":"DOWN","checks":[{"name":"No Application deployed","status":"DOWN","data":{}}]}```
1. tried adding this file, didnt work:
```bash
my-app
|-- build.gradle
`-- src
    |-- main
    |   |-- java
    |   `-- resources
    |       `-- microprofile-config.properties
```
```java
mp.openapi.scan.disable=false
```
1. the first problem shoudl be application is down, if its down docuemtns are never going to show.
1. why is it down?
1. After some digging, mariadb logs shows unauthenticated user. api gradle is not connecting to db becuase opf authentication?
```log
[Warning] Aborted connection 3 to db: 'unconnected' user: 'unauthenticated' host: '172.19.0.4' (This connection closed normally without authentication)
```
1. found something commented in persistance.xml file
```xml
      <!-- <property name="javax.persistence.jdbc.url" value="jdbc:mysql://crm_db:3306/apiDB?zeroDateTimeBehavior=CONVERT_TO_NULL"/>
      <property name="javax.persistence.jdbc.user" value="api"/>
      <property name="javax.persistence.jdbc.driver" value="com.mysql.cj.jdbc.Driver"/>
      <property name="javax.persistence.jdbc.password" value="api"/>
```
1. uncommented it, still same unauthenticated error. WHY???
1. changed value of crm_db to something random. Still same error. Values are gotten from somewhere else then. buth where?
NOTE: check mariadb compatibility since image tag is latest
1. ive tried as envs in the docker compuse, but how do I know the java service is using those env vars? how do i know the name of the vars are ok?
1. I removed all env vars in the dockerfile, including the included one DB=crm_db. Still geting error. 
1. installed mysql in apigradle container, connection works fine:
```bash
docker exec -it borrar2-api-gradle-1 sh
# mysql -h crm_db -u api -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 11.4.2-MariaDB-ubu2404 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```
1. api user cant create dbs:
```bash
● docker exec -it borrar2-api-gradle-1 sh
# mysql -h crm_db -u api -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 11.4.2-MariaDB-ubu2404 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE TABLE test_table (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,
    ->     name VARCHAR(255) NOT NULL,
    ->     email VARCHAR(255) NOT NULL
    -> );
ERROR 1046 (3D000): No database selected
MariaDB [(none)]> CREATE DATABASE your_database_name;
ERROR 1044 (42000): Access denied for user 'api'@'%' to database 'your_database_name'
```
1. this works:
```bash
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| apiDB              |
| information_schema |
+--------------------+
2 rows in set (0.021 sec)

MariaDB [(none)]> USE apiDB;
Database changed
MariaDB [apiDB]> CREATE TABLE test_table (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,
    ->     name VARCHAR(255) NOT NULL,
    ->     email VARCHAR(255) NOT NULL
    -> );
Query OK, 0 rows affected (0.064 sec)

MariaDB [apiDB]> SHOW TABLES;
+-----------------+
| Tables_in_apiDB |
+-----------------+
| test_table      |
+-----------------+
1 row in set (0.000 sec)

MariaDB [apiDB]> 
```
1. changed maridb tag, got different error. if this was the issue im gonna throw myself out the window
```bash
[Warning] Access denied for user 'root'@'%' to database 'apiDB'
```
1. I had changed the user in persistence.xml while trying stuff. Now changed it back to api. New error:
```bash
2024-06-02 01:13:53 2024-06-01 23:13:53 3 [ERROR] Error while loading database options: './apiDB/db.opt':
2024-06-02 01:13:53 2024-06-01 23:13:53 3 [ERROR] Unknown collation: 'utf8mb4_uca1400_ai_ci'
```
1. curled http://localhost:8080/health
```bash
{"status":"UP","checks":[{"name":"api","status":"UP","data":{}}]}
```
1. it was the mariadb version.................
1. curl http://localhost:8080/openapi
```bash
openapi: 3.0.0
info:
  title: Api Gradle with Payara
  version: 1.0.0
servers:
- url: http://localhost:8080
  description: "8080"
  variables: {}
paths:
  /api/api/current-user:
    get:
      operationId: getCurrentUserLogin
      responses:
        default:
          content:
            '*/*':
              schema:
                type: string
          description: Default Response.
[...]
```
1. i don't know if im happy about solving it or sad about how much time I wasted
1. need to go back and remove all unnecessary changes which involved, docker networks.. healthchecks.. env vars...


# CI/CD ENVIRONMENT
Cant deploy managed controller from CasC bundle, no time to solve this so when starting "exercise" controller Configuration as Code (CasC) -> Bundle must be None. Well have to manually add al the stuff.

# OPENAPI

the OpenAPI information is automatically exposed at the /openapi endpoint by the MicroProfile OpenAPI implementation. This is a standard feature of MicroProfile OpenAPI and doesn't require any additional configuration.

The @OpenAPIDefinition annotation in your JAXRSConfiguration class is used to provide metadata about your API. The @Info annotation provides the title and version of your API, and the @Server annotation provides the URL and description of your server.

The @ApplicationPath("api") annotation sets the base URI for all resource URIs. This means that your API endpoints will be available under the /api path.

So, if you have a resource class like this:
@Path("/hello")
public class HelloResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "Hello, world!";
    }
}

The hello endpoint will be available at http://localhost:8080/api/hello.