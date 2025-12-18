# Hadoop Configuration Templates

This directory contains template configuration files for setting up Hadoop in various deployment scenarios.

## Configuration Files Overview

Hadoop's configuration is controlled by several XML files located in `$HADOOP_HOME/etc/hadoop/`:

1. **core-site.xml** - Core Hadoop settings (default filesystem, temp directories)
2. **hdfs-site.xml** - HDFS-specific settings (replication, storage locations)
3. **mapred-site.xml** - MapReduce settings (framework type, job history)
4. **yarn-site.xml** - YARN resource management settings
5. **hadoop-env.sh** - Environment variables for Hadoop daemons

## Quick Setup

### Single-Node Cluster (Development)

For local development and testing on a single machine:

#### core-site.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
        <description>The default file system URI</description>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/tmp/hadoop-${user.name}</value>
        <description>Base directory for temporary files</description>
    </property>
</configuration>
```

#### hdfs-site.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
        <description>Default block replication (1 for single-node)</description>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${user.home}/hadoop-data/namenode</value>
        <description>NameNode metadata directory</description>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://${user.home}/hadoop-data/datanode</value>
        <description>DataNode storage directory</description>
    </property>
</configuration>
```

#### mapred-site.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        <description>Use YARN for MapReduce</description>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
```

#### yarn-site.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        <description>Shuffle service for MapReduce</description>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>localhost</value>
        <description>ResourceManager hostname</description>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>
```

### Multi-Node Cluster (Production)

For a production cluster with multiple nodes:

#### core-site.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://namenode.example.com:9000</value>
        <description>Replace with your NameNode hostname</description>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/data/hadoop/tmp</value>
        <description>Use a dedicated disk partition</description>
    </property>
    <property>
        <name>io.file.buffer.size</name>
        <value>131072</value>
        <description>Buffer size for read/write operations</description>
    </property>
</configuration>
```

#### hdfs-site.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
        <description>Default block replication (3 for production)</description>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///data/hadoop/namenode</value>
        <description>NameNode metadata directory (use multiple disks in production)</description>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///data1/hadoop/datanode,file:///data2/hadoop/datanode</value>
        <description>DataNode storage directories (comma-separated for multiple disks)</description>
    </property>
    <property>
        <name>dfs.blocksize</name>
        <value>134217728</value>
        <description>Block size (128MB)</description>
    </property>
    <property>
        <name>dfs.namenode.handler.count</name>
        <value>100</value>
        <description>Number of NameNode handler threads</description>
    </property>
</configuration>
```

#### yarn-site.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>resourcemanager.example.com</value>
        <description>Replace with your ResourceManager hostname</description>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>8192</value>
        <description>Total memory allocated to containers (adjust based on available RAM)</description>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>8</value>
        <description>Total CPU cores allocated to containers</description>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
        <description>Minimum container memory allocation</description>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>8192</value>
        <description>Maximum container memory allocation</description>
    </property>
</configuration>
```

## Environment Configuration

### hadoop-env.sh

Add these settings to `$HADOOP_HOME/etc/hadoop/hadoop-env.sh`:

```bash
# Java home - adjust path based on your system:
# Ubuntu/Debian: /usr/lib/jvm/java-8-openjdk-amd64 or /usr/lib/jvm/java-11-openjdk-amd64
# RHEL/CentOS: /usr/lib/jvm/java-1.8.0-openjdk or /usr/lib/jvm/java-11-openjdk
# macOS (Homebrew): /usr/local/opt/openjdk@8 or /usr/local/opt/openjdk@11
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64  # Example for Ubuntu

# Hadoop home
export HADOOP_HOME=/path/to/hadoop  # Adjust path

# Hadoop configuration directory
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

# Hadoop log directory
export HADOOP_LOG_DIR=${HADOOP_HOME}/logs

# Hadoop process ID directory
export HADOOP_PID_DIR=/var/run/hadoop

# JVM options for daemons
export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true"

# NameNode JVM options
export HADOOP_NAMENODE_OPTS="-Xmx2048m $HADOOP_NAMENODE_OPTS"

