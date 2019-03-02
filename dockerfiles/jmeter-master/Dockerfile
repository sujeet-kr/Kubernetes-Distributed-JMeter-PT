FROM jmeter-base:latest
MAINTAINER Sujeet Kumar <sujeet.kr@hotmail.com>

EXPOSE 60000

#Install Pip - which is required by Taurus
RUN apt-get update && apt-get install -y \
    python-pip

#RUN pip install
RUN pip install bzt

#Copy bzt-rc file for taurus system settings
ADD .bzt-rc /root/.bzt-rc
