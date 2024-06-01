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
1. Java app not showing openapi info in /openapi. Why?
1. /health showing: ```{"status":"DOWN","checks":[{"name":"No Application deployed","status":"DOWN","data":{}}]}```

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