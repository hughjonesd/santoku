# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

santoku is an R package that provides `chop()`, a versatile replacement for `base::cut()` for cutting data into intervals. The package handles numeric vectors, dates, times, and other comparable objects, with support for singleton intervals and flexible labeling.

## Common Commands

### Testing
```r
# Run all tests
devtools::test()

# Run tests from command line
R CMD check .

# Run specific test file
testthat::test_file("tests/testthat/test-chop.R")
```

### Development workflow
```r
# Build package
devtools::build()

# Install package locally
devtools::install()

# Check package
devtools::check()

# Load package for interactive development
devtools::load_all()
```

### Documentation
```r
# Update documentation
devtools::document()

# Build website
pkgdown::build_site()
```

## Architecture

### Core Components

- **Main cutting function**: `chop()` in `R/chop.R` - the primary interface that calls other functions
- **Break creation**: `R/breaks*.R` files contain functions to create break points (`brk_*` functions)
- **Labeling system**: `R/labels*.R` files contain labeling functions (`lbl_*` functions)  
- **Convenience functions**: `R/chop-*.R` files contain `chop_*` wrapper functions for common use cases
- **C++ backend**: `src/categorize.cpp` provides fast interval categorization via Rcpp
- **Tabulation**: `R/tab.R` provides `tab_*` functions that chop and tabulate in one step

### Key Design Patterns

1. **Function factories**: Many functions return other functions (e.g., `brk_*` functions return break-creation functions)
2. **Method dispatch**: Uses S3 methods and vctrs for handling different data types (numbers, dates, etc.)
3. **Extensible labeling**: Label functions can be combined and customized using the `lbl_*` family
4. **Performance**: Core categorization logic is implemented in C++ for speed

### File Organization

- `R/chop.R` - Main `chop()` function and documentation
- `R/breaks*.R` - Break point creation (`brk_default`, `brk_width`, etc.)
- `R/labels*.R` - Label generation (`lbl_intervals`, `lbl_dash`, etc.)
- `R/chop-*.R` - Convenience functions (`chop_quantiles`, `chop_width`, etc.)
- `R/tab.R` - Tabulation functions
- `R/utils.R` - Utility functions like `exactly()` and `percent()`
- `src/categorize.cpp` - Fast C++ categorization implementation
- `tests/testthat/` - Comprehensive test suite

## Development Notes

- The package uses Rcpp for performance-critical categorization
- Tests are extensive and include systematic testing in `test-zzz-systematic.R`
- The package supports non-standard data types (dates, times, units) via the vctrs package
- Documentation follows roxygen2 conventions with extensive examples
- Uses lifecycle package for function lifecycle management