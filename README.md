
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
#>  [1] [3, 4)  [9, 10] [1, 2)  [3, 4)  [8, 9)  [6, 7)  [3, 4)  [3, 4) 
#>  [9] [2, 3)  [8, 9) 
#> Levels: [1, 2) [2, 3) [3, 4) [6, 7) [8, 9) [9, 10]
data.frame(x, chopped)
#>           x chopped
#> 1  3.045807  [3, 4)
#> 2  9.745762 [9, 10]
#> 3  1.542382  [1, 2)
#> 4  3.404732  [3, 4)
#> 5  8.679728  [8, 9)
#> 6  6.989861  [6, 7)
#> 7  3.904426  [3, 4)
#> 8  3.520875  [3, 4)
#> 9  2.746674  [2, 3)
#> 10 8.251653  [8, 9)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>           x   chopped
#> 1  3.045807    [3, 4)
#> 2  9.745762  (7, Inf]
#> 3  1.542382 [-Inf, 3)
#> 4  3.404732    [3, 4)
#> 5  8.679728  (7, Inf]
#> 6  6.989861    [6, 7]
#> 7  3.904426    [3, 4)
#> 8  3.520875    [3, 4)
#> 9  2.746674 [-Inf, 3)
#> 10 8.251653  (7, Inf]
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chopped <- chop(x_fives, c(2, 5, 5, 8))
data.frame(x_fives, chopped)
#>     x_fives  chopped
#> 1  5.000000      {5}
#> 2  5.000000      {5}
#> 3  5.000000      {5}
#> 4  5.000000      {5}
#> 5  5.000000      {5}
#> 6  6.989861   (5, 8]
#> 7  3.904426   [2, 5)
#> 8  3.520875   [2, 5)
#> 9  2.746674   [2, 5)
#> 10 8.251653 (8, Inf]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         1         5         1         3
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>           x                              chopped
#> 1  3.045807 [1.54238182585686, 3.54238182585686)
#> 2  9.745762              (9.54238182585686, Inf]
#> 3  1.542382 [1.54238182585686, 3.54238182585686)
#> 4  3.404732 [1.54238182585686, 3.54238182585686)
#> 5  8.679728 [7.54238182585686, 9.54238182585686]
#> 6  6.989861 [5.54238182585686, 7.54238182585686)
#> 7  3.904426 [3.54238182585686, 5.54238182585686)
#> 8  3.520875 [1.54238182585686, 3.54238182585686)
#> 9  2.746674 [1.54238182585686, 3.54238182585686)
#> 10 8.251653 [7.54238182585686, 9.54238182585686]
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [1.54238182585686, 3.52087509119883) [3.52087509119883, 8.67972778854892) 
#>                                    4                                    4 
#>              [8.67972778854892, Inf] 
#>                                    2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#>                0-33.3333333333333% 33.3333333333333-66.6666666666667% 
#>                                  3                                  4 
#>              66.6666666666667-100% 
#>                                  3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>           x chopped
#> 1  3.045807   0-25%
#> 2  9.745762 75-100%
#> 3  1.542382   0-25%
#> 4  3.404732  25-50%
#> 5  8.679728 75-100%
#> 6  6.989861  50-75%
#> 7  3.904426  50-75%
#> 8  3.520875  25-50%
#> 9  2.746674   0-25%
#> 10 8.251653 75-100%
```

To chop data by standard deviations around the mean, use
`chop_mean_sd()`:

``` r
chopped <- chop_mean_sd(x)
data.frame(x, chopped)
#>           x  chopped
#> 1  3.045807  [-1, 0)
#> 2  9.745762   [1, 2)
#> 3  1.542382 [-2, -1)
#> 4  3.404732  [-1, 0)
#> 5  8.679728   [1, 2)
#> 6  6.989861   [0, 1)
#> 7  3.904426  [-1, 0)
#> 8  3.520875  [-1, 0)
#> 9  2.746674  [-1, 0)
#> 10 8.251653   [1, 2)
```

`tab_size()`, `tab_width()` and `tab_mean_sd()` act similarly to
`tab()`, calling the related `chop_` function and then `table()`.

``` r
tab_width(x, 2)
#> x
#> [1.54238182585686, 3.54238182585686) [3.54238182585686, 5.54238182585686) 
#>                                    5                                    1 
#> [5.54238182585686, 7.54238182585686) [7.54238182585686, 9.54238182585686] 
#>                                    1                                    2 
#>              (9.54238182585686, Inf] 
#>                                    1
tab_size(x, 4)
#> x
#> [1.54238182585686, 3.52087509119883) [3.52087509119883, 8.67972778854892) 
#>                                    4                                    4 
#>              [8.67972778854892, Inf] 
#>                                    2
tab_mean_sd(x)
#> x
#> [-2, -1)  [-1, 0)   [0, 1)   [1, 2) 
#>        1        5        1        3
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>           x chopped
#> 1  3.045807     Low
#> 2  9.745762 Highest
#> 3  1.542382  Lowest
#> 4  3.404732     Low
#> 5  8.679728 Highest
#> 6  6.989861  Higher
#> 7  3.904426     Low
#> 8  3.520875     Low
#> 9  2.746674     Low
#> 10 8.251653 Highest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>           x  chopped
#> 1  3.045807    2 - 5
#> 2  9.745762  8 - Inf
#> 3  1.542382 -Inf - 2
#> 4  3.404732    2 - 5
#> 5  8.679728  8 - Inf
#> 6  6.989861    5 - 8
#> 7  3.904426    2 - 5
#> 8  3.520875    2 - 5
#> 9  2.746674    2 - 5
#> 10 8.251653  8 - Inf
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>           x   chopped
#> 1  3.045807    2 to 5
#> 2  9.745762  8 to Inf
#> 3  1.542382 -Inf to 2
#> 4  3.404732    2 to 5
#> 5  8.679728  8 to Inf
#> 6  6.989861    5 to 8
#> 7  3.904426    2 to 5
#> 8  3.520875    2 to 5
#> 9  2.746674    2 to 5
#> 10 8.251653  8 to Inf
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>           x chopped
#> 1  3.045807       2
#> 2  9.745762       4
#> 3  1.542382       1
#> 4  3.404732       2
#> 5  8.679728       4
#> 6  6.989861       3
#> 7  3.904426       2
#> 8  3.520875       2
#> 9  2.746674       2
#> 10 8.251653       4
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] b d a b d c b b b d
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] ii  iv  i   ii  iv  iii ii  ii  ii  iv 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>           x chopped
#> 1  3.045807  [3, 5)
#> 2  9.745762    <NA>
#> 3  1.542382    <NA>
#> 4  3.404732  [3, 5)
#> 5  8.679728    <NA>
#> 6  6.989861  [5, 7]
#> 7  3.904426  [3, 5)
#> 8  3.520875  [3, 5)
#> 9  2.746674    <NA>
#> 10 8.251653    <NA>
```

Data outside the range of `breaks` will become `NA`.

By default, intervals are closed on the left, i.e. they include their
left endpoints. If you want right-closed intervals, use `brk_right()`:

``` r
y <- 1:10
data.frame(
        y = y, 
        left_closed = chop(y, 2:8), 
        right_closed = chop(y, brk_right(2:8))
      )
