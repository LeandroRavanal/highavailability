FROM openjdk:8-jdk-alpine
MAINTAINER Leandro Ravanal <leandro.ravanal@gmail.com>

VOLUME /tmp

ARG JAR_FILE

ADD ${JAR_FILE} highavailability.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/highavailability.jar"]