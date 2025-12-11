# FROM openjdk:21-oracle
FROM openjdk:17-jdk-slim
Volume /tmp
Copy target/*.jar app.jar
Entrypoint ["java","-jar","/app.jar"]


