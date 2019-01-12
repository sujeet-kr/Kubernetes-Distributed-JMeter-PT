FROM openjdk:8-jre-slim
MAINTAINER Sujeet Kumar <sujeet.kr@hotmail.com>
		
ARG JMETER_VERSION=5.0
		
RUN apt-get clean && \
    apt-get update && \
    apt-get -qy install \
                wget \
                telnet \
                iputils-ping \
                unzip

RUN mkdir /jmeter \
    && cd /jmeter/ \
    && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz \
    && tar -xzf apache-jmeter-$JMETER_VERSION.tgz \
    && rm apache-jmeter-$JMETER_VERSION.tgz
		
		
ADD jmeter-plugins/lib /jmeter/apache-jmeter-$JMETER_VERSION/lib

# ADD tests-directory tests-directory
		
ENV JMETER_HOME /jmeter/apache-jmeter-$JMETER_VERSION
		
ENV PATH $JMETER_HOME/bin:$PATH