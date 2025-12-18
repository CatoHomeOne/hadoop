#!/bin/bash

################################################################################
# Hadoop Local Environment Setup Script
# 
# This script helps configure and deploy Hadoop in your local environment
# Usage: ./setup-local-env.sh [options]
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HADOOP_SOURCE_DIR="$SCRIPT_DIR"

# Default configuration
BUILD_TYPE="minimal"  # minimal, full, native, dist
SKIP_TESTS=true
USE_DOCKER=false
INSTALL_PATH="${HOME}/hadoop-deploy"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

################################################################################
# Check Prerequisites
################################################################################

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local all_ok=true
    
    # Check Java
    if check_command java; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        print_info "Java version: $JAVA_VERSION"
    else
        all_ok=false
    fi
    
    # Check Maven
    if check_command mvn; then
        MVN_VERSION=$(mvn -version | head -n 1 | awk '{print $3}')
        print_info "Maven version: $MVN_VERSION"
    else
        all_ok=false
    fi
    
    # Check Git
    if check_command git; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        print_info "Git version: $GIT_VERSION"
    else
        all_ok=false
    fi
    
    # Check Docker (optional)
    if check_command docker; then
        print_info "Docker is available (optional)"
    else
        print_warning "Docker is not installed (optional, but recommended)"
    fi
    
    if [ "$all_ok" = false ]; then
        print_error "Some prerequisites are missing. Please install them first."
        exit 1
    fi
    
    print_success "All required prerequisites are installed"
}

################################################################################
# Build Hadoop
################################################################################

build_hadoop() {
    print_header "Building Hadoop"
    
    cd "$HADOOP_SOURCE_DIR"
    
    local mvn_cmd="mvn clean package"
    local mvn_opts="-Dmaven.javadoc.skip=true"
    
    if [ "$SKIP_TESTS" = true ]; then
        mvn_opts="$mvn_opts -DskipTests"
    fi
    
    case "$BUILD_TYPE" in
        minimal)
            print_info "Building minimal Hadoop (no native, no tests, no docs)"
            mvn_cmd="$mvn_cmd $mvn_opts"
            ;;
        native)
            print_info "Building Hadoop with native libraries"
            mvn_cmd="$mvn_cmd -Pnative $mvn_opts"
            ;;
        dist)
            print_info "Building Hadoop distribution package"
            mvn_cmd="$mvn_cmd -Pdist -Dtar $mvn_opts"
            ;;
        full)
            print_info "Building full Hadoop with all features"
            mvn_cmd="$mvn_cmd -Pdist,native -Dtar $mvn_opts"
            ;;
        *)
            print_error "Unknown build type: $BUILD_TYPE"
            exit 1
            ;;
    esac
    
    print_info "Executing: $mvn_cmd"
    
    # Set Maven memory options
    export MAVEN_OPTS="${MAVEN_OPTS:--Xms256m -Xmx2048m}"
    print_info "MAVEN_OPTS: $MAVEN_OPTS"
    
    if eval "$mvn_cmd"; then
        print_success "Hadoop build completed successfully"
    else
        print_error "Hadoop build failed"
        exit 1
    fi
}

################################################################################
# Deploy Hadoop
################################################################################

deploy_hadoop() {
    print_header "Deploying Hadoop"
    
    # Find the built distribution
    local dist_file=""
    
    if [ "$BUILD_TYPE" = "dist" ] || [ "$BUILD_TYPE" = "full" ]; then
        dist_file=$(find "$HADOOP_SOURCE_DIR/hadoop-dist/target" -name "hadoop-*.tar.gz" -type f | head -n 1)
        
        if [ -z "$dist_file" ]; then
            print_error "Distribution file not found. Did the build succeed?"
            exit 1
        fi
        
        print_info "Found distribution: $dist_file"
        
        # Create installation directory
        mkdir -p "$INSTALL_PATH"
        
        # Extract distribution
        print_info "Extracting to $INSTALL_PATH"
        tar -xzf "$dist_file" -C "$INSTALL_PATH" --strip-components=1
        
        print_success "Hadoop deployed to $INSTALL_PATH"
    else
        print_warning "Distribution not built. Skipping deployment."
        print_info "To deploy, run with --build-type dist or --build-type full"
        return
    fi
    
    # Create environment setup script
    create_env_script
}

