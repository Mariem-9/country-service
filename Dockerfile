# Stage 1: Build the application
FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
VOLUME /tmp
COPY --from=builder /build/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]



# FROM openjdk:21-oracle
# Volume /tmp
# Copy target/*.jar app.jar
# Entrypoint ["java","-jar","/app.jar"]


