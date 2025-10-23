FROM openjdk:21-oracle
Volume /tmp
Copy target/*.jar app.jar
Entrypoint ["java","-jar","/app.jar"]