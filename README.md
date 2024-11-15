
Runnning for dev
```bash
mvn org.springframework.boot:spring-boot-maven-plugin:run
```

Building
```bash
mvn clean install
java -jar target/fhir-to-cda-tester-1.0.0-SNAPSHOT.jar

```

```bash
 curl -X POST -d '@src/main/resources/inputs/fhir.xml' -H "Content-Type: application/xml" http://localhost:8080/cdaToFhir 

 curl -X POST -d '@src/main/resources/inputs/valid-observation.json' -H "Content-Type: application/json" http://localhost:8080/validate 


  curl -X POST -d '@src/main/resources/inputs/valid-patient.json' -H "Content-Type: application/json" http://localhost:8080/validate 

  curl -X POST -d '@src/main/resources/inputs/invalid-observation.json' -H "Content-Type: application/json" http://localhost:8080/validate 

  curl -X POST -d '{"key1":"value1", "key2":"value2"}' -H "Content-Type: application/xml" http://localhost:8080/hello 
```