# Documentation Index

Welcome to your forked Apache Hadoop repository! This index will help you find the right documentation for your needs.

## 🚀 New to This Fork? Start Here

1. **[README.md](README.md)** - Start here for an overview
2. **[QUICKSTART.md](QUICKSTART.md)** - Get up and running in 5 minutes
3. **[validate-environment.sh](validate-environment.sh)** - Check your setup (run this first!)

## 📚 Documentation by Purpose

### Getting Started

| Document | Purpose | When to Use |
|----------|---------|-------------|
| [README.md](README.md) | Fork overview and quick links | First time visiting the repository |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute setup guide | You want to start immediately |
| [SETUP_SUMMARY.md](SETUP_SUMMARY.md) | What was added to this fork | Understanding fork enhancements |

### Setup and Installation

| Document | Purpose | When to Use |
|----------|---------|-------------|
| [LOCAL_SETUP.md](LOCAL_SETUP.md) | Complete setup guide | Detailed installation instructions |
| [BUILDING.txt](BUILDING.txt) | Official build instructions | Advanced build scenarios |
| [validate-environment.sh](validate-environment.sh) | Environment checker script | Verifying prerequisites |
| [setup-local-env.sh](setup-local-env.sh) | Automated setup script | One-command deployment |

### Configuration

| Document | Purpose | When to Use |
|----------|---------|-------------|
| [CONFIGURATION.md](CONFIGURATION.md) | Configuration templates | Setting up single/multi-node clusters |
| [LOCAL_SETUP.md](LOCAL_SETUP.md) | Basic configuration | Quick configuration for development |

### Development

| Document | Purpose | When to Use |
|----------|---------|-------------|
| [DEVELOPMENT.md](DEVELOPMENT.md) | Development workflow | Contributing or making changes |
| [README.md](README.md) | Contributing guidelines | Before submitting PRs |

## 🎯 Quick Navigation by Role

### I'm a Developer

1. Start: [QUICKSTART.md](QUICKSTART.md)
2. Setup: Run `./validate-environment.sh` then `./setup-local-env.sh -b dist`
3. Learn: [DEVELOPMENT.md](DEVELOPMENT.md)
4. Build: Check [BUILDING.txt](BUILDING.txt)

### I'm a DevOps Engineer

1. Start: [README.md](README.md)
2. Install: [LOCAL_SETUP.md](LOCAL_SETUP.md)
3. Configure: [CONFIGURATION.md](CONFIGURATION.md)
4. Deploy: Use `./setup-local-env.sh` for automation

### I'm New to Hadoop