################################################################################
# Create Environment Setup Script
################################################################################

create_env_script() {
    print_header "Creating Environment Setup Script"
    
    local env_script="$INSTALL_PATH/hadoop-env-setup.sh"
    
    cat > "$env_script" << 'EOF'
#!/bin/bash
# Hadoop Environment Setup
# Source this file to set up Hadoop environment variables
# Usage: source hadoop-env-setup.sh

# Get the directory where this script is located
HADOOP_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HADOOP_HOME

# Set Hadoop configuration directory
export HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"

# Add Hadoop binaries to PATH
export PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

# Set Java home (update this to your Java installation)
# export JAVA_HOME=/path/to/java

# Set Hadoop log directory
export HADOOP_LOG_DIR="${HADOOP_HOME}/logs"

# Set Hadoop data directory
export HADOOP_DATA_DIR="${HADOOP_HOME}/data"

# Create necessary directories
mkdir -p "${HADOOP_LOG_DIR}"
mkdir -p "${HADOOP_DATA_DIR}"

echo "Hadoop environment configured:"
echo "  HADOOP_HOME: ${HADOOP_HOME}"
echo "  HADOOP_CONF_DIR: ${HADOOP_CONF_DIR}"
echo "  Hadoop version: $(hadoop version 2>/dev/null | head -n 1 || echo 'Run: hadoop version')"

EOF
    
    chmod +x "$env_script"
    print_success "Environment setup script created: $env_script"
    print_info "To configure your shell, run: source $env_script"
}

################################################################################
# Create Sample Configuration Files
################################################################################

create_sample_config() {
    print_header "Creating Sample Configuration Files"
    
    if [ ! -d "$INSTALL_PATH/etc/hadoop" ]; then
        print_warning "Hadoop not deployed yet. Skipping configuration."
        return
    fi
    
    local conf_dir="$INSTALL_PATH/etc/hadoop"
    
    # Backup existing configs
    print_info "Backing up existing configurations"
    for file in core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml; do
        if [ -f "$conf_dir/$file" ]; then
            cp "$conf_dir/$file" "$conf_dir/$file.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    done
    
    # Create core-site.xml
    cat > "$conf_dir/core-site.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
        <description>The default file system URI</description>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/tmp/hadoop-${user.name}</value>
        <description>A base for other temporary directories</description>
    </property>
</configuration>
EOF
    
    # Create hdfs-site.xml
    cat > "$conf_dir/hdfs-site.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
        <description>Default block replication for single-node setup</description>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${env.HADOOP_HOME}/data/namenode</value>
        <description>Path on the local filesystem where the NameNode stores the namespace</description>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://${env.HADOOP_HOME}/data/datanode</value>
        <description>Path on the local filesystem where the DataNode stores its blocks</description>
    </property>
</configuration>
EOF
    
    # Create mapred-site.xml
    cat > "$conf_dir/mapred-site.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        <description>The runtime framework for executing MapReduce jobs</description>
    </property>
</configuration>
EOF
    
    # Create yarn-site.xml
    cat > "$conf_dir/yarn-site.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        <description>Shuffle service for MapReduce</description>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>localhost</value>
        <description>The hostname of the ResourceManager</description>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>
EOF
    
    print_success "Sample configuration files created in $conf_dir"
    print_info "Review and customize the configuration files as needed"
}

################################################################################
# Validate Installation
################################################################################

validate_installation() {
    print_header "Validating Installation"
    
    if [ ! -d "$INSTALL_PATH" ]; then
        print_warning "Hadoop not deployed yet. Skipping validation."
        return
    fi
    
    # Source the environment
    if [ -f "$INSTALL_PATH/hadoop-env-setup.sh" ]; then
        source "$INSTALL_PATH/hadoop-env-setup.sh"
    fi
    
    # Check hadoop command
    if command -v hadoop &> /dev/null; then
        print_success "Hadoop command is available"
        hadoop version | head -n 1
    else
        print_error "Hadoop command not found in PATH"
    fi
    
    # Check configuration files
    local conf_dir="$INSTALL_PATH/etc/hadoop"
    for file in core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml; do
        if [ -f "$conf_dir/$file" ]; then
            print_success "Configuration file exists: $file"
        else
            print_warning "Configuration file missing: $file"
        fi
    done
    
    print_success "Validation complete"
}

