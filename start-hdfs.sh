#!/usr/bin/env bash

: ${HADOOP_HOME:=/opt/hadoop}

sed -i "/^export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\n:" $HADOOP_HOME/etc/hadoop/hadoop-env.sh
sed -i "/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}:" $HADOOP_HOME/etc/hadoop/hadoop-env.sh

#mkdir $HADOOP_HOME/input
#cp $HADOOP_HOME/etc/hadoop/*.xml $HADOOP_HOME/input

$HADOOP_HOME/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# Installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# Start sshd service
service ssh start

# altering the core-site configuration
sed s/HOSTNAME/$NAMENODE/ /opt/hadoop/etc/hadoop/core-site.xml.template > /opt/hadoop/etc/hadoop/core-site.xml

# altering yarn-core configuration
sed s/HOSTNAME/$NAMENODE/ /opt/hadoop/etc/hadoop/yarn-site.xml.template > /opt/hadoop/etc/hadoop/yarn-site.xml

# export native libraries
export LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native/:$LD_LIBRARY_PATH && ldconfig


if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
  if [ ! -d /hdfs/tmp/dfs/name/current ]; then
    echo 'Format Namenode.'
    $HADOOP_HOME/bin/hdfs namenode -format
  fi

  #run on NAMENODE
  echo 'Starting HDFS....'
  $HADOOP_HOME/sbin/start-dfs.sh
#  $HADOOP_HOME/sbin/start-yarn.sh # optional, might be switched off
  sleep 5

elif [ "${DATANODE}" ]; then
  #start datanode
  echo 'Starting Datanode....'
  #$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
  export USER=root
  $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
fi

if [[ $1 == "-d" ]]; then
  while [ 1 ]
  do
   sleep 1000
  done
elif [[ $1 == "-bash" ]]; then
  /bin/bash
fi