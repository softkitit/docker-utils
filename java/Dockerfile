FROM maven:3.6.1-jdk-8

EXPOSE 80

ENV BASE_DIR /opt/app
ENV DEFAULT_JAR_NAME app.jar
ENV JAR_PATH target/${DEFAULT_JAR_NAME}

ENV SETTINGS_FILE /usr/share/maven/conf/settings.xml

WORKDIR ${BASE_DIR}
ADD pom.xml ${BASE_DIR}
#optional if you have custom settings
#ADD .mvn-settings.xml ${SETTINGS_FILE}
RUN mvn dependency:go-offline -s ${SETTINGS_FILE}

COPY ./ ${BASE_DIR}
#tests will run outside of the docker, change if you want it to be inside
RUN mvn package -s ${SETTINGS_FILE} -Dmaven.test.skip=true

#change it if you
FROM openjdk:8u212-jre-slim

#set approprite profile
ARG DEFAULT_PROFILE=dev
ENV DEFAULT_PROFILE_ENV ${DEFAULT_PROFILE}

ENV BASE_DIR /opt/app
ENV DEFAULT_JAR_NAME app.jar
ENV JAR_PATH target/${DEFAULT_JAR_NAME}

WORKDIR ${BASE_DIR}
COPY --from=0 ${BASE_DIR}/${JAR_PATH} ${BASE_DIR}

# set this
ENV MAIN_CLASS com.softkit.App
ENTRYPOINT exec java -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Dspring.profiles.active=${DEFAULT_PROFILE_ENV} -cp ${BASE_DIR}/${DEFAULT_JAR_NAME} ${MAIN_CLASS}