################################################################################
# Print Usage Information
################################################################################

print_next_steps() {
    print_header "Next Steps"
    
    cat << EOF
Your Hadoop environment has been set up! Here's what to do next:

1. Configure your shell environment:
   ${GREEN}source $INSTALL_PATH/hadoop-env-setup.sh${NC}

2. Format the HDFS namenode (first time only):
   ${GREEN}hdfs namenode -format${NC}

3. Start HDFS:
   ${GREEN}start-dfs.sh${NC}

4. Verify HDFS is running:
   ${GREEN}hdfs dfsadmin -report${NC}
   Access HDFS Web UI at: ${BLUE}http://localhost:9870${NC}

5. Start YARN (optional):
   ${GREEN}start-yarn.sh${NC}
   Access YARN Web UI at: ${BLUE}http://localhost:8088${NC}

6. Run a test job:
   ${GREEN}hadoop jar \$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100${NC}

For more information, see:
- ${BLUE}LOCAL_SETUP.md${NC} - Comprehensive setup guide
- ${BLUE}BUILDING.txt${NC} - Build instructions
- ${BLUE}README.txt${NC} - General information

Troubleshooting:
- If you encounter SSH issues, set up passwordless SSH:
  ${GREEN}ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa${NC}
  ${GREEN}cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys${NC}
  ${GREEN}chmod 0600 ~/.ssh/authorized_keys${NC}

- If you get memory errors, increase Maven memory:
  ${GREEN}export MAVEN_OPTS="-Xms256m -Xmx2048m"${NC}

EOF
}

################################################################################
# Usage Information
################################################################################

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Hadoop Local Environment Setup Script

OPTIONS:
    -h, --help              Show this help message
    -b, --build-type TYPE   Build type: minimal, native, dist, full (default: minimal)
    -t, --run-tests         Run tests during build (default: skip tests)
    -d, --use-docker        Use Docker build environment
    -i, --install-path PATH Installation path (default: ~/hadoop-deploy)
    -s, --skip-build        Skip build step
    -c, --configure         Create sample configuration files
    -v, --validate          Validate installation

BUILD TYPES:
    minimal     Build without native libraries, tests, or documentation (fastest)
    native      Build with native libraries
    dist        Build distribution package
    full        Build full distribution with native libraries

EXAMPLES:
    # Quick build and deploy
    $0 -b dist -i ~/hadoop-local

    # Build with native libraries
    $0 -b native

    # Skip build and just configure
    $0 -s -c -i ~/hadoop-local

    # Full build with tests
    $0 -b full -t

EOF
    exit 0
}

################################################################################
# Main Script
################################################################################

main() {
    local skip_build=false
    local do_configure=false
    local do_validate=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -b|--build-type)
                BUILD_TYPE="$2"
                shift 2
                ;;
            -t|--run-tests)
                SKIP_TESTS=false
                shift
                ;;
            -d|--use-docker)
                USE_DOCKER=true
                shift
                ;;
            -i|--install-path)
                INSTALL_PATH="$2"
                shift 2
                ;;
            -s|--skip-build)
                skip_build=true
                shift
                ;;
            -c|--configure)
                do_configure=true
                shift
                ;;
            -v|--validate)
                do_validate=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                ;;
        esac
    done
    
    print_header "Hadoop Local Environment Setup"
    print_info "Script directory: $SCRIPT_DIR"
    print_info "Build type: $BUILD_TYPE"
    print_info "Install path: $INSTALL_PATH"
    print_info "Skip tests: $SKIP_TESTS"
    
    # Check prerequisites
    check_prerequisites
    
    # Build Hadoop
    if [ "$skip_build" = false ]; then
        build_hadoop
        deploy_hadoop
    else
        print_warning "Skipping build step"
    fi
    
    # Configure
    if [ "$do_configure" = true ]; then
        create_sample_config
    fi
    
    # Validate
    if [ "$do_validate" = true ]; then
        validate_installation
    fi
    
    # Print next steps
    print_next_steps
    
    print_success "Setup complete!"
}

# Run main function
main "$@"
