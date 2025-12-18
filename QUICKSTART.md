# Hadoop Fork - Quick Start Guide

Welcome! This guide will help you quickly get your forked Hadoop repository up and running in your local environment.

## 🚀 Quick Start (5 Minutes)

### Option 1: Automated Setup (Recommended)

```bash
# 1. Validate your environment
./validate-environment.sh

# 2. Build and deploy Hadoop
./setup-local-env.sh -b dist -c -i ~/hadoop-local

# 3. Set up your environment
source ~/hadoop-local/hadoop-env-setup.sh

# 4. Format HDFS (first time only)
hdfs namenode -format

# 5. Start Hadoop services
start-dfs.sh
start-yarn.sh

# 6. Verify it's working
hdfs dfsadmin -report
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100
```

### Option 2: Docker Build (Easiest)

```bash
# Start Docker build environment
./start-build-env.sh

# Inside container, build Hadoop
mvn package -Pdist -DskipTests -Dtar -Dmaven.javadoc.skip=true

# Exit container and extract distribution
exit
cd hadoop-dist/target
tar -xzf hadoop-3.5.0-SNAPSHOT.tar.gz
```

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Java 8 or 11+** (`java -version`)
- [ ] **Maven 3.3+** (`mvn -version`)
- [ ] **Git** (`git --version`)
- [ ] **At least 4GB RAM** available
- [ ] **At least 20GB disk space** available
- [ ] **Docker** (optional but recommended)

Run `./validate-environment.sh` to check all prerequisites automatically.

## 🔧 Common Build Commands

```bash
# Minimal build (fastest)
mvn clean package -DskipTests -Dmaven.javadoc.skip=true

# Build with native libraries
mvn clean package -Pnative -DskipTests -Dmaven.javadoc.skip=true

# Build distribution package
mvn package -Pdist -DskipTests -Dtar -Dmaven.javadoc.skip=true

# Full build with everything
mvn package -Pdist,native -DskipTests -Dtar -Dmaven.javadoc.skip=true
```

## 🏃 Running Hadoop Locally

### Single-Node Setup (Development)

1. **Set up environment variables:**
   ```bash
   export HADOOP_HOME=/path/to/hadoop
   export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
   ```

2. **Configure SSH (one-time setup):**
   ```bash
   ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   chmod 0600 ~/.ssh/authorized_keys
   ssh localhost  # Test it works
   ```

3. **Format and start HDFS:**
   ```bash
   hdfs namenode -format
   start-dfs.sh
   ```

4. **Start YARN (optional):**
   ```bash
   start-yarn.sh
   ```

5. **Access Web UIs:**
   - HDFS NameNode: http://localhost:9870
   - YARN ResourceManager: http://localhost:8088

### Test Your Installation

```bash
# Create a directory in HDFS
hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/$USER

# Run a MapReduce example
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100

# Check HDFS
hdfs dfs -ls /
```

## 🛠️ Development Workflow

### Build Specific Module

```bash
# Build only HDFS
cd hadoop-hdfs-project/hadoop-hdfs
mvn clean install -DskipTests

# Build only YARN
cd hadoop-yarn-project
mvn clean install -DskipTests
```

### Run Tests

```bash
# Run all tests in a module
mvn test

# Run specific test
mvn test -Dtest=TestClassName

# Run specific test method
mvn test -Dtest=TestClassName#methodName
```

### Code Quality

```bash
# Check code style
mvn checkstyle:checkstyle

# Run static analysis
mvn compile spotbugs:spotbugs
```

## 📁 Project Structure

```
hadoop/
├── hadoop-common-project/    # Core Hadoop libraries
├── hadoop-hdfs-project/       # Hadoop Distributed File System
├── hadoop-yarn-project/       # Resource management
├── hadoop-mapreduce-project/  # MapReduce framework
├── hadoop-tools/              # Additional tools (DistCp, etc.)
├── hadoop-client-modules/     # Client libraries
├── hadoop-dist/               # Distribution assembly
└── hadoop-assemblies/         # Build assemblies
```

## 🔍 Troubleshooting

### Build Fails with Out of Memory

```bash
export MAVEN_OPTS="-Xms256m -Xmx2048m"
mvn clean package -DskipTests
```

### Can't Connect to Hadoop Services

1. Check if services are running: `jps`
2. Check logs in: `$HADOOP_HOME/logs/`
3. Verify SSH works: `ssh localhost`
4. Check ports aren't in use: `lsof -i :9870`

### Native Library Warnings

```bash
# If you see "Unable to load native-hadoop library"
# Either:
# 1. Ignore it (works fine for development)
# 2. Build with native: mvn package -Pnative -DskipTests
# 3. Use Docker build environment: ./start-build-env.sh
```

### Permission Issues

```bash
# HDFS permission issues
hdfs dfs -chmod 755 /path/to/directory

# Local file permissions
chmod 755 $HADOOP_HOME/bin/*
chmod 755 $HADOOP_HOME/sbin/*
```

## 🔗 Keeping Your Fork Updated

```bash
# Add upstream remote (one-time)
git remote add upstream https://github.com/apache/hadoop.git

# Fetch latest changes
git fetch upstream

# Update your main/trunk branch
git checkout trunk
git merge upstream/trunk

# Push updates to your fork
git push origin trunk
```

## 📚 Additional Resources

- **Detailed Setup Guide**: See `LOCAL_SETUP.md`
- **Build Instructions**: See `BUILDING.txt`
- **Official Documentation**: https://hadoop.apache.org/docs/current/

## 🆘 Getting Help

1. Check the logs: `$HADOOP_HOME/logs/`
2. Run environment validation: `./validate-environment.sh`
3. Review documentation: `LOCAL_SETUP.md`
4. Check Apache Hadoop documentation
5. Open an issue in your fork's GitHub repository

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] `hadoop version` shows correct version
- [ ] `hdfs dfs -ls /` lists HDFS root
- [ ] Web UI accessible at http://localhost:9870
- [ ] Can run example: `hadoop jar ... pi 2 100`
- [ ] YARN UI accessible at http://localhost:8088 (if started)

## 🎯 Next Steps

1. ✅ Complete the quick start above
2. 📖 Read through `LOCAL_SETUP.md` for detailed information
3. 🔨 Try modifying and rebuilding a module
4. 🧪 Write and run tests
5. 🚀 Start developing your features!

---

**Need more help?** Run `./validate-environment.sh` to diagnose issues or check `LOCAL_SETUP.md` for comprehensive documentation.
