# OpenCode Global Guidelines

## General Principles

### Code Quality
- Write clean, readable, and maintainable code
- Follow established patterns and conventions for each language/framework
- Prefer simplicity over complexity
- Use meaningful and descriptive names for variables, functions, and files
- Write self-documenting code when possible

### Project Structure
- Organize code logically by feature or domain
- Keep related files close together
- Separate concerns appropriately
- Maintain a consistent directory structure within the project
- Use clear separation between source code, tests, configuration, and build artifacts

### Code Organization
- Keep functions and methods focused on a single responsibility
- Limit file size to improve readability
- Group related functionality together
- Minimize dependencies between modules
- Use appropriate abstraction levels

## Testing & Quality Assurance

### Testing Principles
- Write tests for new functionality
- Prefer unit tests for isolated logic
- Write integration tests for component interactions
- Write end-to-end tests for critical user journeys
- Test edge cases and error conditions
- Avoid testing implementation details
- Mock external dependencies appropriately

### Quality Practices
- Run tests before committing changes
- Maintain test coverage for critical paths
- Use static analysis tools where available
- Perform code reviews for significant changes
- Refactor code to improve clarity and maintainability

## Version Control

### Git Best Practices
- Write clear, descriptive commit messages
- Follow conventional commits when possible
- Keep commits focused and atomic
- Use feature branches for new work
- Regularly sync with remote repositories
- Use meaningful branch names
- Review changes before committing

### Collaboration
- Use pull requests for code review
- Provide context in PR descriptions
- Request reviews from appropriate team members
- Address review feedback promptly
- Keep PRs manageable in size

## Security

### General Security
- Never commit secrets, API keys, or credentials
- Use environment variables for configuration
- Validate and sanitize all user input
- Follow the principle of least privilege
- Keep dependencies updated to address security vulnerabilities
- Use secure communication protocols (HTTPS, TLS)

### Data Protection
- Handle sensitive data with care
- Implement proper authentication and authorization
- Log security-relevant events appropriately
- Follow data protection regulations and best practices

## Performance

### Code Performance
- Write efficient algorithms and data structures
- Avoid unnecessary computations
- Use appropriate caching strategies
- Optimize critical paths
- Profile code to identify bottlenecks

### System Performance
- Minimize resource usage (CPU, memory, disk, network)
- Implement lazy loading for heavy resources
- Optimize bundle sizes where applicable
- Monitor and optimize network requests
- Use appropriate compression techniques

## Documentation

### Code Documentation
- Document public APIs and complex logic
- Keep documentation up to date with code changes
- Use appropriate documentation tools for the language/framework
- Include examples for complex functionality
- Document architectural decisions and trade-offs

### Project Documentation
- Maintain current README files
- Document setup and development procedures
- Keep architecture diagrams updated
- Document deployment and operations procedures
- Maintain changelogs for significant releases

## Development Workflow

### Local Development
- Use consistent development environments
- Follow project-specific setup instructions
- Use local development servers where appropriate
- Test changes thoroughly before committing

### Code Review Process
- Review your own code before submitting
- Check for common issues and improvements
- Ensure tests pass and new tests are added
- Verify compliance with project guidelines

## Maintenance & Operations

### Code Maintenance
- Regularly update dependencies
- Refactor code to reduce technical debt
- Remove unused code and dependencies
- Update documentation alongside code changes

### Operational Considerations
- Design for observability (logging, monitoring, tracing)
- Implement proper error handling and recovery
- Consider scalability and performance implications
- Plan for maintenance and future enhancements