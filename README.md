
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku <img src="man/figures/logo.png" align="right" alt="santoku logo" width="120" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/santoku.svg?branch=master)](https://travis-ci.org/hughjonesd/santoku)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
[![Codecov test
coverage](https://codecov.io/gh/hughjonesd/santoku/branch/master/graph/badge.svg)](https://codecov.io/gh/hughjonesd/santoku?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
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

  - Flexible labelling, including easy ways to label intervals by
    numerals or letters.

  - Convenience functions for creating quantile intervals, evenly-spaced
    intervals or equal-sized groups.

  - Convenience functions for quickly tabulating chopped data.

These advantages make santoku especially useful for exploratory
analysis, where you may not know the range of your data in advance.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hughjonesd/santoku")
```

## Basic usage

Use `chop()` like `cut()` to cut your data up:

``` r
library(santoku)
x <- runif(10, 0, 10)
(chopped <- chop(x, breaks = 0:10))
#>  [1] [4, 5)  [8, 9)  [3, 4)  [4, 5)  [7, 8)  [9, 10] [6, 7)  [8, 9) 
#>  [9] [1, 2)  [4, 5) 
#> Levels: [1, 2) [3, 4) [4, 5) [6, 7) [7, 8) [8, 9) [9, 10]
data.frame(x, chopped)
#>           x chopped
#> 1  4.978305  [4, 5)
#> 2  8.969989  [8, 9)
#> 3  3.391823  [3, 4)
#> 4  4.676785  [4, 5)
#> 5  7.057042  [7, 8)
#> 6  9.707687 [9, 10]
#> 7  6.713807  [6, 7)
#> 8  8.376589  [8, 9)
#> 9  1.086165  [1, 2)
#> 10 4.495479  [4, 5)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>           x    chopped
#> 1  4.978305     [4, 5)
#> 2  8.969989 (7, 9.708]
#> 3  3.391823     [3, 4)
#> 4  4.676785     [4, 5)
#> 5  7.057042 (7, 9.708]
#> 6  9.707687 (7, 9.708]
#> 7  6.713807     [6, 7]
#> 8  8.376589 (7, 9.708]
#> 9  1.086165 [1.086, 3)
#> 10 4.495479     [4, 5)
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chopped <- chop(x_fives, c(2, 5, 5, 8))
data.frame(x_fives, chopped)
#>     x_fives    chopped
#> 1  5.000000        {5}
#> 2  5.000000        {5}
#> 3  5.000000        {5}
#> 4  5.000000        {5}
#> 5  5.000000        {5}
#> 6  9.707687 (8, 9.708]
#> 7  6.713807     (5, 8]
#> 8  8.376589 (8, 9.708]
#> 9  1.086165 [1.086, 2)
#> 10 4.495479     [2, 5)
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(1:10, c(2, 5, 8))
#> x
#>  [1, 2)  [2, 5)  [5, 8] (8, 10] 
#>       1       3       4       2
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>           x        chopped
#> 1  4.978305 [3.086, 5.086)
#> 2  8.969989 [7.086, 9.086)
#> 3  3.391823 [3.086, 5.086)
#> 4  4.676785 [3.086, 5.086)
#> 5  7.057042 [5.086, 7.086)
#> 6  9.707687 [9.086, 11.09]
#> 7  6.713807 [5.086, 7.086)
#> 8  8.376589 [7.086, 9.086)
#> 9  1.086165 [1.086, 3.086)
#> 10 4.495479 [3.086, 5.086)
```

To chop into exactly `groups` fixed-with intervals, use `chop_evenly()`:

``` r
chopped <- chop_evenly(x, groups = 3)
data.frame(x, chopped)
#>           x        chopped
#> 1  4.978305  [3.96, 6.834)
#> 2  8.969989 [6.834, 9.708]
#> 3  3.391823  [1.086, 3.96)
#> 4  4.676785  [3.96, 6.834)
#> 5  7.057042 [6.834, 9.708]
#> 6  9.707687 [6.834, 9.708]
#> 7  6.713807  [3.96, 6.834)
#> 8  8.376589 [6.834, 9.708]
#> 9  1.086165  [1.086, 3.96)
#> 10 4.495479  [3.96, 6.834)
```

To chop into groups with a fixed number of members, use `chop_n()`:

``` r
chopped <- chop_n(x, 4)
table(chopped)
#> chopped
#> [1.086, 4.978)  [4.978, 8.97)  [8.97, 9.708] 
#>              4              4              2
```

To chop into a fixed number of equal-sized groups, use `chop_equally()`:

``` r
chopped <- chop_equally(x, groups = 5)
table(chopped)
#> chopped
#>   [0%, 20%)  [20%, 40%)  [40%, 60%)  [60%, 80%) [80%, 100%] 
#>           2           2           2           2           2
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>           x     chopped
#> 1  4.978305  [25%, 50%)
#> 2  8.969989 (75%, 100%]
#> 3  3.391823   [0%, 25%)
#> 4  4.676785  [25%, 50%)
#> 5  7.057042  [50%, 75%]
#> 6  9.707687 (75%, 100%]
#> 7  6.713807  [50%, 75%]
#> 8  8.376589 (75%, 100%]
#> 9  1.086165   [0%, 25%)
#> 10 4.495479   [0%, 25%)
```

To chop data by standard deviations around the mean, use
`chop_mean_sd()`:

``` r
chopped <- chop_mean_sd(x)
data.frame(x, chopped)
#>           x        chopped
#> 1  4.978305  [-1 sd, 0 sd)
#> 2  8.969989   [1 sd, 2 sd)
#> 3  3.391823  [-1 sd, 0 sd)
#> 4  4.676785  [-1 sd, 0 sd)
#> 5  7.057042   [0 sd, 1 sd)
#> 6  9.707687   [1 sd, 2 sd)
#> 7  6.713807   [0 sd, 1 sd)
#> 8  8.376589   [0 sd, 1 sd)
#> 9  1.086165 [-2 sd, -1 sd)
#> 10 4.495479  [-1 sd, 0 sd)
```

`tab_n()`, `tab_width()`, `tab_evenly()` and `tab_mean_sd()` act
similarly to `tab()`, calling the related `chop_` function and then
`table()`.

``` r
tab_n(x, 4)
#> x
#> [1.086, 4.978)  [4.978, 8.97)  [8.97, 9.708] 
#>              4              4              2
tab_width(x, 2)
#> x
#> [1.086, 3.086) [3.086, 5.086) [5.086, 7.086) [7.086, 9.086) [9.086, 11.09] 
#>              1              4              2              2              1
tab_evenly(x, 5)
#> x
#>  [1.086, 2.81)  [2.81, 4.535) [4.535, 6.259) [6.259, 7.983) [7.983, 9.708] 
#>              1              2              2              2              3
tab_mean_sd(x)
#> x
#> [-2 sd, -1 sd)  [-1 sd, 0 sd)   [0 sd, 1 sd)   [1 sd, 2 sd) 
#>              1              4              3              2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>           x chopped
#> 1  4.978305     Low
#> 2  8.969989 Highest
#> 3  3.391823     Low
#> 4  4.676785     Low
#> 5  7.057042  Higher
#> 6  9.707687 Highest
#> 7  6.713807  Higher
#> 8  8.376589 Highest
#> 9  1.086165  Lowest
#> 10 4.495479     Low
```

You need as many labels as there are intervals - one fewer than
`length(breaks)` if your data doesn’t extend beyond `breaks`, one more
than `length(breaks)` if it does.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>           x   chopped
#> 1  4.978305     2 - 5
#> 2  8.969989 8 - 9.708
#> 3  3.391823     2 - 5
#> 4  4.676785     2 - 5
#> 5  7.057042     5 - 8
#> 6  9.707687 8 - 9.708
#> 7  6.713807     5 - 8
#> 8  8.376589 8 - 9.708
#> 9  1.086165 1.086 - 2
#> 10 4.495479     2 - 5
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>           x    chopped
#> 1  4.978305     2 to 5
#> 2  8.969989 8 to 9.708
#> 3  3.391823     2 to 5
#> 4  4.676785     2 to 5
#> 5  7.057042     5 to 8
#> 6  9.707687 8 to 9.708
#> 7  6.713807     5 to 8
#> 8  8.376589 8 to 9.708
#> 9  1.086165 1.086 to 2
#> 10 4.495479     2 to 5
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>           x chopped
#> 1  4.978305       2
#> 2  8.969989       4
#> 3  3.391823       2
#> 4  4.676785       2
#> 5  7.057042       3
#> 6  9.707687       4
#> 7  6.713807       3
#> 8  8.376589       4
#> 9  1.086165       1
#> 10 4.495479       2
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] b d b b c d c d a b
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] ii  iv  ii  ii  iii iv  iii iv  i   ii 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>           x chopped
#> 1  4.978305  [3, 5)
#> 2  8.969989    <NA>
#> 3  3.391823  [3, 5)
#> 4  4.676785  [3, 5)
#> 5  7.057042    <NA>
#> 6  9.707687    <NA>
#> 7  6.713807  [5, 7]
#> 8  8.376589    <NA>
#> 9  1.086165    <NA>
#> 10 4.495479  [3, 5)
```

Data outside the range of `breaks` will become `NA`.

By default, intervals are closed on the left, i.e. they include their
left endpoints. If you want right-closed intervals, use `brk_right()`:

``` r
y <- 1:5
data.frame(
        y = y, 
        left_closed = chop(y, 1:5), 
        right_closed = chop(y, brk_right(1:5))
      )
#>   y left_closed right_closed
#> 1 1      [1, 2)       [1, 2]
#> 2 2      [2, 3)       [1, 2]
#> 3 3      [3, 4)       (2, 3]
#> 4 4      [4, 5]       (3, 4]
#> 5 5      [4, 5]       (4, 5]
```

The last finite interval is right-closed (or if you use `brk_right`, the
first finite interval is left-closed). If you don’t want that, use
`brk_left()` explicitly and set `close_end = FALSE`:

``` r
z <- 1:5
data.frame(
  z = z,
  rightmost_closed = chop(1:5, brk_left(1:5)),
  rightmost_open   = chop(1:5, brk_left(1:5, close_end = FALSE))
)
#>   z rightmost_closed rightmost_open
#> 1 1           [1, 2)         [1, 2)
#> 2 2           [2, 3)         [2, 3)
#> 3 3           [3, 4)         [3, 4)
#> 4 4           [4, 5]         [4, 5)
#> 5 5           [4, 5]            {5}
```

If you want to chop repeatedly with the same arguments, create your own
`knife`:

``` r
chop_by_quartiles <- knife(
        breaks = brk_quantiles(c(0.25, 0.5, 0.75)), 
        labels = lbl_dash()
      )

chop_by_quartiles(x)
#>  [1] 25% - 50%  75% - 100% 0% - 25%   25% - 50%  50% - 75%  75% - 100%
#>  [7] 50% - 75%  75% - 100% 0% - 25%   0% - 25%  
#> Levels: 0% - 25% 25% - 50% 50% - 75% 75% - 100%
table(chop_by_quartiles(rnorm(50)))
#> 
#>   0% - 25%  25% - 50%  50% - 75% 75% - 100% 
#>         13         12         12         13
```
