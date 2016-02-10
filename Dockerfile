#FROM ubuntu:vivid
FROM java:openjdk-8-jdk
MAINTAINER Markus Mayer <widemeadows@gmail.com>

ENV ZOOKEEPER_PATH=/zookeeper

COPY bin/zookeeper-setup.sh /tmp/
RUN /tmp/zookeeper-setup.sh

WORKDIR $ZOOKEEPER_PATH

COPY bin/zookeeper-init.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/zookeeper-init.sh"]
