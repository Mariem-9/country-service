# FROM openjdk:21-oracle
# Volume /tmp
# Copy target/*.jar app.jar
# Entrypoint ["java","-jar","/app.jar"]

FROM openjdk:21

VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]

