FROM openjdk:8-jre

# ENVs
ENV HADOOP_HOME /opt/hadoop/latest/
ENV HIVE_HOME /opt/hive/latest/

# Versions
ARG HADOOP_VER=hadoop-2.9.0
ARG HADOOP_TAR=http://mirror.reverse.net/pub/apache/hadoop/common/${HADOOP_VER}/${HADOOP_VER}.tar.gz
ARG HIVE_VER=hive-2.3.2
ARG HIVE_TAR=http://mirrors.gigenet.com/apache/hive/${HIVE_VER}/apache-${HIVE_VER}-bin.tar.gz

# Make the destination directories
RUN mkdir /opt/hadoop && mkdir /opt/hive
ADD entrypoint.sh /entrypoint.sh

# Extract and rm compressed version
RUN cd /opt/hadoop && \
    wget ${HADOOP_TAR} 2>/dev/null && \
    tar xvf ${HADOOP_VER}.tar.gz && \
    rm -f ${HADOOP_VER}.tar.gz && \
    cd /opt/hive && \
    wget ${HIVE_TAR} 2>/dev/null && \
    tar xvf apache-${HIVE_VER}-bin.tar.gz && \
    rm -f apache-${HIVE_VER}-bin.tar.gz

# Symlink to latest
RUN ln -s /opt/hadoop/${HADOOP_VER} /opt/hadoop/latest && ln -s /opt/hive/apache-${HIVE_VER}-bin /opt/hive/latest

# Make a config file
COPY hive-site.xml /opt/hadoop/latest/etc/hadoop/hive-site.xml

ENTRYPOINT ["/entrypoint.sh"]