#>     y left_closed right_closed
#> 1   1   [-Inf, 2)    [-Inf, 2)
#> 2   2      [2, 3)       [2, 3]
#> 3   3      [3, 4)       [2, 3]
#> 4   4      [4, 5)       (3, 4]
#> 5   5      [5, 6)       (4, 5]
#> 6   6      [6, 7)       (5, 6]
#> 7   7      [7, 8]       (6, 7]
#> 8   8      [7, 8]       (7, 8]
#> 9   9    (8, Inf]     (8, Inf]
#> 10 10    (8, Inf]     (8, Inf]
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
#> 5 5           [4, 5]       [5, Inf]
```

If you want to chop repeatedly with the same arguments, create your own
`knife`:

``` r
chop_by_quartiles <- knife(
        breaks = brk_quantiles(c(0.25, 0.5, 0.75)), 
        labels = lbl_dash()
      )

chop_by_quartiles(x)
#>  [1] -Inf - 3.13553857442457            
#>  [2] 7.93620521319099 - Inf             
#>  [3] -Inf - 3.13553857442457            
#>  [4] 3.13553857442457 - 3.71265035821125
#>  [5] 7.93620521319099 - Inf             
#>  [6] 3.71265035821125 - 7.93620521319099
#>  [7] 3.71265035821125 - 7.93620521319099
#>  [8] 3.13553857442457 - 3.71265035821125
#>  [9] -Inf - 3.13553857442457            
#> [10] 7.93620521319099 - Inf             
#> 4 Levels: -Inf - 3.13553857442457 ... 7.93620521319099 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>               -Inf - -0.728394805438697 
#>                                      13 
#> -0.728394805438697 - -0.191728912996556 
#>                                      12 
#>  -0.191728912996556 - 0.863454371894529 
#>                                      12 
#>                 0.863454371894529 - Inf 
#>                                      13
```

## Speed

The core of santoku is written in C++. It is reasonably fast:

``` r
microbenchmark::microbenchmark(
        chop(rnorm(1e5), -2:2),
         cut(rnorm(1e5), -2:2)
      )
#> Unit: milliseconds
#>                      expr      min       lq     mean   median       uq
#>  chop(rnorm(1e+05), -2:2) 14.50784 16.55729 17.91861 17.14887 18.99479
#>   cut(rnorm(1e+05), -2:2) 11.53046 12.74836 13.68451 13.04884 14.05959
#>       max neval cld
#>  26.01172   100   b
#>  24.76575   100  a
```