1. Start: [README.md](README.md) - Understand what Hadoop is
2. Quick Setup: [QUICKSTART.md](QUICKSTART.md)
3. Learn More: Visit [Apache Hadoop Website](http://hadoop.apache.org/)
4. Practice: Follow [LOCAL_SETUP.md](LOCAL_SETUP.md) examples

### I Want to Contribute

1. Setup: [LOCAL_SETUP.md](LOCAL_SETUP.md)
2. Workflow: [DEVELOPMENT.md](DEVELOPMENT.md)
3. Standards: [DEVELOPMENT.md](DEVELOPMENT.md#code-quality)
4. Submit: Follow PR guidelines in [README.md](README.md#contributing)

## 📋 Common Tasks

### First Time Setup

```bash
# 1. Validate environment
./validate-environment.sh

# 2. Build and deploy
./setup-local-env.sh -b dist -c -i ~/hadoop-local

# 3. Set up environment
source ~/hadoop-local/hadoop-env-setup.sh

# 4. Format HDFS and start
hdfs namenode -format
start-dfs.sh
```

📖 Detailed guide: [QUICKSTART.md](QUICKSTART.md)

### Development Setup

```bash
# Build for development
mvn clean install -DskipTests -DskipShade

# Run tests
mvn test -Dtest=TestClassName

# Check code quality
mvn verify
```

📖 Detailed guide: [DEVELOPMENT.md](DEVELOPMENT.md)

### Configuration

See [CONFIGURATION.md](CONFIGURATION.md) for:
- Single-node setup (development)
- Multi-node setup (production)
- High availability configuration
- Security settings
- Performance tuning

### Troubleshooting

1. Run: `./validate-environment.sh`
2. Check: [QUICKSTART.md](QUICKSTART.md#troubleshooting)
3. Review: [LOCAL_SETUP.md](LOCAL_SETUP.md#troubleshooting)
4. Debug: [DEVELOPMENT.md](DEVELOPMENT.md#troubleshooting-development-issues)

## 🛠️ Tools and Scripts

### Validation Script
```bash
./validate-environment.sh
```
Checks Java, Maven, Git, Docker, system resources, and more.

### Setup Script
```bash
./setup-local-env.sh [OPTIONS]

Options:
  -b, --build-type TYPE   Build type: minimal|native|dist|full
  -i, --install-path PATH Installation directory
  -c, --configure         Create sample configs
  -v, --validate          Validate installation
  -h, --help              Show help
```

### Build Environment Script
```bash
./start-build-env.sh [platform]

Platforms:
  ubuntu_20 (default)
  ubuntu_24
  debian_11
  rockylinux_8
```

## 📊 Document Details

### Comprehensive Documents (Read When You Have Time)

- **[LOCAL_SETUP.md](LOCAL_SETUP.md)** - 7.4KB
  - Prerequisites
  - Quick start
  - Docker builds
  - Local deployment
  - Development workflow
  - IDE setup
  - Troubleshooting

- **[CONFIGURATION.md](CONFIGURATION.md)** - 11KB
  - Configuration templates
  - Single-node setup
  - Multi-node setup
  - Performance tuning
  - Best practices

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - 12KB
  - Development environment
  - Branch management
  - Testing guidelines
  - Code quality
  - Contributing workflow
  - Common tasks

### Quick Reference Documents

- **[QUICKSTART.md](QUICKSTART.md)** - 6KB
  - 5-minute setup
  - Common commands
  - Quick troubleshooting

- **[README.md](README.md)** - 10KB
  - Project overview
  - Quick links
  - Getting started
  - Resources

- **[SETUP_SUMMARY.md](SETUP_SUMMARY.md)** - 7.5KB
  - What was added
  - How to use
  - Key features
  - Next steps

## 🔗 External Resources

- [Apache Hadoop Website](http://hadoop.apache.org/)
- [Official Documentation](https://hadoop.apache.org/docs/current/)
- [Hadoop Wiki](https://cwiki.apache.org/confluence/display/HADOOP/)
- [JIRA Issue Tracker](https://issues.apache.org/jira/browse/HADOOP)
- [Mailing Lists](https://hadoop.apache.org/mailing_lists.html)

## 💡 Tips

- **First time?** Start with [README.md](README.md) and [QUICKSTART.md](QUICKSTART.md)
- **Having issues?** Run `./validate-environment.sh` first
- **Need to configure?** Check [CONFIGURATION.md](CONFIGURATION.md)
- **Want to develop?** Read [DEVELOPMENT.md](DEVELOPMENT.md)
- **Quick reference?** Use this index!

## 📞 Getting Help

1. Search this documentation
2. Run `./validate-environment.sh`
3. Check the troubleshooting sections
4. Visit Apache Hadoop resources
5. Open an issue in this repository

## ✅ Recommended Reading Order

### For Quick Setup
1. [README.md](README.md) - Overview
2. [QUICKSTART.md](QUICKSTART.md) - Setup in 5 minutes
3. Run `./validate-environment.sh` and `./setup-local-env.sh`

### For Complete Understanding
1. [README.md](README.md) - Overview
2. [SETUP_SUMMARY.md](SETUP_SUMMARY.md) - What's new
3. [LOCAL_SETUP.md](LOCAL_SETUP.md) - Complete guide
4. [CONFIGURATION.md](CONFIGURATION.md) - Configuration details
5. [DEVELOPMENT.md](DEVELOPMENT.md) - Development workflow

### For Contributing
1. [README.md](README.md) - Project overview
2. [LOCAL_SETUP.md](LOCAL_SETUP.md) - Setup environment
3. [DEVELOPMENT.md](DEVELOPMENT.md) - Contribution workflow
4. [BUILDING.txt](BUILDING.txt) - Advanced building

---

**Not sure where to start?** Run `./validate-environment.sh` and then follow [QUICKSTART.md](QUICKSTART.md)! 🚀
