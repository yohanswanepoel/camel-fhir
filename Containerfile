# Build stage
FROM fedora:41 as builder

# Install build dependencies
RUN dnf update -y && \
    dnf install -y java-21-openjdk-devel maven && \
    dnf clean all

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk

# Create and set working directory
WORKDIR /app

# Copy pom.xml first to leverage Docker cache
COPY pom.xml .
COPY src src/

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage
FROM fedora:latest

# Install runtime dependencies only
RUN dnf update -y && \
    dnf install -y java-21-openjdk-headless && \
    dnf clean all

# Set JAVA_HOME and default environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk \
    JAVA_OPTS="-Xms512m -Xmx512m --enable-preview" \
    env_xslhost="http://xslhost:5500/api/xsl?name=" \
    env_fhirhost="http://fhirhost:8080/fhir" \
    env_cdahost="http://cdahost:5500/cda_system"

# Create user with ID 1001 for OpenShift compatibility
RUN useradd -m -r -u 1001 cameluser

# Create app directory
WORKDIR /app

# Copy the JAR file from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Set ownership and permissions for OpenShift
RUN chown -R 1001:0 /app && \
    chmod -R g+rwX /app

# Switch to non-root user
USER 1001

# Expose port (adjust if needed)
EXPOSE 8080

# Command to run the application with environment variables
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS \
    -Denv.xslhost=\"$env_xslhost\" \
    -Denv.fhirhost=\"$env_fhirhost\" \
    -Denv.cdahost=\"$env_cdahost\" \
    -jar app.jar"]