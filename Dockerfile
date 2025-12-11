# FROM openjdk:21-oracle
# FROM eclipse-temurin:17-jdk
# Stage 1: Build the JAR
FROM eclipse-temurin:17-jdk-alpine as builder
WORKDIR /app
COPY . .
RUN ./mvnw -q package -DskipTests
# Stage 2: Run the JAR in a tiny image
FROM eclipse-temurin:17-jre-alpine
Volume /tmp
Copy target/*.jar app.jar
Entrypoint ["java","-jar","/app.jar"]


