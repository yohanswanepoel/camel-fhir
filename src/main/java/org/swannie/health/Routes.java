package org.swannie.health;

import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;

/**
 * Camel route definitions.
 */
public class Routes extends RouteBuilder {

    private ResponseType response = new ResponseType("Hello World");

    @Override
    public void configure() throws Exception {
        
        onException(Exception.class)
            .handled(true)
            .log(LoggingLevel.ERROR, "Error processing file ${exception.message}")
            .setBody(simple("Boo boo happened"));

        //from("platform-http:/validate")
        from("undertow:http://localhost:8080/validate")
            .routeId("fhir-validation")
            .process(e -> {
                String XMLInput = e.getIn().getBody(String.class);
                e.getIn().setBody(XMLInput);
            })
            // Validate the message and convert to XML - now we can pass it to XML Transform if valid
            .process(new FhirValidationProcessor())
            .choice()
                .when(header("validation-passed").isEqualTo(true))
                    // Pass to XSL transform if message is valid 
                    .log("✅ Valid FHIR message: ${header.fhir-resouce}")
                    .setBody(simple("Valid FHIR message: ${header.fhir-resouce}"))
                .otherwise()
                    .log("❌ Invalid FHIR message: ${header.fhir-resouce}")
                    .log("Error: ${header.validation-error}")
                    .log(body().toString())
                    .setBody(simple("Invalid FHIR message: ${header.fhir-resouce}\n Error: ${header.validation-error}"));
            
        from("undertow:http://localhost:8080/cdaToFhir")
        //from("platform-http:/cdaToFhir")
            .routeId("CDAToFHIRRoute")
            //.to("log:DEBUG?showBody=true&showHeaders=true")
            .process(e -> {
                String XMLInput = e.getIn().getBody(String.class);
                e.getIn().setBody(XMLInput);
            })
            .log(".................................Input.................................")
            .log(body().toString())
            .to("xslt:transform/cda-to-fhir.xsl") // Apply XSLT transformation
            .process(exchange -> {
                // Get the transformed output as a String (XML)
                String xmlOutput = exchange.getIn().getBody(String.class);
                // Strip the XML tags to get the JSON
                // In this case, assuming the output from the XSLT is a valid JSON string
                //String jsonOutput = stripXml(xmlOutput);
                // Set the stripped JSON as the new body
                exchange.getIn().setBody(xmlOutput);
            })
            .log(".................................Output.................................")
            .log(body().toString());
            //.setBody(simple("Hello World"));
            
        /*from("direct:sayHello")
            .routeId("sayHello")
            .log("Message")
            .setBody(simple("Hello World"))
            .log("test");*/
            
    }
    
    
}
