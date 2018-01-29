
# Hadoop cluster for Docker Swarm

```
docker run -it --rm -p 8088:8088 -p 9000:9000 -p 50075:50075 -e NAMENODE=masternode --hostname masternode --name hadoop_test alex202/hadoop:2.7.5
```


## Test hdfs

#### Test 1
```
hdfs dfsadmin -report
```

#### Test 2
```
hdfs dfs -mkdir -p /user/root
hdfs dfs -ls /
hdfs dfs -mkdir test
hdfs dfs -ls
echo "hello world" | hdfs dfs -put - test/hello_world.txt

hdfs dfs -cat test/hello_world.txt # check on all datanodes
```

#### Test 3
```
hdfs dfs -mkdir input
hdfs dfs -put $HADOOP_HOME/etc/hadoop/ input
hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.5.jar grep input output 'dfs[a-z.]+'
hdfs dfs -cat output/*
```


#### Links:
 - https://github.com/kubernetes-incubator/application-images/tree/master/spark
 - https://github.com/junk16/spark-yarn-cluster