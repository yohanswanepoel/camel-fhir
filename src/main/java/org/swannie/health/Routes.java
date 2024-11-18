package org.swannie.health;

import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.rest.RestBindingMode;

import org.springframework.stereotype.Component;

/**
 * A simple Camel REST DSL route.
 */
@Component
public class Routes extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        
        restConfiguration()
				.bindingMode(RestBindingMode.json);

        onException(Exception.class)
            .handled(true)
            .log(LoggingLevel.ERROR, "Error processing file ${exception.message}")
            .setBody(simple("Boo boo happened"));
  
        from("direct:hello")
            .log(LoggingLevel.INFO, "Hello World")
            .transform().simple("Hello World");

        from("platform-http:/dynamicRoute")
            .routeId("dynamicRoute")
            // Need to see if it is a post or get
            // Validate the message and convert to XML - now we can pass it to XML Transform if valid
            .log("Camel Request Type:  ${header.CamelHttpMethod}")
            .choice()
                .when(header("CamelHttpMethod").isEqualTo(("POST")))
                    .log("Running Things")
                    .log(body().toString())
                    .process(new FhirValidationProcessor())
                    .choice()
                        .when(header("validation-passed").isEqualTo(true))
                            // Pass to XSL transform if message is valid 
                            .toD("xslt:http://10.215.66.15:5500/api/xsl?name=${header.fhir-resouce}")
                            .log("✅ Valid FHIR message: ${header.fhir-resouce}")
                            .log(body().toString())
                            //.setBody(simple("Valid FHIR message: ${header.fhir-resouce}"))
                        .otherwise()
                            .log("❌ Invalid FHIR message: ${header.fhir-resouce}")
                            .log("Error: ${header.validation-error}")
                            .log(body().toString())
                            .setBody(simple("Invalid FHIR message: ${header.fhir-resouce}\n Error: ${header.validation-error}"));

        from("platform-http:/validate")
            .routeId("fhir-validation")
            // Need to see if it is a post or get
            // Validate the message and convert to XML - now we can pass it to XML Transform if valid
            .log("Camel Request Type:  ${header.CamelHttpMethod}")
            .choice()
                .when(header("CamelHttpMethod").isEqualTo(("POST")))
                    .log("Running Things")
                    .log(body().toString())
                    .process(new FhirValidationProcessor())
                    .choice()
                        .when(header("validation-passed").isEqualTo(true))
                            // Pass to XSL transform if message is valid 
                            .toD("xslt:transform/f2c-${header.fhir-resouce}.xsl")
                            .log("✅ Valid FHIR message: ${header.fhir-resouce}")
                            .log(body().toString())
                            //.setBody(simple("Valid FHIR message: ${header.fhir-resouce}"))
                        .otherwise()
                            .log("❌ Invalid FHIR message: ${header.fhir-resouce}")
                            .log("Error: ${header.validation-error}")
                            .log(body().toString())
                            .setBody(simple("Invalid FHIR message: ${header.fhir-resouce}\n Error: ${header.validation-error}"));
            
        
    }
    
    
}
