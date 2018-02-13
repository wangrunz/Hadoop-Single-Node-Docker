# HADOOP Single Node Cluster Docker
FROM ubuntu

# Get necessary packages
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y python3 && \
    apt-get install -y default-jdk && \
    apt-get install -y openssh-server && \
    apt-get install -y openssh-client && \
    apt-get install -y vim && \
    wget http://ftp.wayne.edu/apache/hadoop/common/hadoop-3.0.0/hadoop-3.0.0.tar.gz

# Set Enviroment variables
ENV HADOOP_HOME /usr/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64/
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Unzip hadoop3 and move it to new directory
RUN tar -xzf hadoop-3.0.0.tar.gz
RUN mv hadoop-3.0.0 $HADOOP_HOME

# Set passwordless ssh
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# Set up Hadoop configurations
RUN mkdir $HADOOP_HOME/hdfs &&\
    mkdir $HADOOP_HOME/hdfs/name &&\
    mkdir $HADOOP_HOME/hdfs/data &&\
    mkdir $HADOOP_HOME/tmp

ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh


# Start SSH, format hadoop namenode, start hadoop services
# Create input/output directory in hdfs
# Run bash
ENTRYPOINT service ssh start &&\
           hadoop namenode -format &&\
           start-all.sh &&\
           hdfs dfs -mkdir /input &&\
           hdfs dfs -mkdir /output &&\
           bash
