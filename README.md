# Playwright Cross-Browser Test Comparison Tool

A Perl utility for comparing Playwright test results across different browsers and browser versions to detect compatibility issues and regressions.

**This tool was specifically designed for and used with Playwright** to test web frameworks across multiple browser engines and versions.

Copyright (c) 2024 Maxim Masiutin

## Overview

This tool compares two test output files to identify which tests changed status (passed↔failed), making it ideal for:
- **Cross-browser compatibility testing** (Chrome vs Firefox vs Safari)
- **Browser version regression testing** (New Chrome vs Old Chrome)
- **Web framework validation** across different browser engines
- **Sencha ExtJS testing with Playwright** across multiple toolkits and browsers

## Features

- **Regression Detection**: Identify tests that changed status between runs
- **Emoji-Based Format**: Human-readable output using 📙 for test suites, ✔️ for passes, 💣 for failures
- **Smart Comparison**: Order-independent comparison with normalized sorting
- **Detailed Diffs**: Generates separate files showing only the differences
- **UTF-8 Support**: Proper handling of Unicode emoji characters

## Installation

Requires Perl and the `File::Slurp` module:

```bash
cpan File::Slurp
```

## Usage

```bash
perl compare-test-results.pl <first_file> <second_file>
```

### Example Workflow

```bash
# Baseline test run
npx playwright test --reporter=./custom-emoji-reporter.js > baseline.txt

# After code changes
npx playwright test --reporter=./custom-emoji-reporter.js > current.txt

# Compare to find regressions
perl compare-test-results.pl baseline.txt current.txt
```

### Output

When differences are found, the script generates:
- `<filename>.out` - Test results showing only differences
- `<filename>.leftovers` - Unparsed lines for debugging

If test results are identical, the script reports success and generates no files.

## Expected Input Format

The script parses emoji-based test output where 📙 marks Playwright `test.describe()` blocks:

```
📙 User Authentication
  ✔️ Passed: should login successfully
  💣 Failed: should handle invalid credentials

📙 Shopping Cart
  ✔️ Passed: should add items to cart
```

## Custom Playwright Reporter

To generate compatible output, create a custom Playwright reporter:

```javascript
// custom-emoji-reporter.js
class EmojiReporter {
  onTestEnd(test, result) {
    const titlePath = test.titlePath();
    const suiteName = titlePath.slice(1, -1).join(' > ');
    const testName = titlePath[titlePath.length - 1];

    console.log(`📙 ${suiteName}`);

    if (result.status === 'passed') {
      console.log(`  ✔️ Passed: ${testName}`);
    } else if (result.status === 'failed') {
      console.log(`  💣 Failed: ${testName}`);
    }
  }
}

module.exports = EmojiReporter;
```

## Use Cases

### Web Framework & Library Development
- **Browser Version Regression Testing**: Compare test results between browser versions (Chrome 120 vs Chrome 119) to catch breaking changes
- **Cross-Browser Compatibility Validation**: Ensure your framework/library works consistently across Chromium, Firefox, and WebKit
- **Browser Update Impact Analysis**: Quickly identify which features broke when users upgrade their browsers
- **Framework Release Validation**: Verify new framework versions don't introduce browser-specific bugs

### QA & Testing Teams
- **Automated Cross-Browser Test Comparison**: Compare test suites across different browser engines in CI/CD pipelines
- **Regression Detection**: Identify tests that started failing after code changes or browser updates
- **Test Suite Maintenance**: Track which tests behave differently across browsers and prioritize fixes
- **Release Confidence**: Verify release candidates pass the same tests as previous versions across all browsers

### Enterprise Application Testing
- **Multi-Browser Support Verification**: Ensure enterprise web apps work on all employee browser configurations
- **Legacy Browser Testing**: Compare behavior between modern and older browser versions your users still run
- **Browser Deprecation Planning**: Identify which features will break when dropping support for older browsers
- **Vendor Browser Testing**: Test compatibility across browser vendors (Google Chrome, Mozilla Firefox, Apple Safari)

### Open Source Projects
- **Contributor Testing**: Allow contributors to quickly verify their changes don't break cross-browser compatibility
- **Issue Triage**: Identify if bug reports are browser-specific or affect all browsers
- **Documentation**: Generate browser compatibility matrices from test results
- **Community Testing**: Distributed testing across different browser configurations with easy result comparison

