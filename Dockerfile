FROM java:openjdk-8-jdk

ENV HADOOP_VER 2.7.5
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop

# Install all dependencies
RUN apt-get update \
  && apt-get install -y curl net-tools rsync openssh-server openssh-client \
  && rm -r /var/cache/apt /var/lib/apt/lists

# Download and install hadoop
RUN mkdir -p /opt \
    && cd /opt \
    && curl http://www.eu.apache.org/dist/hadoop/common/hadoop-${HADOOP_VER}/hadoop-${HADOOP_VER}.tar.gz | tar -zx \
    && ln -s hadoop-${HADOOP_VER} hadoop \
    && echo Hadoop ${HADOOP_VER} native libraries installed in /opt/hadoop/lib/native

# Install ssh key
RUN ssh-keygen -q -t dsa -P '' -f /root/.ssh/id_dsa \
    && cat /root/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys

# Config ssh to accept all connections from unknow hosts.
COPY ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config \
    && chown root:root /root/.ssh/config

RUN  sed -i "/^[^#]*UsePAM/ s/.*/UsePAM no/" /etc/ssh/sshd_config \
  && sed -i "/^[^#]*Port/ s/.*/Port 2122/" /etc/ssh/sshd_config

# Copy Hadoop config files
ADD ./conf/ $HADOOP_HOME/etc/hadoop/

# Copy bootstrap file, fix file permissions
COPY start-hdfs.sh /etc/start-hdfs.sh
RUN chmod 700 /etc/start-hdfs.sh \
    && chown root:root /etc/start-hdfs.sh \
    && ls -la ${HADOOP_HOME}/etc/hadoop/*-env.sh \
    && chmod +x ${HADOOP_HOME}/etc/hadoop/*-env.sh \
    && ls -la ${HADOOP_HOME}/etc/hadoop/*-env.sh

ENV PATH $PATH:${HADOOP_HOME}/bin
ENV DATANODE localhost

ENTRYPOINT ["/etc/start-hdfs.sh", "-d"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122