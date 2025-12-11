# FROM openjdk:21-oracle
FROM openjdk:21-jdk-alpine
Volume /tmp
Copy target/*.jar app.jar
Entrypoint ["java","-jar","/app.jar"]