### DevOps & CI/CD
- **Pipeline Test Validation**: Compare test results between pipeline runs to catch flaky or environment-specific failures
- **Multi-Stage Testing**: Compare dev → staging → production test results across different browser configurations
- **Parallel Test Execution**: Run tests on multiple browsers simultaneously and compare results
- **Build Artifact Validation**: Verify that different build artifacts (minified, bundled, etc.) produce consistent test results

### Performance & Compatibility Research
- **Browser Engine Comparison**: Study behavioral differences between Chromium, Gecko (Firefox), and WebKit
- **Web Standards Compliance**: Track which browsers pass/fail standards compliance tests
- **Feature Detection Testing**: Compare feature support across browser versions
- **Polyfill Validation**: Verify polyfills work correctly across browsers by comparing polyfilled vs native implementations

### Educational & Training
- **Teaching Cross-Browser Testing**: Demonstrate browser compatibility issues to students/trainees
- **Test Strategy Development**: Show the importance of cross-browser testing with real examples
- **Debugging Workshops**: Use diff results to teach browser-specific debugging techniques

### Sencha ExtJS Framework Development
- **Toolkit Comparison Testing**: Compare Sencha Classic vs Modern toolkit behavior across browsers using Playwright
- **SDK Version Validation**: Test Sencha SDK updates to ensure backward compatibility across all supported browsers
- **Component Library Testing**: Validate Sencha UI components (grids, forms, charts) work consistently in Chromium, Firefox, and WebKit
- **Cross-Browser ExtJS Validation**: Ensure Sencha applications render and function correctly across all browser engines
- **Sencha Upgrade Testing**: Compare test results before and after Sencha framework upgrades to identify breaking changes
- **Multi-Toolkit Regression Detection**: Identify when changes to Classic toolkit affect Modern toolkit or vice versa
- **Browser-Specific Sencha Issues**: Quickly isolate which Sencha components have browser-specific rendering or functionality issues

## Real-World Examples

### Example 1: React Component Library Testing
```bash
# Test your React components on Chrome 120
npx playwright test --project=chromium --reporter=./emoji-reporter.js > chrome-120.txt

# Chrome auto-updates to 121
npx playwright test --project=chromium --reporter=./emoji-reporter.js > chrome-121.txt

# Compare to find if Chrome 121 broke any components
perl compare-test-results.pl chrome-120.txt chrome-121.txt
```

### Example 2: E-commerce Platform Cross-Browser Testing
```bash
# Test checkout flow on all browsers
npx playwright test checkout.spec.js --project=chromium > checkout-chrome.txt
npx playwright test checkout.spec.js --project=firefox > checkout-firefox.txt
npx playwright test checkout.spec.js --project=webkit > checkout-safari.txt

# Compare to find browser-specific payment processing issues
perl compare-test-results.pl checkout-chrome.txt checkout-firefox.txt
perl compare-test-results.pl checkout-firefox.txt checkout-safari.txt
```

### Example 3: SPA Framework Migration Validation
```bash
# Test old framework version
npx playwright test --reporter=./emoji-reporter.js > old-framework.txt

# Upgrade to new framework version
npx playwright test --reporter=./emoji-reporter.js > new-framework.txt

# Verify migration didn't break browser compatibility
perl compare-test-results.pl old-framework.txt new-framework.txt
```

### Example 4: CI/CD Browser Matrix Testing
```bash
# In your CI pipeline
npx playwright test --project=chromium > chrome-$BUILD_ID.txt
npx playwright test --project=firefox > firefox-$BUILD_ID.txt

# Compare against last successful build
perl compare-test-results.pl chrome-$LAST_BUILD_ID.txt chrome-$BUILD_ID.txt
perl compare-test-results.pl firefox-$LAST_BUILD_ID.txt firefox-$BUILD_ID.txt

# Fail build if regressions detected
if [ -f chrome-$BUILD_ID.txt.out ]; then exit 1; fi
```

