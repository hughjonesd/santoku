
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku <img src="man/figures/logo.png" align="right" alt="santoku logo" width="120" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/santoku.svg?branch=master)](https://travis-ci.org/hughjonesd/santoku)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
[![Codecov test
coverage](https://codecov.io/gh/hughjonesd/santoku/branch/master/graph/badge.svg)](https://codecov.io/gh/hughjonesd/santoku?branch=master)
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
#>  [1] [2, 3)  [6, 7)  [8, 9)  [0, 1)  [2, 3)  [7, 8)  [4, 5)  [9, 10]
#>  [9] [2, 3)  [9, 10]
#> Levels: [0, 1) [2, 3) [4, 5) [6, 7) [7, 8) [8, 9) [9, 10]
data.frame(x, chopped)
#>            x chopped
#> 1  2.3035299  [2, 3)
#> 2  6.2410364  [6, 7)
#> 3  8.2351518  [8, 9)
#> 4  0.5820561  [0, 1)
#> 5  2.1381988  [2, 3)
#> 6  7.8497878  [7, 8)
#> 7  4.8597634  [4, 5)
#> 8  9.6363684 [9, 10]
#> 9  2.8388452  [2, 3)
#> 10 9.8956612 [9, 10]
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  2.3035299 [-Inf, 3)
#> 2  6.2410364    [6, 7]
#> 3  8.2351518  (7, Inf]
#> 4  0.5820561 [-Inf, 3)
#> 5  2.1381988 [-Inf, 3)
#> 6  7.8497878  (7, Inf]
#> 7  4.8597634    [4, 5)
#> 8  9.6363684  (7, Inf]
#> 9  2.8388452 [-Inf, 3)
#> 10 9.8956612  (7, Inf]
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
#> 6  7.849788   (5, 8]
#> 7  4.859763   [2, 5)
#> 8  9.636368 (8, Inf]
#> 9  2.838845   [2, 5)
#> 10 9.895661 (8, Inf]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         1         4         2         3
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>            x     chopped
#> 1  2.3035299 [0.58, 2.6)
#> 2  6.2410364  [4.6, 6.6)
#> 3  8.2351518  [6.6, 8.6]
#> 4  0.5820561 [0.58, 2.6)
#> 5  2.1381988 [0.58, 2.6)
#> 6  7.8497878  [6.6, 8.6]
#> 7  4.8597634  [4.6, 6.6)
#> 8  9.6363684  (8.6, Inf]
#> 9  2.8388452  [2.6, 4.6)
#> 10 9.8956612  (8.6, Inf]
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.58, 4.9)  [4.9, 9.6)  [9.6, Inf] 
#>           4           4           2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 2.8)  [2.8, 7.8]  (7.8, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>            x chopped
#> 1  2.3035299   0-25%
#> 2  6.2410364  50-75%
#> 3  8.2351518 75-100%
#> 4  0.5820561   0-25%
#> 5  2.1381988   0-25%
#> 6  7.8497878  50-75%
#> 7  4.8597634  25-50%
#> 8  9.6363684 75-100%
#> 9  2.8388452  25-50%
#> 10 9.8956612 75-100%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.58)  [0.58, 2.6)   [2.6, 4.6)   [4.6, 6.6)   [6.6, 8.6] 
#>            0            3            1            2            2 
#>   (8.6, Inf] 
#>            2
tab_size(x, 4)
#> x
#> [-Inf, 0.58)  [0.58, 4.9)   [4.9, 9.6)   [9.6, Inf] 
#>            0            4            4            2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  2.3035299     Low
#> 2  6.2410364  Higher
#> 3  8.2351518 Highest
#> 4  0.5820561  Lowest
#> 5  2.1381988     Low
#> 6  7.8497878  Higher
#> 7  4.8597634     Low
#> 8  9.6363684 Highest
#> 9  2.8388452     Low
#> 10 9.8956612 Highest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  2.3035299    2 - 5
#> 2  6.2410364    5 - 8
#> 3  8.2351518  8 - Inf
#> 4  0.5820561 -Inf - 2
#> 5  2.1381988    2 - 5
#> 6  7.8497878    5 - 8
#> 7  4.8597634    2 - 5
#> 8  9.6363684  8 - Inf
#> 9  2.8388452    2 - 5
#> 10 9.8956612  8 - Inf
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  2.3035299    2 to 5
#> 2  6.2410364    5 to 8
#> 3  8.2351518  8 to Inf
#> 4  0.5820561 -Inf to 2
#> 5  2.1381988    2 to 5
#> 6  7.8497878    5 to 8
#> 7  4.8597634    2 to 5
#> 8  9.6363684  8 to Inf
#> 9  2.8388452    2 to 5
#> 10 9.8956612  8 to Inf
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  2.3035299       2
#> 2  6.2410364       3
#> 3  8.2351518       4
#> 4  0.5820561       1
#> 5  2.1381988       2
#> 6  7.8497878       3
#> 7  4.8597634       2
#> 8  9.6363684       4
#> 9  2.8388452       2
#> 10 9.8956612       4
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] b c d a b c b d b d
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] ii  iii iv  i   ii  iii ii  iv  ii  iv 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  2.3035299    <NA>
#> 2  6.2410364  [5, 7]
#> 3  8.2351518    <NA>
#> 4  0.5820561    <NA>
#> 5  2.1381988    <NA>
#> 6  7.8497878    <NA>
#> 7  4.8597634  [3, 5)
#> 8  9.6363684    <NA>
#> 9  2.8388452    <NA>
#> 10 9.8956612    <NA>
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
#>  [1] -Inf - 2.44 5.55 - 8.14 8.14 - Inf  -Inf - 2.44 -Inf - 2.44
#>  [6] 5.55 - 8.14 2.44 - 5.55 8.14 - Inf  2.44 - 5.55 8.14 - Inf 
#> Levels: -Inf - 2.44 2.44 - 5.55 5.55 - 8.14 8.14 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>  -Inf - -0.483 -0.483 - 0.138  0.138 - 0.803    0.803 - Inf 
#>             13             12             12             13
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
#>  chop(rnorm(1e+05), -2:2) 13.19846 15.43388 17.34146 16.46521 17.66208
#>   cut(rnorm(1e+05), -2:2) 10.51832 11.67420 12.50234 12.09335 12.81482
#>       max neval cld
#>  49.07338   100   b
#>  19.30830   100  a
```
