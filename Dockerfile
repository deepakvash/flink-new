FROM docker.repo1.uhc.com/solutioning-appstore/oracle_jdk:8_unlimited_jce_ubuntu_16.04

#RUN apt-get -y install openssh-client 
#CMD ssh-keygen -q -t rsa -N '' -f /keys/id_rsa

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
      openssh-server 

#add passless key to ssh
RUN ssh-keygen -f ~/.ssh/id_rsa -t rsa -C '' 
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/*

ENV FLINK_VERSION=1.11.0
#ENV HADOOP_VERSION=28
ENV SCALA_VERSION=2.12

#Enable poc-init-daemon
ENV ENABLE_INIT_DAEMON true
ENV INIT_DAEMON_BASE_URI http://identifier/init-daemon
ENV INIT_DAEMON_STEP flink_master_init

##Flink Installation
###Download:
RUN   apt-get update \
      && apt-get install dnsutils -y  \
      && wget https://archive.apache.org/dist/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz \
      && tar -xvzf flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz \
      && rm flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz \
      && mv flink-${FLINK_VERSION} /usr/local/flink
ENV FLINK_HOME /usr/local/flink
ENV PATH $PATH:$FLINK_HOME/bin

# add netcat for SERVICE_PRECONDITION checks
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends netcat

RUN chown 1001:1001 -R /opt && chmod +x /usr/local/flink

User root
EXPOSE 6123 8081
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["/usr/local/flink/bin/start-cluster.sh", "run"]
#CMD ["/bin/bash", "/docker-entrypoint.sh", "jobmanager"]