# DataNode JVM options
export HADOOP_DATANODE_OPTS="-Xmx1024m $HADOOP_DATANODE_OPTS"

# ResourceManager JVM options
export YARN_RESOURCEMANAGER_OPTS="-Xmx2048m $YARN_RESOURCEMANAGER_OPTS"

# NodeManager JVM options
export YARN_NODEMANAGER_OPTS="-Xmx1024m $YARN_NODEMANAGER_OPTS"
```

## Common Configuration Patterns

### High Availability (HA) Setup

For HA NameNode configuration:

```xml
<property>
    <name>dfs.nameservices</name>
    <value>mycluster</value>
</property>
<property>
    <name>dfs.ha.namenodes.mycluster</name>
    <value>nn1,nn2</value>
</property>
<property>
    <name>dfs.namenode.rpc-address.mycluster.nn1</name>
    <value>namenode1.example.com:9000</value>
</property>
<property>
    <name>dfs.namenode.rpc-address.mycluster.nn2</name>
    <value>namenode2.example.com:9000</value>
</property>
```

### Security Configuration

Enable Kerberos authentication:

```xml
<property>
    <name>hadoop.security.authentication</name>
    <value>kerberos</value>
</property>
<property>
    <name>hadoop.security.authorization</name>
    <value>true</value>
</property>
```

### Compression Settings

Enable compression for better performance:

```xml
<property>
    <name>mapreduce.map.output.compress</name>
    <value>true</value>
</property>
<property>
    <name>mapreduce.map.output.compress.codec</name>
    <value>org.apache.hadoop.io.compress.SnappyCodec</value>
</property>
```

## Performance Tuning

### Memory Settings

Adjust based on your cluster size:

- **Small cluster (< 10 nodes)**: NameNode 2-4GB, DataNode 1-2GB
- **Medium cluster (10-100 nodes)**: NameNode 4-8GB, DataNode 2-4GB
- **Large cluster (> 100 nodes)**: NameNode 8-16GB+, DataNode 4-8GB

### Block Size

- **Small files (< 1GB)**: 64MB blocks
- **Medium files (1-100GB)**: 128MB blocks (default)
- **Large files (> 100GB)**: 256MB or 512MB blocks

### Replication Factor

- **Development**: 1
- **Testing**: 2
- **Production**: 3 (default)
- **Critical data**: 4+

## Configuration Best Practices

1. **Use separate disks** for HDFS data and OS
2. **Enable compression** for MapReduce intermediate data
3. **Tune JVM heap sizes** based on available memory
4. **Monitor and adjust** based on workload patterns
5. **Keep configurations in version control**
6. **Use configuration management tools** (Ansible, Puppet, Chef)
7. **Document custom settings** and reasons for changes
8. **Test configuration changes** on development cluster first

## Validation

After configuring, validate your setup:

```bash
# Check configuration syntax
hdfs getconf -confKey dfs.replication

# Test HDFS
hdfs dfs -mkdir /test
hdfs dfs -ls /

# Run example job
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100

# Check cluster health
hdfs dfsadmin -report
yarn node -list
```

## Troubleshooting Configuration Issues

### Check logs:
```bash
tail -f $HADOOP_HOME/logs/hadoop-*-namenode-*.log
tail -f $HADOOP_HOME/logs/hadoop-*-datanode-*.log
tail -f $HADOOP_HOME/logs/yarn-*-resourcemanager-*.log
```

### Verify configuration is loaded:
```bash
hdfs getconf -confKey fs.defaultFS
hdfs getconf -confKey dfs.replication
yarn getconf -confKey yarn.resourcemanager.hostname
```

### Common issues:
- Port conflicts: Change port numbers in configuration
- Permission errors: Check file/directory permissions
- Memory issues: Adjust JVM heap sizes
- Network issues: Check hostname resolution and firewall rules

## Additional Resources

- [Hadoop Configuration Guide](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html)
- [HDFS Configuration](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)
- [YARN Configuration](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)
- [MapReduce Configuration](https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml)
