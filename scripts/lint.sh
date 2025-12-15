#!/bin/bash

# Comprehensive linting script for Acore Package
# Runs Flutter analyze, dart_unused_files, and markdownlint
# Usage: ./scripts/lint.sh

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACORE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=./_common.sh
source "$SCRIPT_DIR/_common.sh"

print_header "ACORE PACKAGE LINTER"

# Change to acore directory
cd "$ACORE_DIR"
print_info "Working in: $(pwd)"
print_divider

# Track overall success
OVERALL_SUCCESS=true

# Function to run a linter and track success
run_linter() {
    local linter_name="$1"
    local linter_command="$2"
    local working_dir="$3"

    print_section "🔍 Running $linter_name..."

    if [[ -n "$working_dir" ]]; then
        cd "$working_dir"
    fi

    if eval "$linter_command"; then
        print_success "✅ $linter_name passed"
        if [[ -n "$working_dir" ]]; then
            cd "$ACORE_DIR"
        fi
        return 0
    else
        print_error "❌ $linter_name failed"
        if [[ -n "$working_dir" ]]; then
            cd "$ACORE_DIR"
        fi
        OVERALL_SUCCESS=false
        return 1
    fi
}

# 1. Flutter analyze (try fvm first, then flutter)
if command -v fvm &>/dev/null; then
    run_linter "Flutter Analyze" "fvm flutter analyze" "" || true
elif command -v flutter &>/dev/null; then
    run_linter "Flutter Analyze" "flutter analyze" "" || true
else
    print_warning "⚠️ Flutter command not found, skipping Flutter analyze"
    print_info "Install Flutter or ensure fvm is available"
fi

# 2. dart_unused_files scan (package-specific)
if command -v dart_unused_files &>/dev/null; then
    run_linter "Dart Unused Files" "dart_unused_files scan" "" || true
else
    print_warning "⚠️ dart_unused_files not found, skipping unused files analysis"
    print_info "Install with: dart pub global activate dart_unused_files"
fi

# 3. Test verification (basic check)
if [[ -d "test" ]]; then
    print_section "🧪 Running Test Verification..."

    # Check if test files can be parsed
    test_files=$(find test -name "*.dart" 2>/dev/null | wc -l)
    if [[ $test_files -gt 0 ]]; then
        print_info "Found $test_files test file(s)"

        # Try to run test analysis (not actual tests, just parsing)
        if dart analyze test/; then
            print_success "✅ Test files analysis passed"
        else
            print_error "❌ Test files analysis failed"
            OVERALL_SUCCESS=false
        fi
    else
        print_warning "⚠️ No test files found"
    fi
else
    print_warning "⚠️ No test directory found"
fi

# 4. markdownlint for documentation
if [[ -d "docs" ]]; then
    if command -v markdownlint-cli2 &>/dev/null; then
        run_linter "Markdown Lint" "markdownlint-cli2 --fix \"docs/**/*.md\"" "" || true
    else
        print_warning "⚠️ markdownlint-cli2 not found, skipping markdown linting"
        print_info "Install with: npm install -g markdownlint-cli2"
    fi
else
    print_info "No docs directory found, skipping markdown linting"
fi

# 5. Check pubspec.yaml format
print_section "📋 Checking pubspec.yaml..."
if command -v fvm &>/dev/null; then
    if fvm flutter pub get --dry-run &>/dev/null; then
        print_success "✅ pubspec.yaml format is valid"
    else
        print_error "❌ pubspec.yaml has issues"
        OVERALL_SUCCESS=false
    fi
elif command -v flutter &>/dev/null; then
    if flutter pub get --dry-run &>/dev/null; then
        print_success "✅ pubspec.yaml format is valid"
    else
        print_error "❌ pubspec.yaml has issues"
        OVERALL_SUCCESS=false
    fi
else
    print_warning "⚠️ Flutter command not found, skipping pubspec.yaml validation"
    print_info "Install Flutter or ensure fvm is available"
fi

# Final result
print_divider
echo

# Summary section
print_section "📊 LINTING SUMMARY"
echo "Package: acore"
echo "Working Directory: $(pwd)"
echo "Status: $($OVERALL_SUCCESS && echo 'PASSED' || echo 'FAILED')"

if $OVERALL_SUCCESS; then
    print_header "✅ ALL LINTERS PASSED!"
    print_divider_char "=" 70
    print_success "🎉 The acore package is ready for development!"
else
    print_header "❌ SOME LINTERS FAILED!"
    print_divider_char "!" 70
    print_error "🔧 Please fix the issues above before continuing"
fi

# Exit with appropriate code
$OVERALL_SUCCESS && exit 0 || exit 1
