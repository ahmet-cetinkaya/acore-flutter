# Acore Package Scripts

This directory contains development scripts for the Acore package.

## Available Scripts

### `lint.sh`

Comprehensive linting script that runs multiple checks on the Acore package:

- **Flutter Analyze**: Static analysis of Dart/Flutter code
- **Dart Unused Files**: Scans for unused Dart files (requires
  `dart_unused_files`)
- **Test Verification**: Basic validation of test files structure
- **Markdown Lint**: Checks documentation formatting (requires
  `markdownlint-cli2`)
- **Pubspec Validation**: Validates pubspec.yaml format

### Usage

```bash
# Run comprehensive linting
./scripts/lint.sh

# Or use the pubspec script (if using dart pub with script support)
dart pub run lint
```

### Prerequisites

Optional tools for enhanced linting:

```bash
# Install dart_unused_files
dart pub global activate dart_unused_files

# Install markdownlint-cli2
npm install -g markdownlint-cli2
```

## Script Features

- **Colored Output**: Consistent color coding with main project scripts
- **Error Handling**: Continues running all linters and reports overall status
- **Graceful Degradation**: Skips linters if required tools are not installed
- **Package-Specific**: Tailored for Acore package structure and dependencies

## Output

- ✅ Green: Success
- ❌ Red: Error/Failure
- ⚠️ Yellow: Warning/Info
- 🔵 Blue: Informational messages

## Integration

The script is designed to work:

1. From within the Acore package directory
2. When called from the main WHPH project
3. In CI/CD pipelines for automated quality checks
