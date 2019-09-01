
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

  - Unlike `cut()` or `cut2()`, `chop()` can handle single values as
    well as intervals. For example, `chop(x, breaks = c(1, 2, 2, 3))`
    will create a separate factor level for values exactly equal to 2.

  - santoku has flexible labelling, including easy ways to label
    intervals by numerals or letters.

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
#>  [1] [9, 10] [1, 2)  [6, 7)  [6, 7)  [2, 3)  [0, 1)  [5, 6)  [0, 1) 
#>  [9] [4, 5)  [2, 3) 
#> Levels: [0, 1) [1, 2) [2, 3) [4, 5) [5, 6) [6, 7) [9, 10]
data.frame(x, chopped)
#>            x chopped
#> 1  9.0734873 [9, 10]
#> 2  1.7960371  [1, 2)
#> 3  6.7042056  [6, 7)
#> 4  6.2043489  [6, 7)
#> 5  2.8193668  [2, 3)
#> 6  0.9371805  [0, 1)
#> 7  5.1141874  [5, 6)
#> 8  0.7754162  [0, 1)
#> 9  4.2859425  [4, 5)
#> 10 2.6126451  [2, 3)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  9.0734873  (7, Inf]
#> 2  1.7960371 [-Inf, 3)
#> 3  6.7042056    [6, 7]
#> 4  6.2043489    [6, 7]
#> 5  2.8193668 [-Inf, 3)
#> 6  0.9371805 [-Inf, 3)
#> 7  5.1141874    [5, 6)
#> 8  0.7754162 [-Inf, 3)
#> 9  4.2859425    [4, 5)
#> 10 2.6126451 [-Inf, 3)
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
#> 6  0.9371805 [-Inf, 2)
#> 7  5.1141874    (5, 8]
#> 8  0.7754162 [-Inf, 2)
#> 9  4.2859425    [2, 5)
#> 10 2.6126451    [2, 5)
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         3         3         3         1
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>            x     chopped
#> 1  9.0734873  (8.8, Inf]
#> 2  1.7960371 [0.78, 2.8)
#> 3  6.7042056  [4.8, 6.8)
#> 4  6.2043489  [4.8, 6.8)
#> 5  2.8193668  [2.8, 4.8)
#> 6  0.9371805 [0.78, 2.8)
#> 7  5.1141874  [4.8, 6.8)
#> 8  0.7754162 [0.78, 2.8)
#> 9  4.2859425  [2.8, 4.8)
#> 10 2.6126451 [0.78, 2.8)
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.78, 2.8)  [2.8, 6.7)  [6.7, Inf] 
#>           4           4           2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 2.6)  [2.6, 5.1]  (5.1, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>            x chopped
#> 1  9.0734873 75-100%
#> 2  1.7960371   0-25%
#> 3  6.7042056 75-100%
#> 4  6.2043489 75-100%
#> 5  2.8193668  25-50%
#> 6  0.9371805   0-25%
#> 7  5.1141874  50-75%
#> 8  0.7754162   0-25%
#> 9  4.2859425  50-75%
#> 10 2.6126451  25-50%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.78)  [0.78, 2.8)   [2.8, 4.8)   [4.8, 6.8)   [6.8, 8.8] 
#>            0            4            2            3            0 
#>   (8.8, Inf] 
#>            1
tab_size(x, 4)
#> x
#> [-Inf, 0.78)  [0.78, 2.8)   [2.8, 6.7)   [6.7, Inf] 
#>            0            4            4            2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  9.0734873 Highest
#> 2  1.7960371  Lowest
#> 3  6.7042056  Higher
#> 4  6.2043489  Higher
#> 5  2.8193668     Low
#> 6  0.9371805  Lowest
#> 7  5.1141874  Higher
#> 8  0.7754162  Lowest
#> 9  4.2859425     Low
#> 10 2.6126451     Low
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  9.0734873  8 - Inf
#> 2  1.7960371 -Inf - 2
#> 3  6.7042056    5 - 8
#> 4  6.2043489    5 - 8
#> 5  2.8193668    2 - 5
#> 6  0.9371805 -Inf - 2
#> 7  5.1141874    5 - 8
#> 8  0.7754162 -Inf - 2
#> 9  4.2859425    2 - 5
#> 10 2.6126451    2 - 5
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  9.0734873  8 to Inf
#> 2  1.7960371 -Inf to 2
#> 3  6.7042056    5 to 8
#> 4  6.2043489    5 to 8
#> 5  2.8193668    2 to 5
#> 6  0.9371805 -Inf to 2
#> 7  5.1141874    5 to 8
#> 8  0.7754162 -Inf to 2
#> 9  4.2859425    2 to 5
#> 10 2.6126451    2 to 5
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  9.0734873       4
#> 2  1.7960371       1
#> 3  6.7042056       3
#> 4  6.2043489       3
#> 5  2.8193668       2
#> 6  0.9371805       1
#> 7  5.1141874       3
#> 8  0.7754162       1
#> 9  4.2859425       2
#> 10 2.6126451       2
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] d a c c b a c a b b
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iv  i   iii iii ii  i   iii i   ii  ii 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  9.0734873    <NA>
#> 2  1.7960371    <NA>
#> 3  6.7042056  [5, 7]
#> 4  6.2043489  [5, 7]
#> 5  2.8193668    <NA>
#> 6  0.9371805    <NA>
#> 7  5.1141874  [5, 7]
#> 8  0.7754162    <NA>
#> 9  4.2859425  [3, 5)
#> 10 2.6126451    <NA>
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
#>  [1] 5.93 - Inf  -Inf - 2    5.93 - Inf  5.93 - Inf  2 - 3.55   
#>  [6] -Inf - 2    3.55 - 5.93 -Inf - 2    3.55 - 5.93 2 - 3.55   
#> Levels: -Inf - 2 2 - 3.55 3.55 - 5.93 5.93 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>    -Inf - -0.541 -0.541 - -0.0886  -0.0886 - 0.705      0.705 - Inf 
#>               13               12               12               13
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
#>  chop(rnorm(1e+05), -2:2) 13.92728 15.88332 16.92908 16.28101 17.58183
#>   cut(rnorm(1e+05), -2:2) 10.60559 11.97017 12.58420 12.18927 13.01646
#>       max neval cld
#>  25.44707   100   b
#>  18.81300   100  a
```
