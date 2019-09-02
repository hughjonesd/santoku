
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
#>  [1] [7, 8)  [3, 4)  [9, 10] [8, 9)  [3, 4)  [0, 1)  [7, 8)  [7, 8) 
#>  [9] [1, 2)  [9, 10]
#> Levels: [0, 1) [1, 2) [3, 4) [7, 8) [8, 9) [9, 10]
data.frame(x, chopped)
#>            x chopped
#> 1  7.9723999  [7, 8)
#> 2  3.9213432  [3, 4)
#> 3  9.7424836 [9, 10]
#> 4  8.6384664  [8, 9)
#> 5  3.0275358  [3, 4)
#> 6  0.1005091  [0, 1)
#> 7  7.2712117  [7, 8)
#> 8  7.6701278  [7, 8)
#> 9  1.0883207  [1, 2)
#> 10 9.1924411 [9, 10]
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  7.9723999  (7, Inf]
#> 2  3.9213432    [3, 4)
#> 3  9.7424836  (7, Inf]
#> 4  8.6384664  (7, Inf]
#> 5  3.0275358    [3, 4)
#> 6  0.1005091 [-Inf, 3)
#> 7  7.2712117  (7, Inf]
#> 8  7.6701278  (7, Inf]
#> 9  1.0883207 [-Inf, 3)
#> 10 9.1924411  (7, Inf]
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chopped <- chop(x_fives, c(2, 5, 5, 8))
data.frame(x_fives, chopped)
#>      x_fives   chopped
#> 1  5.0000000       {5}
#> 2  5.0000000       {5}
#> 3  5.0000000       {5}
#> 4  5.0000000       {5}
#> 5  5.0000000       {5}
#> 6  0.1005091 [-Inf, 2)
#> 7  7.2712117    (5, 8]
#> 8  7.6701278    (5, 8]
#> 9  1.0883207 [-Inf, 2)
#> 10 9.1924411  (8, Inf]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         2         2         3         3
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>            x                 chopped
#> 1  7.9723999  [6.1005091, 8.1005091)
#> 2  3.9213432  [2.1005091, 4.1005091)
#> 3  9.7424836 [8.1005091, 10.1005091]
#> 4  8.6384664 [8.1005091, 10.1005091]
#> 5  3.0275358  [2.1005091, 4.1005091)
#> 6  0.1005091  [0.1005091, 2.1005091)
#> 7  7.2712117  [6.1005091, 8.1005091)
#> 8  7.6701278  [6.1005091, 8.1005091)
#> 9  1.0883207  [0.1005091, 2.1005091)
#> 10 9.1924411 [8.1005091, 10.1005091]
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.1005091, 7.2712117) [7.2712117, 9.1924411)       [9.1924411, Inf] 
#>                      4                      4                      2
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
#>            x chopped
#> 1  7.9723999  50-75%
#> 2  3.9213432  25-50%
#> 3  9.7424836 75-100%
#> 4  8.6384664 75-100%
#> 5  3.0275358   0-25%
#> 6  0.1005091   0-25%
#> 7  7.2712117  25-50%
#> 8  7.6701278  50-75%
#> 9  1.0883207   0-25%
#> 10 9.1924411 75-100%
```

To chop data by standard deviations around the mean, use
`chop_mean_sd()`:

``` r
chopped <- chop_mean_sd(x)
data.frame(x, chopped)
#>            x  chopped
#> 1  7.9723999   [0, 1)
#> 2  3.9213432  [-1, 0)
#> 3  9.7424836   [1, 2)
#> 4  8.6384664   [0, 1)
#> 5  3.0275358  [-1, 0)
#> 6  0.1005091 [-2, -1)
#> 7  7.2712117   [0, 1)
#> 8  7.6701278   [0, 1)
#> 9  1.0883207 [-2, -1)
#> 10 9.1924411   [0, 1)
```

`tab_size()`, `tab_width()` and `tab_mean_sd()` act similarly to
`tab()`, calling the related `chop_` function and then `table()`.

``` r
tab_width(x, 2)
#> x
#>  [0.1005091, 2.1005091)  [2.1005091, 4.1005091)  [6.1005091, 8.1005091) 
#>                       2                       2                       3 
#> [8.1005091, 10.1005091] 
#>                       3
tab_size(x, 4)
#> x
#> [0.1005091, 7.2712117) [7.2712117, 9.1924411)       [9.1924411, Inf] 
#>                      4                      4                      2
tab_mean_sd(x)
#> x
#> [-2, -1)  [-1, 0)   [0, 1)   [1, 2) 
#>        2        2        5        1
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  7.9723999  Higher
#> 2  3.9213432     Low
#> 3  9.7424836 Highest
#> 4  8.6384664 Highest
#> 5  3.0275358     Low
#> 6  0.1005091  Lowest
#> 7  7.2712117  Higher
#> 8  7.6701278  Higher
#> 9  1.0883207  Lowest
#> 10 9.1924411 Highest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  7.9723999    5 - 8
#> 2  3.9213432    2 - 5
#> 3  9.7424836  8 - Inf
#> 4  8.6384664  8 - Inf
#> 5  3.0275358    2 - 5
#> 6  0.1005091 -Inf - 2
#> 7  7.2712117    5 - 8
#> 8  7.6701278    5 - 8
#> 9  1.0883207 -Inf - 2
#> 10 9.1924411  8 - Inf
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  7.9723999    5 to 8
#> 2  3.9213432    2 to 5
#> 3  9.7424836  8 to Inf
#> 4  8.6384664  8 to Inf
#> 5  3.0275358    2 to 5
#> 6  0.1005091 -Inf to 2
#> 7  7.2712117    5 to 8
#> 8  7.6701278    5 to 8
#> 9  1.0883207 -Inf to 2
#> 10 9.1924411  8 to Inf
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  7.9723999       3
#> 2  3.9213432       2
#> 3  9.7424836       4
#> 4  8.6384664       4
#> 5  3.0275358       2
#> 6  0.1005091       1
#> 7  7.2712117       3
#> 8  7.6701278       3
#> 9  1.0883207       1
#> 10 9.1924411       4
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] c b d d b a c c a d
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iii ii  iv  iv  ii  i   iii iii i   iv 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  7.9723999    <NA>
#> 2  3.9213432  [3, 5)
#> 3  9.7424836    <NA>
#> 4  8.6384664    <NA>
#> 5  3.0275358  [3, 5)
#> 6  0.1005091    <NA>
#> 7  7.2712117    <NA>
#> 8  7.6701278    <NA>
#> 9  1.0883207    <NA>
#> 10 9.1924411    <NA>
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
#> 5 5           [4, 5]           <NA>
```

If you want to chop repeatedly with the same arguments, create your own
`knife`:

``` r
chop_by_quartiles <- knife(
        breaks = brk_quantiles(c(0.25, 0.5, 0.75)), 
        labels = lbl_dash()
      )

chop_by_quartiles(x)
#>  [1] 7.47066974290647 - 8.47194979491178
#>  [2] 3.2509876426775 - 7.47066974290647 
#>  [3] 8.47194979491178 - Inf             
#>  [4] 8.47194979491178 - Inf             
#>  [5] -Inf - 3.2509876426775             
#>  [6] -Inf - 3.2509876426775             
#>  [7] 3.2509876426775 - 7.47066974290647 
#>  [8] 7.47066974290647 - 8.47194979491178
#>  [9] -Inf - 3.2509876426775             
#> [10] 8.47194979491178 - Inf             
#> 4 Levels: -Inf - 3.2509876426775 ... 8.47194979491178 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>               -Inf - -0.800760873787986 
#>                                      13 
#> -0.800760873787986 - -0.206358929826589 
#>                                      12 
#>  -0.206358929826589 - 0.559937981556792 
#>                                      12 
#>                 0.559937981556792 - Inf 
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
#>  chop(rnorm(1e+05), -2:2) 13.76359 15.77183 17.30239 16.28457 18.45222
#>   cut(rnorm(1e+05), -2:2) 11.46665 12.60786 13.84940 12.86603 14.25499
#>       max neval cld
#>  28.04527   100   b
#>  21.83588   100  a
```