### Example 5: Sencha ExtJS Framework Testing with Playwright
```bash
# Test Sencha ExtJS Classic toolkit across browsers
node run-tests.js -show-pass true -sdk-url "http://127.0.0.1:1842/" \
  -toolkits classic -browsers chromium > sencha-classic-chrome.txt

node run-tests.js -show-pass true -sdk-url "http://127.0.0.1:1842/" \
  -toolkits classic -browsers firefox > sencha-classic-firefox.txt

node run-tests.js -show-pass true -sdk-url "http://127.0.0.1:1842/" \
  -toolkits classic -browsers webkit > sencha-classic-safari.txt

# Compare Classic toolkit results across browsers
perl compare-test-results.pl sencha-classic-chrome.txt sencha-classic-firefox.txt
perl compare-test-results.pl sencha-classic-chrome.txt sencha-classic-safari.txt

# Test Modern toolkit and compare with Classic
node run-tests.js -show-pass true -sdk-url "http://127.0.0.1:1842/" \
  -toolkits modern -browsers chromium > sencha-modern-chrome.txt

# Compare Modern vs Classic to find toolkit-specific issues
perl compare-test-results.pl sencha-classic-chrome.txt sencha-modern-chrome.txt
```

### Example 6: Sencha SDK Multi-Toolkit Cross-Browser Validation
```bash
# Run comprehensive Sencha tests across all toolkits and browsers
node run-tests.js -show-pass true -sdk-url "http://127.0.0.1:1842/" \
  -toolkits classic,modern -browsers chromium,firefox,webkit > sencha-all.txt

# After SDK updates, run again and compare
node run-tests.js -show-pass true -sdk-url "http://127.0.0.1:1842/" \
  -toolkits classic,modern -browsers chromium,firefox,webkit > sencha-updated.txt

perl compare-test-results.pl sencha-all.txt sencha-updated.txt

# Identify which Sencha components broke after SDK update
```

## How It Works

1. **Parse Both Files**: Extract test sections (📙) and their results
2. **Determine Primary**: File with more tests becomes the baseline
3. **Normalize Results**: Sort test results alphabetically within each section
4. **Compare**: Check if results match between files
5. **Output Differences**: Generate `.out` files with only changed tests

## Technical Details

- **Language**: Perl 5
- **Dependencies**: `File::Slurp`
- **Encoding**: UTF-8 with `:raw` binmode for emoji support
- **Algorithm**: Single-pass parsing with hash-based lookups
- **Memory Management**: Explicit cleanup with `undef` statements

## License

GNU General Public License v3.0

Copyright (c) 2024 Maxim Masiutin

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

## Benefits & Value Proposition

### Time Savings
- **Quick Identification**: Instantly see which tests differ between browsers/versions
- **No Manual Comparison**: Automate what would take hours of manual review
- **Focused Debugging**: Only investigate actual differences, not entire test suites
- **Faster Release Cycles**: Quickly validate browser compatibility before deployment

### Cost Reduction
- **Minimal Infrastructure**: Runs on any system with Perl (no databases, servers, or cloud services)
- **Zero External Dependencies**: Only requires File::Slurp CPAN module
- **No Licensing Costs**: Free and open source (GPL v3.0)
- **Resource Efficient**: Lightweight Perl script with minimal memory footprint

### Quality Improvement
- **Comprehensive Coverage**: Compare test results across all browser combinations
- **Regression Prevention**: Catch browser-specific issues before users do
- **Confidence Building**: Know exactly what works (and doesn't) on each browser
- **Audit Trail**: Keep historical test comparisons for compliance and analysis

### Developer Experience
- **Simple Integration**: Drop into existing Playwright test workflows
- **Clear Output**: Emoji-based format is intuitive and easy to understand
- **Flexible Usage**: Works with any test framework that can output the emoji format
- **Cross-Platform**: Runs on Windows, Linux, macOS without modification

## Why This Format?

The emoji-based format offers advantages over standard formats:
- **Visual Clarity**: Emojis make test status instantly recognizable in terminals
- **Terminal-Friendly**: Works well in CI/CD logs and colored terminals
- **Simple Parsing**: Easier to parse with Perl regex than HTML/XML/JSON
- **Human-Readable**: Can be reviewed directly in text editors without special viewers
- **Version Control**: Text-based diffs can be committed to git and reviewed in PRs
- **Lightweight**: Smaller file sizes compared to verbose XML or JSON reports
- **Language Agnostic**: Any test runner can output this format regardless of language

## Contributing

This is a simple utility script. For enhancements:
1. Ensure UTF-8 emoji handling remains intact
2. Maintain backward compatibility with existing output format
3. Test with various file sizes and test counts
4. Preserve atomic file operations for reliability
