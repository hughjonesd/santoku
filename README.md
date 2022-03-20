
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku <img src="man/figures/logo.png" align="right" alt="santoku logo" width="120" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/santoku)](https://CRAN.R-project.org/package=santoku)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN Downloads Per
Month](http://cranlogs.r-pkg.org/badges/santoku)](https://CRAN.R-project.org/package=santoku)
[![R-CMD-check](https://github.com/hughjonesd/santoku/workflows/R-CMD-check/badge.svg)](https://github.com/hughjonesd/santoku/actions)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
[![Codecov test
coverage](https://codecov.io/gh/hughjonesd/santoku/branch/master/graph/badge.svg)](https://app.codecov.io/gh/hughjonesd/santoku?branch=master)
<!-- badges: end -->

santoku is a versatile cutting tool for R. It provides `chop()`, a
replacement for `base::cut()`.

## Advantages

Here are some advantages of santoku:

-   By default, `chop()` always covers the whole range of the data, so
    you won’t get unexpected `NA` values.

-   `chop()` can handle single values as well as intervals. For example,
    `chop(x, breaks = c(1, 2, 2, 3))` will create a separate factor
    level for values exactly equal to 2.

-   Flexible labelling, including easy ways to label intervals by
    numerals or letters.

-   Convenience functions for creating quantile intervals, evenly-spaced
    intervals or equal-sized groups.

-   Convenience functions for quickly tabulating chopped data.

These advantages make santoku especially useful for exploratory
analysis, where you may not know the range of your data in advance.

## Examples

``` r
library(santoku)
```

`chop` returns a factor:

``` r
chop(1:8, c(3, 5, 7))
#> [1] [1, 3) [1, 3) [3, 5) [3, 5) [5, 7) [5, 7) [7, 8] [7, 8]
#> Levels: [1, 3) [3, 5) [5, 7) [7, 8]
```

Include a number twice to match it exactly:

``` r
chop(1:8, c(3, 5, 5, 7))
#> [1] [1, 3) [1, 3) [3, 5) [3, 5) {5}    (5, 7) [7, 8] [7, 8]
#> Levels: [1, 3) [3, 5) {5} (5, 7) [7, 8]
```

Customize output with `lbl_*` functions:

``` r
chop(1:8, c(3, 5, 7), labels = lbl_dash())
#> [1] 1—3 1—3 3—5 3—5 5—7 5—7 7—8 7—8
#> Levels: 1—3 3—5 5—7 7—8
```

Chop into fixed-width intervals:

``` r
chop_width(runif(10), 0.1)
#>  [1] [0.8278, 0.9278)  [0.8278, 0.9278)  [0.8278, 0.9278)  [0.3278, 0.4278) 
#>  [5] [0.7278, 0.8278)  [0.2278, 0.3278)  [0.9278, 1.028)   [0.02781, 0.1278)
#>  [9] [0.9278, 1.028)   [0.02781, 0.1278)
#> 6 Levels: [0.02781, 0.1278) [0.2278, 0.3278) ... [0.9278, 1.028)
```

Or into fixed-size groups:

``` r
chop_n(1:10, 5)
#>  [1] [1, 6)  [1, 6)  [1, 6)  [1, 6)  [1, 6)  [6, 10] [6, 10] [6, 10] [6, 10]
#> [10] [6, 10]
#> Levels: [1, 6) [6, 10]
```

Chop dates by calendar month, then tabulate:

``` r
library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union

tab_width(as.Date("2021-12-31") + 1:90, months(1), 
            labels = lbl_discrete(fmt = "%d %b")
          )
#> 01 Jan—31 Jan 01 Feb—28 Feb 01 Mar—31 Mar 
#>            31            28            31
```

For more information, see the
[vignette](https://hughjonesd.github.io/santoku/articles/santoku.html).
