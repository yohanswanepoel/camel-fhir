
Runnning for dev
```bash
mvn org.springframework.boot:spring-boot-maven-plugin:run
```

Starting FHIR server
```
podman run -p 8090:8080 hapiproject/hapi:latest
```

Building
```bash
mvn clean install
java -jar target/fhir-to-cda-tester-1.0.0-SNAPSHOT.jar --env.xslhost="http://10.215.66.15:5500/api/xsl?name=" --env.fhirhost="http://10.215.66.15:8090/fhir"

```

```bash
 curl -X POST -d '@src/main/resources/inputs/fhir.xml' -H "Content-Type: application/xml" http://localhost:8080/cdaToFhir 

 curl -X POST -d '@src/main/resources/inputs/valid-observation.json' -H "Content-Type: application/json" http://localhost:8080/validate 


  curl -X POST -d '@src/main/resources/inputs/valid-patient.json' -H "Content-Type: application/json" http://localhost:8080/validate 

  curl -X POST -d '@src/main/resources/inputs/invalid-observation.json' -H "Content-Type: application/json" http://localhost:8080/validate 

  curl -X POST -d '{"key1":"value1", "key2":"value2"}' -H "Content-Type: application/xml" http://localhost:8080/hello 
```

## TODO
* container builds
* Hardcoded IP as env.xslhost in application.properties - would like to externalise mores

```bash
podman build . -t f2c-demo-camel
podman run --rm --name f2c-demo-camel -p 8080:8080 -e env.xslhost="http://xslhost/api/xsl?name=" -e env.fhirhost="http://fhirhost:8090/fhir" f2c-demo-camel
```

Building to push to x86 repo
```bash
podman build . -t f2c-demo-camel --platform linux/amd64
```