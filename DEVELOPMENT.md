# Development Workflow Guide

This guide outlines best practices and workflows for developing with your forked Hadoop repository.

## Table of Contents

1. [Setting Up Your Development Environment](#setting-up-your-development-environment)
2. [Branch Management](#branch-management)
3. [Making Changes](#making-changes)
4. [Testing Your Changes](#testing-your-changes)
5. [Code Quality](#code-quality)
6. [Contributing Back](#contributing-back)
7. [Common Development Tasks](#common-development-tasks)

## Setting Up Your Development Environment

### Initial Setup

1. **Clone and configure your fork:**
   ```bash
   git clone https://github.com/CatoHomeOne/hadoop.git
   cd hadoop
   
   # Add upstream remote to track Apache Hadoop
   git remote add upstream https://github.com/apache/hadoop.git
   git fetch upstream
   ```

2. **Verify your environment:**
   ```bash
   ./validate-environment.sh
   ```

3. **Do an initial build:**
   ```bash
   # First time build to populate local Maven cache
   mvn clean install -DskipTests -DskipShade
   ```

### IDE Configuration

#### IntelliJ IDEA

```bash
# Build first to generate required files
mvn clean install -DskipTests -DskipShade

# Then import as Maven project
# File → Open → Select hadoop directory
# IntelliJ will automatically detect Maven structure
```

Configuration:
- Enable annotation processing: Settings → Build → Compiler → Annotation Processors
- Set JDK: Project Structure → SDKs → Add JDK 8 or 11
- Increase IDE memory: Help → Edit Custom VM Options → `-Xmx4096m`

#### VS Code

Install extensions:
- Java Extension Pack
- Maven for Java
- Language Support for Java

```bash
# Open the project
code .

# VS Code will automatically detect Maven project
```

#### Eclipse

```bash
# Build artifacts first
mvn clean install -DskipTests -DskipShade

# Then import
# File → Import → Maven → Existing Maven Projects
# Select hadoop directory
```

## Branch Management

### Creating Feature Branches

Always work on feature branches, never directly on trunk/main:

```bash
# Update your local trunk
git checkout trunk
git fetch upstream
git merge upstream/trunk
git push origin trunk

# Create feature branch
git checkout -b feature/my-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### Branch Naming Conventions

Use descriptive branch names:
- `feature/add-new-functionality` - For new features
- `fix/hdfs-datanode-issue` - For bug fixes
- `improvement/optimize-mapper` - For improvements
- `docs/update-readme` - For documentation
- `test/add-unit-tests` - For test additions

### Keeping Branches Updated

```bash
# Regularly sync with upstream
git checkout trunk
git fetch upstream
git merge upstream/trunk

# Rebase your feature branch
git checkout feature/my-feature
git rebase trunk

# If conflicts occur, resolve them and continue
git add .
git rebase --continue
```

## Making Changes

### Development Workflow

1. **Make small, focused changes:**
   ```bash
   # Edit files
   vim hadoop-common-project/hadoop-common/src/main/java/...
   
   # Build affected module
   cd hadoop-common-project/hadoop-common
   mvn clean install -DskipTests
   ```

2. **Test as you go:**
   ```bash
   # Run specific tests
   mvn test -Dtest=TestClassName
   
   # Or test a single method
   mvn test -Dtest=TestClassName#methodName
   ```

3. **Commit frequently:**
   ```bash
   git add <changed-files>
   git commit -m "Brief description of change"
   ```

### Commit Message Guidelines

Follow these conventions:

```
Short (50 chars or less) summary

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. The blank line separating the summary from the body
is critical.

Further paragraphs come after blank lines.

- Bullet points are okay, too
- Use a hyphen or asterisk for the bullet

Fixes #123
```

Example:
```
HDFS-12345. Fix DataNode memory leak in BlockReceiver

The BlockReceiver was not properly closing file streams in certain
error conditions, leading to a slow memory leak. This patch ensures
all streams are closed in a finally block.

Added unit test to verify the fix.
```

## Testing Your Changes

### Unit Tests

```bash
# Run all tests in a module
cd hadoop-hdfs-project/hadoop-hdfs
mvn test

# Run specific test class
mvn test -Dtest=TestDataNode

# Run specific test method
mvn test -Dtest=TestDataNode#testSpecificMethod

# Run tests with additional logging
mvn test -Dtest=TestClassName -X
```

### Integration Tests

```bash
# Run integration tests (may take longer)
mvn verify

# Run with native code tests
mvn test -Pnative
```

### Testing Your Build

```bash
# Build distribution to test
mvn package -Pdist -DskipTests -Dtar

# Extract and test
cd hadoop-dist/target
tar -xzf hadoop-*.tar.gz
cd hadoop-*

# Run example jobs
./bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100
```

### Manual Testing Checklist

Before submitting changes:

- [ ] Unit tests pass
- [ ] Integration tests pass (if applicable)
- [ ] Code compiles without warnings
- [ ] Checkstyle passes
- [ ] Spotbugs/FindBugs passes
- [ ] Documentation updated (if needed)
- [ ] Example code works (if applicable)
- [ ] No unintended changes included

## Code Quality

### Running Code Quality Checks

```bash
# Run all checks at once
mvn verify

# Individual checks:

# Checkstyle (code style)
mvn checkstyle:checkstyle

# SpotBugs (static analysis)
mvn compile spotbugs:spotbugs

# PMD (code quality)
mvn pmd:pmd

# Check for license headers
mvn apache-rat:check
```

### Viewing Reports

Reports are generated in `target/site/`:
- Checkstyle: `target/site/checkstyle.html`
- SpotBugs: `target/site/spotbugs.html`
- PMD: `target/site/pmd.html`

### Fixing Common Issues

**Checkstyle violations:**
```bash
# Auto-format code (if using IDE)
# IntelliJ: Code → Reformat Code
# Eclipse: Source → Format

# Or use Maven plugins
mvn spotless:apply  # If configured
```

**Import organization:**
- Keep imports organized alphabetically
- Remove unused imports
- Use wildcard imports sparingly

**Javadoc:**
- Add Javadoc to all public methods
- Include `@param`, `@return`, `@throws` tags
- Describe what the method does, not how

## Contributing Back

### Preparing for Pull Request

1. **Ensure your branch is up to date:**
   ```bash
   git checkout trunk
   git pull upstream trunk
   git checkout feature/my-feature
   git rebase trunk
   ```

2. **Squash commits if needed:**
   ```bash
   # Combine last 3 commits
   git rebase -i HEAD~3
   
   # In editor, change 'pick' to 'squash' for commits to combine
   ```

3. **Run full test suite:**
   ```bash
   mvn clean verify
   ```

4. **Push to your fork:**
   ```bash
   git push origin feature/my-feature
   ```

### Creating Pull Request

1. Go to your fork on GitHub
2. Click "Pull Request"
3. Select your feature branch
4. Write clear PR description:
   - What problem does it solve?
   - How does it solve it?
   - What testing was done?
   - Any breaking changes?

### PR Template

```markdown
## Description
Brief description of the change

## Motivation
Why is this change needed?

## Changes
- Change 1
- Change 2
- Change 3

## Testing
How was this tested?
- [ ] Unit tests added/updated
- [ ] Integration tests passed
- [ ] Manual testing performed

## Checklist
- [ ] Code compiles
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Checkstyle passes
- [ ] Commits are squashed appropriately
```

## Common Development Tasks

### Building Specific Modules

```bash
# Build only HDFS
cd hadoop-hdfs-project
mvn clean install -DskipTests

# Build only YARN
cd hadoop-yarn-project
mvn clean install -DskipTests

# Build only MapReduce
cd hadoop-mapreduce-project
mvn clean install -DskipTests

# Build only Common
cd hadoop-common-project
mvn clean install -DskipTests
```

### Working with Native Code

```bash
# Build with native libraries
mvn package -Pnative -DskipTests

# Run native tests
mvn test -Pnative -Dtest=allNative

# Check native library
hadoop checknative -a
```

### Debugging

#### Remote Debugging

Add to your Maven command:
```bash
mvn test -Dmaven.surefire.debug
# Then connect debugger to port 5005
```

Or for applications:
```bash
export HADOOP_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
hadoop jar my-app.jar
```

#### Logging

Increase logging level:
```bash
# Edit $HADOOP_HOME/etc/hadoop/log4j.properties
log4j.logger.org.apache.hadoop=DEBUG

# Or for specific class
log4j.logger.org.apache.hadoop.hdfs.server.datanode.DataNode=DEBUG
```

### Performance Testing

```bash
# HDFS performance test
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar TestDFSIO -write -nrFiles 10 -fileSize 1GB

# Read test
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar TestDFSIO -read -nrFiles 10 -fileSize 1GB

# MapReduce benchmark
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar teragen 10000000 /teragen-out
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar terasort /teragen-out /terasort-out
```

### Documentation

```bash
# Build documentation
mvn clean site -Preleasedocs,docs

# View in browser
# Open hadoop-project-dist/hadoop-common/target/site/index.html
```

### Release Management

```bash
# Change version
mvn versions:set -DnewVersion=3.5.1-SNAPSHOT

# Create release candidate
mvn package -Pdist,native,src -DskipTests -Dtar

# Sign release (if you're a committer)
gpg --armor --detach-sig hadoop-*.tar.gz
```

## Best Practices

### Code Style

1. Follow existing code style in the file
2. Use meaningful variable names
3. Keep methods short and focused
4. Add comments for complex logic
5. Write self-documenting code

### Testing

1. Write tests before code (TDD)
2. Test edge cases and error conditions
3. Use descriptive test names
4. Keep tests fast and independent
5. Mock external dependencies

### Performance

1. Profile before optimizing
2. Avoid premature optimization
3. Document performance-critical code
4. Add performance tests for critical paths
5. Consider memory and CPU usage

### Security

1. Validate all inputs
2. Use secure defaults
3. Follow principle of least privilege
4. Document security implications
5. Never commit credentials

## Troubleshooting Development Issues

### Build Failures

```bash
# Clean everything
mvn clean
rm -rf ~/.m2/repository/org/apache/hadoop

# Rebuild
mvn clean install -DskipTests

# If out of memory
export MAVEN_OPTS="-Xms512m -Xmx3072m"
```

### Test Failures

```bash
# Run with more logging
mvn test -Dtest=FailingTest -X

# Check logs
ls -la target/surefire-reports/

# Run in isolation
mvn test -Dtest=FailingTest -DfailIfNoTests=false
```

### IDE Issues

```bash
# Regenerate IDE files
mvn eclipse:eclipse  # For Eclipse
mvn idea:idea        # For IntelliJ (older)

# Or reimport Maven project
```

## Resources

- **Apache Hadoop Wiki**: https://cwiki.apache.org/confluence/display/HADOOP
- **JIRA Issue Tracker**: https://issues.apache.org/jira/browse/HADOOP
- **Mailing Lists**: https://hadoop.apache.org/mailing_lists.html
- **Code Review**: https://reviews.apache.org/
- **Contributing Guide**: https://cwiki.apache.org/confluence/display/HADOOP/HowToContribute

## Getting Help

1. Check existing documentation
2. Search JIRA for similar issues
3. Ask on mailing lists
4. Join community Slack/IRC channels
5. Attend community meetings

---

Happy developing! 🚀
