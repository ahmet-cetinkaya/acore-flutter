# Contributing to ACore Flutter

Thank you for your interest in contributing to ACore! This comprehensive core package provides reusable implementations, abstractions, and helper code snippets for Flutter applications. Your contributions help make ACore better for the entire Flutter community.

## 🎯 Project Overview

ACore is a minimal-dependency Flutter core package that provides:
- **Reusable UI Components** (DateTimePicker, NumericInput, etc.)
- **Dependency Injection** abstractions and implementations
- **Error Handling** business exception frameworks
- **File Utilities** for cross-platform file operations
- **Logging** abstractions and console implementations
- **Mapping** utilities for data transformation
- **Repository Pattern** abstractions
- **Sound Utilities** for audio operations
- **Storage** abstractions for local storage
- **Time & Date Utilities** for date manipulation
- **General Utilities** for collections, colors, and helpers

## 🛠️ Development Environment Setup

### Prerequisites
- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=3.5.3
- **Git**: For version control

### Initial Setup
1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/acore-flutter.git
   cd acore-flutter
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Tests**
   ```bash
   flutter test
   ```

4. **Check Code Formatting**
   ```bash
   flutter analyze
   ```

## 📁 Project Structure

```
lib/
├── acore.dart                 # Main export file
├── async/                     # Async utilities and helpers
├── components/                # Reusable UI components
│   └── date_time_picker/      # DateTime picker components
├── dependency_injection/      # DI container and abstractions
├── errors/                    # Business exception classes
├── extensions/                # Dart/Flutter extensions
├── file/                      # File operation utilities
├── logging/                   # Logging abstractions
├── mapper/                    # Data transformation utilities
├── queries/                   # Query models and helpers
├── repository/                # Repository pattern abstractions
├── sounds/                    # Audio utilities
├── storage/                   # Storage abstractions
├── time/                      # Time and date utilities
└── utils/                     # General utility functions
```

## 🎨 Code Style and Standards

### Core Principles
- **Minimal Dependencies**: Use Flutter/Dart core libraries when possible
- **Modularity**: Keep components focused and loosely coupled
- **Reusability**: Design for cross-platform compatibility
- **Performance**: Optimize for Flutter's widget tree and build cycles
- **Testability**: Write testable code with clear abstractions

### Code Style Guidelines

#### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `date_utils.dart`)
- **Classes**: `PascalCase` (e.g., `DateTimePickerField`)
- **Variables/Methods**: `camelCase` (e.g., `formatDate()`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `DEFAULT_DATE_FORMAT`)
- **Private members**: Prefix with `_` (e.g., `_internalMethod()`)

#### Dart/Flutter Best Practices
- Use `const` constructors wherever possible
- Prefer `StatelessWidget` over `StatefulWidget` when no state is needed
- Use `final` for immutable variables
- Implement proper error handling with try-catch blocks
- Use `async/await` instead of `.then()` for readability
- Follow SOLID principles (Single Responsibility, Open/Closed, etc.)

#### Widget Development
- Keep widgets focused and reusable
- Use parameter documentation with dartdoc comments
- Implement proper accessibility (semantics, labels)
- Use `Theme.of(context)` for styling consistency
- Provide sensible default values for optional parameters

#### Code Organization
```dart
// Example class structure
class ExampleWidget extends StatelessWidget {
  // Public constructor with named parameters
  const ExampleWidget({
    super.key,
    required this.title,
    this.onTap,
    this.style = defaultStyle,
  });

  // Public properties
  final String title;
  final VoidCallback? onTap;
  final TextStyle style;

  // Private constants
  static const defaultStyle = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## 🧪 Testing Guidelines

### Test Structure
```bash
test/
├── components/               # Widget tests for UI components
├── dependency_injection/    # DI container tests
├── errors/                  # Error handling tests
├── file/                    # File utility tests
├── logging/                 # Logger tests
├── mapper/                  # Mapper tests
├── repository/              # Repository tests
├── time/                    # Time utility tests
└── utils/                   # General utility tests
```

### Testing Requirements

#### Unit Tests
- Test all public methods and properties
- Cover edge cases and error conditions
- Use descriptive test names following `describe('when X', () { it('should Y', () {...}); })` pattern
- Mock external dependencies using `mockito` or manual mocks

#### Widget Tests
- Test widget rendering and interaction
- Verify accessibility properties
- Test different input states and configurations
- Use `pumpAndSettle()` for async operations

#### Integration Tests
- Test component integration scenarios
- Verify cross-platform compatibility
- Test real file operations and platform channels

### Example Test Structure
```dart
// test/components/date_time_picker_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:acore/components/date_time_picker.dart';

void main() {
  group('DateTimePickerField', () {
    testWidgets('should display current date when initialized', (tester) async {
      // Arrange
      const widget = DateTimePickerField();

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(DateTimePickerField), findsOneWidget);
    });

    testWidgets('should call onChanged when date is selected', (tester) async {
      // Test implementation
    });
  });
}
```

## 🔄 Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/bug-description
# or
git checkout -b docs/update-documentation
```

