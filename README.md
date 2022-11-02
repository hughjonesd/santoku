
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

  - By default, `chop()` always covers the whole range of the data, so
    you won’t get unexpected `NA` values.

  - `chop()` can handle single values as well as intervals. For example,
    `chop(x, breaks = c(1, 2, 2, 3))` will create a separate factor
    level for values exactly equal to 2.

  - `chop()` can handle many kinds of data, including numbers, dates and
    times, and [units](https://r-quantities.github.io/units/).

  - `chop_*` functions create intervals in many ways, using quantiles of
    the data, standard deviations, fixed-width intervals, equal-sized
    groups, or pretty intervals for use in graphs.

  - `lbl_*` functions make it easy to label intervals: use interval
    notation like `[1, 2)`, dash notation like `1-2`, or arbitrary
    styles using `glue::glue()`.

  - `tab_*` functions quickly chop data, then tabulate it.

These advantages make santoku especially useful for exploratory
analysis, where you may not know the range of your data in advance.

## Examples

``` r
library(santoku)
```

`chop` returns a factor:

``` r
chop(1:5, c(2, 4))
#> [1] [1, 2) [2, 4) [2, 4) [4, 5] [4, 5]
#> Levels: [1, 2) [2, 4) [4, 5]
```

Include a number twice to match it exactly:

``` r
chop(1:5, c(2, 2, 4))
#> [1] [1, 2) {2}    (2, 4) [4, 5] [4, 5]
#> Levels: [1, 2) {2} (2, 4) [4, 5]
```

Use names in breaks for labels:

``` r
chop(1:5, c(Low = 1, Mid = 2, High = 4))
#> [1] Low  Mid  Mid  High High
#> Levels: Low Mid High
```

Or use `lbl_*` functions:

``` r
chop(1:5, c(2, 4), labels = lbl_dash())
#> [1] 1—2 2—4 2—4 4—5 4—5
#> Levels: 1—2 2—4 4—5
```

Chop into fixed-width intervals:

``` r
chop_width(runif(10), 0.1)
#>  [1] [0.1518, 0.2518) [0.3518, 0.4518) [0.8518, 0.9518] [0.0518, 0.1518)
#>  [5] [0.7518, 0.8518) [0.7518, 0.8518) [0.5518, 0.6518) [0.6518, 0.7518)
#>  [9] [0.0518, 0.1518) [0.4518, 0.5518)
#> 8 Levels: [0.0518, 0.1518) [0.1518, 0.2518) ... [0.8518, 0.9518]
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

dates <- as.Date("2021-12-31") + 1:90

tab_width(dates, months(1), labels = lbl_discrete(fmt = "%d %b"))
#> 01 Jan—31 Jan 01 Feb—28 Feb 01 Mar—31 Mar 
#>            31            28            31
```

For more information, see the
[vignette](https://hughjonesd.github.io/santoku/articles/santoku.html).
