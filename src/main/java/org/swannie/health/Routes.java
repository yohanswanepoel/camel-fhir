package org.swannie.health;

import org.apache.camel.Exchange;
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
            .setBody(simple("Error processing file ${exception.message}"));

        from("platform-http:/queryFHIRfromCDA/{object}/{id}")
            .routeId("getMessage")
            .log("get CDA return FHIR ${header.object} / ${header.id}")
            .setHeader(Exchange.HTTP_METHOD, constant("GET"))
            .choice()
                .when(simple("${header.X-get-from} == 'cda'"))
                    .toD("{{env.cdahost}}/${header.id}?bridgeEndpoint=true")
                    .log(body().toString())
                    .toD("xslt:{{env.xslhost}}${header.object}&direction=c2f")
                    .log(body().toString())
                .when(simple("${header.X-get-from} == 'fhir'"))
                    .toD("{{env.fhirhost}}/${header.object}/${header.id}?bridgeEndpoint=true")
                    .log(body().toString())
            .endChoice()
        .end();

        from("platform-http:/dynamicRoute")
            .routeId("dynamicRoute")
            //.log("Camel Route to FHIR: ${header.CamelHttpQuery}")
            // USEFUL FOR DEBUGGING 
            // .log("Header... ${headers}")
            .choice()
                .when(header("CamelHttpMethod").isEqualTo(("POST")))
                    .log("Running Things")
                    .process(new FhirValidationProcessor())
                    .setProperty("XML_Body", body())
                    .choice()
                        .when(header("validation-passed").isEqualTo(true))
                            .choice()
                                .when(simple("${header.toFHIR} == 'Y'"))
                                // Send message to FHIR
                                    .convertBodyTo(String.class)
                                    .toD("fhir://create/resource?inBody=resourceAsString&encoding=XML&serverUrl={{env.fhirhost}}&fhirVersion={{env.fhirVersion}}")
                                    // log the outcome
                                    .log("${header.fhir-resouce} created successfully: ${body}")
                                    .setProperty("FHIR_Response", body())
                                    .setHeader("fhir_updated",constant("yes"))
                            .endChoice()
                            // Pass to XSL transform if message is valid 
                            .setBody(exchangeProperty("XML_Body"))
                            .toD("xslt:{{env.xslhost}}${header.fhir-resouce}&direction=f2c")
                            .setHeader("message_transformed",constant("yes"))
                            // Send the CDA message back to CDA service
                            .log("Sending to CDA endpoint")
                            .setHeader(Exchange.HTTP_METHOD, constant("POST"))
                            .toD("{{env.cdahost}}?bridgeEndpoint=true")
                            .setHeader("message_stored_cda",constant("yes"))
                            .setBody(exchangeProperty("XML_Body"))
                            .log("Valid FHIR message: ${header.fhir-resouce}")
                            //.log(body().toString())
                            .setBody(simple("FHIR Server Create Success: ${exchangeProperty.FHIR_Response}!\\n\\n ${body} "))
                            //.setBody(simple("Valid FHIR message: ${header.fhir-resouce}"))
                    .otherwise()
                        .log("Invalid FHIR message: ${header.fhir-resouce}")
                        .log("Error: ${header.validation-error}")
                        .log(body().toString())
                        .setBody(simple("(Validation Failed) - Invalid FHIR message: ${header.fhir-resouce}\n Error: ${header.validation-error}"))
                    .endChoice()
            .endChoice();

        
            
        
    }
    
    
}