### 2. Development Steps
- Make your changes following the code style guidelines
- Add comprehensive tests for new functionality
- Ensure all existing tests pass: `flutter test`
- Run static analysis: `flutter analyze`
- Format your code: `dart format .`

### 3. Testing Requirements
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/components/date_time_picker_test.dart
```

### 4. Commit Guidelines
Follow [Conventional Commits](https://conventionalcommits.org/) specification:

- `feat:`: New features or functionality
- `fix:`: Bug fixes
- `docs:`: Documentation changes
- `style:`: Code style changes (formatting, etc.)
- `refactor:`: Code refactoring without functional changes
- `test:`: Adding or updating tests
- `chore:`: Maintenance tasks, dependency updates

Examples:
```bash
git commit -m "feat(date_picker): add quick range selection functionality"
git commit -m "fix(numeric_input): resolve decimal input validation issue"
git commit -m "docs(readme): update installation instructions"
```

### 5. Pull Request Process
1. **Create Pull Request** with clear title and description
2. **Link Issues**: Reference related issue numbers (e.g., "Fixes #123")
3. **Description**: Include:
   - What changes were made and why
   - How to test the changes
   - Any breaking changes or migration notes
   - Screenshots for UI changes
4. **Code Review**: Respond to review feedback promptly
5. **CI/CD**: Ensure all automated checks pass

## 📦 Package Management

### Dependencies
ACore maintains minimal external dependencies. Before adding new dependencies:

1. **Check if Flutter/Dart core libraries can solve the requirement**
2. **Evaluate package size and maintenance status**
3. **Consider impact on users of ACore**
4. **Add to `dev_dependencies` if only needed for development**

### Version Management
- Follow Semantic Versioning (SemVer)
- Update `pubspec.yaml` version for breaking changes
- Maintain backward compatibility when possible
- Document breaking changes in CHANGELOG

## 🐛 Bug Reporting

### Bug Report Template
Create issues with the following information:

```markdown
## Bug Description
Clear, concise description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Screenshots
Add screenshots if applicable

## Environment
- Flutter: [e.g., 3.16.0]
- Dart: [e.g., 3.2.0]
- ACore: [e.g., 1.0.0]
- Platform: [Android/iOS/Web/Desktop]

## Additional Context
Add any other context about the problem here
```

## 💡 Feature Requests

### Feature Request Template
```markdown
## Feature Description
Clear, concise description of the feature

## Problem Statement
What problem does this feature solve?

## Proposed Solution
How you envision implementing this feature

## Alternatives Considered
Other approaches you considered

## Breaking Changes
Will this introduce breaking changes?

## Additional Context
Any other relevant information or examples
```

## 🔍 Code Review Guidelines

### Reviewer Checklist
- [ ] Code follows project style guidelines
- [ ] Tests are comprehensive and passing
- [ ] Documentation is updated if needed
- [ ] Breaking changes are documented
- [ ] Performance impact is considered
- [ ] Security implications are evaluated
- [ ] Accessibility is maintained
- [ ] Platform compatibility is preserved

### Contributor Guidelines
- Address all review feedback constructively
- Explain complex logic in comments
- Update documentation for public APIs
- Consider edge cases and error handling
- Maintain backward compatibility

## 📚 Documentation

### Code Documentation
- Use dartdoc comments for all public APIs
- Include parameter descriptions and examples
- Document usage patterns and best practices
- Keep documentation up-to-date with code changes

### README Updates
- Update feature descriptions for new components
- Add installation instructions for new dependencies
- Include usage examples for new functionality
- Update API documentation links

## 🚀 Release Process

### Pre-Release Checklist
- [ ] All tests are passing
- [ ] Code coverage is adequate (>80%)
- [ ] Documentation is updated
- [ ] CHANGELOG is updated
- [ ] Version is bumped appropriately
- [ ] Examples are tested and working

### Release Types
- **Major (X.0.0)**: Breaking changes, significant new features
- **Minor (0.X.0)**: New features, backward compatible
- **Patch (0.0.X)**: Bug fixes, documentation updates

## 🤝 Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow professional communication standards

### Getting Help
- Check existing issues and documentation
- Ask questions in GitHub discussions
- Review similar components for patterns
- Contact maintainers for guidance

## 🏆 Recognition

Contributors are recognized for their valuable input:
- **Code Contributors**: Listed in README
- **Feature Ideas**: Credited in release notes
- **Bug Reports**: Acknowledged in issue resolution
- **Documentation**: Recognized in documentation updates

---

## 📞 Contact

For questions or support:
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For general questions and community support
- **Maintainer**: [ahmetcetinkaya](https://github.com/ahmet-cetinkaya)

Thank you for contributing to ACore! Your efforts help build better Flutter applications for everyone. 🚀