#!/bin/bash

################################################################################
# Hadoop Environment Validation Script
# 
# This script validates that your environment is properly configured for
# building and running Hadoop
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}========================================"
    echo -e "$1"
    echo -e "========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((ISSUES_FOUND++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

version_compare() {
    # Returns 0 if $1 >= $2
    if [[ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" == "$2" ]]; then
        return 0
    else
        return 1
    fi
}

################################################################################
# Check Java
################################################################################

check_java() {
    print_header "Java Environment"
    
    if check_command java; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        print_success "Java is installed"
        print_info "Version: $JAVA_VERSION"
        
        # Check Java version (should be 8 or 11+)
        JAVA_MAJOR=$(echo $JAVA_VERSION | cut -d'.' -f1)
        if [[ "$JAVA_MAJOR" == "1" ]]; then
            JAVA_MAJOR=$(echo $JAVA_VERSION | cut -d'.' -f2)
        fi
        
        if [[ "$JAVA_MAJOR" -eq 8 ]] || [[ "$JAVA_MAJOR" -ge 11 ]]; then
            print_success "Java version is compatible"
        else
            print_warning "Java version should be 8 or 11+. Current: $JAVA_VERSION"
        fi
        
        # Check JAVA_HOME
        if [[ -n "$JAVA_HOME" ]]; then
            print_success "JAVA_HOME is set: $JAVA_HOME"
            if [[ -f "$JAVA_HOME/bin/java" ]]; then
                print_success "JAVA_HOME points to a valid Java installation"
            else
                print_error "JAVA_HOME does not point to a valid Java installation"
            fi
        else
            print_warning "JAVA_HOME is not set (recommended to set it)"
            print_info "Add to your shell profile: export JAVA_HOME=/path/to/java"
        fi
    else
        print_error "Java is not installed"
        print_info "Install Java 8 or 11+:"
        print_info "  Ubuntu/Debian: sudo apt-get install openjdk-11-jdk"
        print_info "  RHEL/CentOS: sudo yum install java-11-openjdk-devel"
        print_info "  macOS: brew install openjdk@11"
    fi
}

################################################################################
# Check Maven
################################################################################

check_maven() {
    print_header "Maven Environment"
    
    if check_command mvn; then
        MVN_VERSION=$(mvn -version | head -n 1 | awk '{print $3}')
        print_success "Maven is installed"
        print_info "Version: $MVN_VERSION"
        
        # Check Maven version (should be 3.3+)
        if version_compare "$MVN_VERSION" "3.3"; then
            print_success "Maven version is compatible (3.3+)"
        else
            print_error "Maven version should be 3.3 or later. Current: $MVN_VERSION"
            print_info "Upgrade Maven: https://maven.apache.org/download.cgi"
        fi
        
        # Check MAVEN_OPTS
        if [[ -n "$MAVEN_OPTS" ]]; then
            print_success "MAVEN_OPTS is set: $MAVEN_OPTS"
        else
            print_warning "MAVEN_OPTS is not set (recommended for better performance)"
            print_info "Add to your shell profile: export MAVEN_OPTS=\"-Xms256m -Xmx2048m\""
        fi
        
        # Check Maven local repository
        MVN_REPO=$(mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout 2>/dev/null || echo "$HOME/.m2/repository")
        print_info "Maven local repository: $MVN_REPO"
        if [[ -d "$MVN_REPO" ]]; then
            REPO_SIZE=$(du -sh "$MVN_REPO" 2>/dev/null | cut -f1)
            print_info "Repository size: $REPO_SIZE"
        fi
    else
        print_error "Maven is not installed"
        print_info "Install Maven:"
        print_info "  Ubuntu/Debian: sudo apt-get install maven"
        print_info "  RHEL/CentOS: sudo yum install maven"
        print_info "  macOS: brew install maven"
    fi
}

################################################################################
# Check Git
################################################################################

check_git() {
    print_header "Git Environment"
    
    if check_command git; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        print_success "Git is installed"
        print_info "Version: $GIT_VERSION"
        
        # Check if we're in a git repository
        if git rev-parse --git-dir > /dev/null 2>&1; then
            print_success "Current directory is a Git repository"
            
            # Check remote
            if git remote -v | grep -q "origin"; then
                ORIGIN_URL=$(git remote get-url origin)
                print_success "Git remote 'origin' is configured"
                print_info "Origin: $ORIGIN_URL"
            else
                print_warning "Git remote 'origin' is not configured"
            fi
            
            # Check current branch
            CURRENT_BRANCH=$(git branch --show-current)
            print_info "Current branch: $CURRENT_BRANCH"
            
            # Check for uncommitted changes
            if git diff-index --quiet HEAD --; then
                print_success "No uncommitted changes"
            else
                print_warning "There are uncommitted changes"
            fi
        else
            print_warning "Current directory is not a Git repository"
        fi
        
        # Check Git user config
        if git config user.name > /dev/null 2>&1; then
            print_success "Git user.name is configured: $(git config user.name)"
        else
            print_warning "Git user.name is not configured"
            print_info "Set with: git config --global user.name \"Your Name\""
        fi
        
        if git config user.email > /dev/null 2>&1; then
            print_success "Git user.email is configured: $(git config user.email)"
        else
            print_warning "Git user.email is not configured"
            print_info "Set with: git config --global user.email \"your.email@example.com\""
        fi
    else
        print_error "Git is not installed"
        print_info "Install Git:"
        print_info "  Ubuntu/Debian: sudo apt-get install git"
        print_info "  RHEL/CentOS: sudo yum install git"
        print_info "  macOS: brew install git"
    fi
}

################################################################################
# Check Docker
################################################################################

check_docker() {
    print_header "Docker Environment (Optional)"
    
    if check_command docker; then
        DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
        print_success "Docker is installed"
        print_info "Version: $DOCKER_VERSION"
        
        # Check if Docker daemon is running
        if docker info > /dev/null 2>&1; then
            print_success "Docker daemon is running"
            
            # Check Docker permissions
            if docker ps > /dev/null 2>&1; then
                print_success "Current user has Docker permissions"
            else
                print_warning "Current user might not have Docker permissions"
                print_info "Add user to docker group: sudo usermod -aG docker \$USER"
            fi
        else
            print_warning "Docker daemon is not running"
            print_info "Start Docker: sudo systemctl start docker"
        fi
    else
        print_info "Docker is not installed (optional, but recommended)"
        print_info "Docker simplifies building Hadoop with all dependencies"
        print_info "Install Docker: https://docs.docker.com/get-docker/"
    fi
}

################################################################################
# Check System Resources
################################################################################

check_system_resources() {
    print_header "System Resources"
    
    # Check available memory
    if check_command free; then
        TOTAL_MEM=$(free -g | awk '/^Mem:/ {print $2}')
        AVAIL_MEM=$(free -g | awk '/^Mem:/ {print $7}')
        print_info "Total memory: ${TOTAL_MEM}GB"
        print_info "Available memory: ${AVAIL_MEM}GB"
        
        if [[ "$AVAIL_MEM" -lt 4 ]]; then
            print_warning "Available memory is less than 4GB. Build might be slow."
            print_info "Consider increasing MAVEN_OPTS: export MAVEN_OPTS=\"-Xms256m -Xmx1536m\""
        else
            print_success "Sufficient memory available"
        fi
    fi
    
    # Check available disk space
    if check_command df; then
        DISK_AVAIL=$(df -h . | awk 'NR==2 {print $4}')
        print_info "Available disk space in current directory: $DISK_AVAIL"
        
        DISK_AVAIL_GB=$(df -BG . | awk 'NR==2 {print $4}' | tr -d 'G')
        if [[ "$DISK_AVAIL_GB" -lt 20 ]]; then
            print_warning "Less than 20GB disk space available"
            print_info "Hadoop build requires significant disk space"
        else
            print_success "Sufficient disk space available"
        fi
    fi
    
    # Check CPU cores
    if check_command nproc; then
        CPU_CORES=$(nproc)
        print_info "CPU cores: $CPU_CORES"
        print_success "Maven will use multiple cores for parallel builds"
    fi
}

################################################################################
# Check Build Dependencies
################################################################################

check_build_dependencies() {
    print_header "Build Dependencies (Optional)"
    
    # These are optional but recommended for native builds
    
    if check_command cmake; then
        CMAKE_VERSION=$(cmake --version | head -n 1 | awk '{print $3}')
        print_success "CMake is installed: $CMAKE_VERSION"
    else
        print_info "CMake is not installed (needed for native builds)"
    fi
    
    if check_command protoc; then
        PROTOC_VERSION=$(protoc --version | awk '{print $2}')
        print_success "Protocol Buffers is installed: $PROTOC_VERSION"
    else
        print_info "Protocol Buffers is not installed (needed for native builds)"
    fi
    
    if check_command gcc; then
        GCC_VERSION=$(gcc --version | head -n 1 | awk '{print $NF}')
        print_success "GCC is installed: $GCC_VERSION"
    else
        print_info "GCC is not installed (needed for native builds)"
    fi
    
    print_info "Native builds are optional. You can build Hadoop without them."
    print_info "To build with native support, see BUILDING.txt for requirements."
}

################################################################################
# Check SSH Configuration
################################################################################

check_ssh() {
    print_header "SSH Configuration (For Running Hadoop)"
    
    if check_command ssh; then
        print_success "SSH is installed"
        
        # Check if SSH key exists
        if [[ -f "$HOME/.ssh/id_rsa" ]] || [[ -f "$HOME/.ssh/id_ed25519" ]]; then
            print_success "SSH key exists"
            
            # Check if passwordless SSH to localhost works
            if ssh -o BatchMode=yes -o ConnectTimeout=5 localhost "echo 2>&1" > /dev/null 2>&1; then
                print_success "Passwordless SSH to localhost is configured"
            else
                print_warning "Passwordless SSH to localhost is not configured"
                print_info "This is needed to run Hadoop services"
                print_info "Set up with:"
                print_info "  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
                print_info "  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
                print_info "  chmod 0600 ~/.ssh/authorized_keys"
            fi
        else
            print_warning "SSH key not found"
            print_info "Generate SSH key for Hadoop:"
            print_info "  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
        fi
    else
        print_warning "SSH is not installed (needed for running Hadoop)"
        print_info "Install SSH:"
        print_info "  Ubuntu/Debian: sudo apt-get install openssh-client openssh-server"
        print_info "  RHEL/CentOS: sudo yum install openssh-clients openssh-server"
    fi
}

################################################################################
# Check Hadoop Installation
################################################################################

check_hadoop_installation() {
    print_header "Hadoop Installation"
    
    if check_command hadoop; then
        print_success "Hadoop command is available"
        HADOOP_VERSION=$(hadoop version 2>/dev/null | head -n 1 || echo "Unable to determine version")
        print_info "Version: $HADOOP_VERSION"
        
        if [[ -n "$HADOOP_HOME" ]]; then
            print_success "HADOOP_HOME is set: $HADOOP_HOME"
            
            if [[ -d "$HADOOP_HOME" ]]; then
                print_success "HADOOP_HOME directory exists"
                
                # Check for key directories
                for dir in bin sbin etc/hadoop share/hadoop; do
                    if [[ -d "$HADOOP_HOME/$dir" ]]; then
                        print_success "Directory exists: $dir"
                    else
                        print_warning "Directory missing: $dir"
                    fi
                done
            else
                print_error "HADOOP_HOME directory does not exist"
            fi
        else
            print_warning "HADOOP_HOME is not set"
        fi
        
        if [[ -n "$HADOOP_CONF_DIR" ]]; then
            print_info "HADOOP_CONF_DIR: $HADOOP_CONF_DIR"
        fi
    else
        print_info "Hadoop is not installed yet (expected if you haven't built it)"
        print_info "Build and deploy Hadoop using: ./setup-local-env.sh -b dist"
    fi
}

################################################################################
# Summary
################################################################################

print_summary() {
    print_header "Validation Summary"
    
    if [[ $ISSUES_FOUND -eq 0 ]]; then
        print_success "All critical checks passed!"
        echo -e "${GREEN}Your environment is ready for Hadoop development.${NC}"
    else
        print_warning "Found $ISSUES_FOUND issue(s) that need attention"
        echo -e "${YELLOW}Please review the warnings and errors above.${NC}"
    fi
    
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo "1. Review any warnings or errors above"
    echo "2. Build Hadoop: ./setup-local-env.sh -b dist"
    echo "3. Read LOCAL_SETUP.md for detailed instructions"
    echo "4. Configure Hadoop: ./setup-local-env.sh -c -i ~/hadoop-deploy"
    echo "5. Start using Hadoop!"
    echo ""
}

################################################################################
# Main Script
################################################################################

main() {
    print_header "Hadoop Environment Validation"
    
    check_java
    check_maven
    check_git
    check_docker
    check_system_resources
    check_build_dependencies
    check_ssh
    check_hadoop_installation
    
    print_summary
}

# Run main function
main "$@"
