# FROM openjdk:21-oracle
FROM eclipse-temurin:17-jdk
Volume /tmp
Copy target/*.jar app.jar
Entrypoint ["java","-jar","/app.jar"]


