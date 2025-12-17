# Apache Hadoop - Forked Repository

This is a fork of [Apache Hadoop](https://github.com/apache/hadoop), the open-source software framework for distributed storage and distributed processing of very large data sets on computer clusters.

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE.txt)
[![Java](https://img.shields.io/badge/java-8%20%7C%2011+-orange.svg)](https://www.oracle.com/java/)
[![Maven](https://img.shields.io/badge/maven-3.3+-brightgreen.svg)](https://maven.apache.org/)

## 🚀 Quick Start

Get up and running in minutes!

```bash
# 1. Validate your environment
./validate-environment.sh

# 2. Build and deploy Hadoop
./setup-local-env.sh -b dist -c -i ~/hadoop-local

# 3. Set up environment and start services
source ~/hadoop-local/hadoop-env-setup.sh
hdfs namenode -format
start-dfs.sh

# 4. Verify it's working
hdfs dfsadmin -report
```

📖 **[Read the Quick Start Guide →](QUICKSTART.md)**

## 📚 Documentation

This fork includes comprehensive documentation to help you get started:

- **[QUICKSTART.md](QUICKSTART.md)** - Get Hadoop running in 5 minutes
- **[LOCAL_SETUP.md](LOCAL_SETUP.md)** - Complete local environment setup guide
- **[CONFIGURATION.md](CONFIGURATION.md)** - Configuration templates and best practices
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development workflow and contributing guide
- **[BUILDING.txt](BUILDING.txt)** - Detailed build instructions (original)

## 🛠️ Setup Scripts

This repository includes helpful scripts for quick setup:

### `validate-environment.sh`
Validates that your system has all required prerequisites:
```bash
./validate-environment.sh
```

Checks:
- Java version (8 or 11+)
- Maven version (3.3+)
- Git configuration
- System resources (memory, disk space)
- Optional tools (Docker, native dependencies)

### `setup-local-env.sh`
Automated build and deployment script:
```bash
# Basic usage
./setup-local-env.sh -b dist -i ~/hadoop-local

# With configuration
./setup-local-env.sh -b dist -c -i ~/hadoop-local

# Available options:
# -b, --build-type    minimal|native|dist|full
# -i, --install-path  Installation directory
# -c, --configure     Create sample configs
# -v, --validate      Validate installation
# -h, --help          Show help
```

## 📋 What is Apache Hadoop?

The Apache Hadoop software library is a framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models. It is designed to scale up from single servers to thousands of machines, each offering local computation and storage.

### Core Components

- **Hadoop Common** - Common utilities and libraries
- **HDFS** - Hadoop Distributed File System for distributed storage
- **YARN** - Yet Another Resource Negotiator for job scheduling and cluster resource management
- **MapReduce** - Parallel processing framework for large data sets

## 🏗️ Building Hadoop

### Prerequisites

- Unix System (Linux, macOS, or Windows with WSL)
- JDK 8 or 11+
- Maven 3.3 or later
- Git
- Docker (optional, but recommended)

### Quick Build

```bash
# Minimal build (fastest)
mvn clean package -DskipTests -Dmaven.javadoc.skip=true

# Distribution build
mvn package -Pdist -DskipTests -Dtar -Dmaven.javadoc.skip=true

# Full build with native libraries
mvn package -Pdist,native -DskipTests -Dtar
```

### Using Docker Build Environment

The easiest way to build with all dependencies:

```bash
./start-build-env.sh
# Inside container:
mvn package -Pdist -DskipTests -Dtar -Dmaven.javadoc.skip=true
```

## 🔧 Configuration

### Single-Node Setup (Development)

Perfect for local development and testing:

```bash
# Use the setup script with configuration
./setup-local-env.sh -b dist -c -i ~/hadoop-local

# Or manually edit configuration files in etc/hadoop/:
# - core-site.xml (filesystem settings)
# - hdfs-site.xml (HDFS settings)
# - mapred-site.xml (MapReduce settings)
# - yarn-site.xml (YARN settings)
```

See [CONFIGURATION.md](CONFIGURATION.md) for detailed templates and examples.

### Multi-Node Cluster

For production deployments, see the [Cluster Setup Guide](hadoop-project-dist/hadoop-common/ClusterSetup.html) (generated after building docs).

## 🚦 Running Hadoop

### Start Services

```bash
# Format HDFS (first time only)
hdfs namenode -format

# Start HDFS
start-dfs.sh

# Start YARN (optional)
start-yarn.sh
```

### Access Web UIs

- **HDFS NameNode**: http://localhost:9870
- **YARN ResourceManager**: http://localhost:8088
- **MapReduce JobHistory**: http://localhost:19888

### Run Example

```bash
# Run the Pi estimation example
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100
```

### Stop Services

```bash
stop-yarn.sh
stop-dfs.sh
```

## 🧪 Testing

```bash
# Run all tests
mvn test

# Run tests for specific module
cd hadoop-hdfs-project/hadoop-hdfs
mvn test

# Run specific test class
mvn test -Dtest=TestDataNode

# Run with native code tests
mvn test -Pnative
```

## 👨‍💻 Development

### Working with the Fork

```bash
# Clone your fork
git clone https://github.com/CatoHomeOne/hadoop.git
cd hadoop

# Add upstream remote
git remote add upstream https://github.com/apache/hadoop.git
git fetch upstream

# Create feature branch
git checkout -b feature/my-feature

# Make changes and test
mvn clean install -DskipTests
mvn test -Dtest=MyTest

# Commit and push
git add .
git commit -m "Description of changes"
git push origin feature/my-feature
```

### Keeping Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Update your trunk branch
git checkout trunk
git merge upstream/trunk
git push origin trunk

# Rebase your feature branch
git checkout feature/my-feature
git rebase trunk
```

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed development workflows.

## 📊 Project Structure

```
hadoop/
├── hadoop-common-project/      # Core libraries and utilities
├── hadoop-hdfs-project/         # Distributed file system
├── hadoop-yarn-project/         # Resource management
├── hadoop-mapreduce-project/    # MapReduce framework
├── hadoop-tools/                # Additional tools (DistCp, etc.)
├── hadoop-client-modules/       # Client libraries
├── hadoop-dist/                 # Distribution assembly
├── hadoop-cloud-storage-project/# Cloud storage connectors
└── dev-support/                 # Development tools and scripts
```

## 🔒 Security

Apache Hadoop supports:
- Kerberos authentication
- Token-based delegation
- Access Control Lists (ACLs)
- Encryption at rest and in transit

See the [Security Guide](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SecureMode.html) for details.

## 📈 Performance Tuning

Key areas to tune:
- JVM heap sizes for daemons
- HDFS block size
- Replication factor
- MapReduce memory settings
- YARN resource allocation

See [CONFIGURATION.md](CONFIGURATION.md) for tuning guidelines.

## 🐛 Troubleshooting

### Common Issues

**Build fails with OutOfMemoryError:**
```bash
export MAVEN_OPTS="-Xms512m -Xmx3072m"
mvn clean install
```

**Cannot connect to services:**
- Check services are running: `jps`
- Verify SSH is configured: `ssh localhost`
- Check logs: `$HADOOP_HOME/logs/`

**Native library warnings:**
- Build with native: `mvn package -Pnative`
- Or use Docker: `./start-build-env.sh`

Run `./validate-environment.sh` to diagnose environment issues.

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run quality checks: `mvn verify`
6. Submit a pull request

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed contribution guidelines.

### Code Quality Standards

- Follow existing code style
- Add unit tests for new code
- Run checkstyle: `mvn checkstyle:checkstyle`
- Run spotbugs: `mvn spotbugs:spotbugs`
- Update documentation as needed

## 📝 License

Apache Hadoop is licensed under the [Apache License 2.0](LICENSE.txt).

## 🔗 Resources

### Documentation
- [Apache Hadoop Website](http://hadoop.apache.org/)
- [Official Documentation](https://hadoop.apache.org/docs/current/)
- [Hadoop Wiki](https://cwiki.apache.org/confluence/display/HADOOP/)

### Community
- [Mailing Lists](https://hadoop.apache.org/mailing_lists.html)
- [JIRA Issue Tracker](https://issues.apache.org/jira/browse/HADOOP)
- [Slack Channel](https://hadoop.apache.org/community.html)

### Getting Help
- Check [LOCAL_SETUP.md](LOCAL_SETUP.md) for setup issues
- Run `./validate-environment.sh` to diagnose problems
- Search [JIRA](https://issues.apache.org/jira/browse/HADOOP) for similar issues
- Ask on the [user mailing list](https://hadoop.apache.org/mailing_lists.html)

## 🎯 What's New in This Fork

This fork includes:

✨ **Enhanced Setup Experience**
- Automated environment validation
- One-command build and deployment
- Sample configuration templates
- Comprehensive documentation

📚 **Additional Documentation**
- Quick start guide
- Local setup guide
- Configuration templates
- Development workflow guide

🛠️ **Helper Scripts**
- `validate-environment.sh` - Environment checker
- `setup-local-env.sh` - Automated setup
- Pre-configured Docker builds

## 📞 Support

For issues specific to this fork:
- Open an issue in this repository
- Check the documentation in this repo

For general Hadoop questions:
- Apache Hadoop mailing lists
- Stack Overflow (tag: apache-hadoop)
- Official documentation

## 🙏 Acknowledgments

This project is based on [Apache Hadoop](https://hadoop.apache.org/), developed and maintained by the Apache Software Foundation and its community.

Special thanks to all Apache Hadoop contributors!

---

**Ready to get started?** Run `./validate-environment.sh` to check your setup, then follow the [Quick Start Guide](QUICKSTART.md)! 🚀
