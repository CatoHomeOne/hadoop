# Local Environment Setup Guide

This guide will help you configure and deploy your forked Hadoop repository in your local development environment.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Unix/Linux System** (or WSL2 on Windows)
- **JDK 1.8** (Java 8) - Required for Hadoop 3.x
- **Maven 3.3+** - Build automation tool
- **Git** - Version control
- **Docker** (Optional but recommended) - For containerized build environment

## Quick Start

### 1. Clone Your Forked Repository

```bash
# Clone the repository
git clone https://github.com/CatoHomeOne/hadoop.git
cd hadoop

# Set up the upstream remote to track Apache Hadoop
git remote add upstream https://github.com/apache/hadoop.git
git fetch upstream
```

### 2. Verify Your Environment

```bash
# Check Java version (should be 1.8 or 11)
java -version

# Check Maven version (should be 3.3+)
mvn -version

# Check Git version
git --version
```

### 3. Build Hadoop (Simplest Approach)

```bash
# Build Hadoop without tests (fastest)
mvn clean package -DskipTests -Dmaven.javadoc.skip=true

# Or build with native code support
mvn clean package -Pnative -DskipTests -Dmaven.javadoc.skip=true
```

### 4. Build Distribution Package

```bash
# Create binary distribution
mvn package -Pdist -DskipTests -Dtar -Dmaven.javadoc.skip=true

# The distribution will be available at:
# hadoop-dist/target/hadoop-3.5.0-SNAPSHOT.tar.gz
```

## Using Docker Build Environment (Recommended)

The easiest way to build Hadoop with all dependencies is using the provided Docker environment:

```bash
# Start the Docker build environment
./start-build-env.sh

# Inside the container, build Hadoop
mvn clean package -Pdist -DskipTests -Dtar -Dmaven.javadoc.skip=true
```

Available Docker platforms:
- `ubuntu_20` (default)
- `ubuntu_24`
- `debian_11`
- `debian_12`
- `rockylinux_8`

## Local Deployment

### 1. Extract the Distribution

```bash
cd hadoop-dist/target
tar -xzf hadoop-3.5.0-SNAPSHOT.tar.gz
cd hadoop-3.5.0-SNAPSHOT
export HADOOP_HOME=$(pwd)
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

### 2. Configure Hadoop Environment

Edit `etc/hadoop/hadoop-env.sh`:

```bash
# Set Java home
export JAVA_HOME=/path/to/your/jdk

# Set Hadoop configuration directory
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
```

### 3. Configure Core Hadoop (Single Node Setup)

Edit `etc/hadoop/core-site.xml`:

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/tmp/hadoop-${user.name}</value>
    </property>
</configuration>
```

Edit `etc/hadoop/hdfs-site.xml`:

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///home/hadoop/data/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///home/hadoop/data/datanode</value>
    </property>
</configuration>
```

### 4. Format HDFS and Start Services

```bash
# Format the HDFS namenode (first time only)
hdfs namenode -format

# Start HDFS
start-dfs.sh

# Verify HDFS is running
hdfs dfsadmin -report

# Access HDFS web UI at: http://localhost:9870
```

### 5. Start YARN (Optional)

Edit `etc/hadoop/mapred-site.xml`:

```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

Edit `etc/hadoop/yarn-site.xml`:

```xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>localhost</value>
    </property>
</configuration>
```

```bash
# Start YARN
start-yarn.sh

# Verify YARN is running
yarn node -list

# Access YARN web UI at: http://localhost:8088
```

## Development Workflow

### Building Specific Modules

```bash
# Build only HDFS
cd hadoop-hdfs-project/hadoop-hdfs
mvn clean install -DskipTests

# Build only YARN
cd hadoop-yarn-project
mvn clean install -DskipTests

# Build only MapReduce
cd hadoop-mapreduce-project
mvn clean install -DskipTests
```

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test
mvn test -Dtest=TestClassName

# Run tests with native code
mvn test -Pnative
```

### Code Quality Checks

```bash
# Run checkstyle
mvn checkstyle:checkstyle

# Run spotbugs
mvn compile spotbugs:spotbugs

# Run all code quality checks
mvn verify
```

### Working with Your Fork

```bash
# Create a feature branch
git checkout -b feature/my-feature

# Make your changes and commit
git add .
git commit -m "Description of changes"

# Push to your fork
git push origin feature/my-feature

# Keep your fork in sync with upstream
git fetch upstream
git checkout trunk
git merge upstream/trunk
git push origin trunk
```

## Troubleshooting

### Out of Memory Errors

If you encounter out of memory errors during build:

```bash
export MAVEN_OPTS="-Xms256m -Xmx2048m"
mvn clean package -DskipTests
```

### Missing Native Libraries

If you see warnings about native libraries:

```bash
# Build with native profile
mvn package -Pnative -DskipTests

# Or use the Docker build environment which has all dependencies
./start-build-env.sh
```

### Port Already in Use

If ports 9000, 9870, 8088 are in use:

```bash
# Check what's using the port
lsof -i :9870

# Kill the process or change port in configuration files
```

### SSH Passwordless Setup

For a single-node cluster, set up passwordless SSH:

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

# Add to authorized keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

# Test SSH
ssh localhost
```

## Additional Resources

- **Official Hadoop Documentation**: https://hadoop.apache.org/docs/current/
- **Building Instructions**: See `BUILDING.txt` in the repository
- **Single Cluster Setup**: `hadoop-project-dist/hadoop-common/SingleCluster.html` (after building docs)
- **Cluster Setup**: `hadoop-project-dist/hadoop-common/ClusterSetup.html` (after building docs)

## IDE Setup

### IntelliJ IDEA

1. Import the project as a Maven project
2. Build the project first: `mvn clean install -DskipTests -DskipShade`
3. File → Project Structure → SDKs → Add JDK 1.8
4. Enable annotation processing for hadoop-annotations

### Eclipse

1. Build artifacts first: `mvn clean install -DskipTests -DskipShade`
2. File → Import → Maven → Existing Maven Projects
3. Select the repository root directory
4. Eclipse will import all modules

### VS Code

1. Install Java Extension Pack
2. Install Maven for Java extension
3. Open the repository folder
4. VS Code will automatically detect the Maven project

## Next Steps

After setting up your local environment:

1. Read the contributor guide (if planning to contribute)
2. Explore the codebase and module structure
3. Run example MapReduce jobs to verify your setup
4. Start developing your features or fixes
5. Run tests before submitting pull requests

## Support

For issues specific to this fork, please open an issue in the GitHub repository:
https://github.com/CatoHomeOne/hadoop/issues

For general Hadoop questions, refer to:
- Apache Hadoop User Mailing List
- Apache Hadoop Developer Mailing List
- Stack Overflow (tag: apache-hadoop)
