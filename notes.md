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