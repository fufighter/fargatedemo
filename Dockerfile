FROM 898649339363.dkr.ecr.us-east-1.amazonaws.com/openjdk:17-jdk-alpine
MAINTAINER stoopid.local
COPY target/dog-1.0.0.jar dog-1.0.0.jar
ENTRYPOINT ["java","-jar","/dog-1.0.0.jar","--server.port=8081"]
