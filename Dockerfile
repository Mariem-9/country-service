# FROM openjdk:21-oracle
# FROM eclipse-temurin:17-jdk
FROM eclipse-temurin:17-jre-alpine

Volume /tmp
Copy target/*.jar app.jar
Entrypoint ["java","-jar","/app.jar"]


