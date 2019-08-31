
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku <img src="man/figures/logo.png" align="right" alt="" width="120" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/santoku.svg?branch=master)](https://travis-ci.org/hughjonesd/santoku)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
<!-- badges: end -->

santoku is a versatile cutting tool for R. It provides `chop()`, a
replacement for `base::cut()`.

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
#>  [1] [1, 2)  [6, 7)  [3, 4)  [8, 9)  [4, 5)  [9, 10] [1, 2)  [9, 10]
#>  [9] [9, 10] [8, 9) 
#> Levels: [1, 2) [3, 4) [4, 5) [6, 7) [8, 9) [9, 10]
data.frame(x, chopped)
#>           x chopped
#> 1  1.946400  [1, 2)
#> 2  6.402338  [6, 7)
#> 3  3.474928  [3, 4)
#> 4  8.434991  [8, 9)
#> 5  4.385594  [4, 5)
#> 6  9.775059 [9, 10]
#> 7  1.316238  [1, 2)
#> 8  9.918701 [9, 10]
#> 9  9.190205 [9, 10]
#> 10 8.305950  [8, 9)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>           x   chopped
#> 1  1.946400 [-Inf, 3)
#> 2  6.402338    [6, 7]
#> 3  3.474928    [3, 4)
#> 4  8.434991  (7, Inf]
#> 5  4.385594    [4, 5)
#> 6  9.775059  (7, Inf]
#> 7  1.316238 [-Inf, 3)
#> 8  9.918701  (7, Inf]
#> 9  9.190205  (7, Inf]
#> 10 8.305950  (7, Inf]
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chopped <- chop(x_fives, c(2, 5, 5, 8))
data.frame(x_fives, chopped)
#>     x_fives   chopped
#> 1  5.000000       {5}
#> 2  5.000000       {5}
#> 3  5.000000       {5}
#> 4  5.000000       {5}
#> 5  5.000000       {5}
#> 6  9.775059  (8, Inf]
#> 7  1.316238 [-Inf, 2)
#> 8  9.918701  (8, Inf]
#> 9  9.190205  (8, Inf]
#> 10 8.305950  (8, Inf]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         2         2         1         5
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>           x    chopped
#> 1  1.946400 [1.3, 3.3)
#> 2  6.402338 [5.3, 7.3)
#> 3  3.474928 [3.3, 5.3)
#> 4  8.434991 [7.3, 9.3]
#> 5  4.385594 [3.3, 5.3)
#> 6  9.775059 (9.3, Inf]
#> 7  1.316238 [1.3, 3.3)
#> 8  9.918701 (9.3, Inf]
#> 9  9.190205 [7.3, 9.3]
#> 10 8.305950 [7.3, 9.3]
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [1.3, 6.4) [6.4, 9.8) [9.8, Inf] 
#>          4          4          2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 4.4)  [4.4, 8.4]  (8.4, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>           x chopped
#> 1  1.946400   0-25%
#> 2  6.402338  25-50%
#> 3  3.474928   0-25%
#> 4  8.434991  50-75%
#> 5  4.385594  25-50%
#> 6  9.775059 75-100%
#> 7  1.316238   0-25%
#> 8  9.918701 75-100%
#> 9  9.190205 75-100%
#> 10 8.305950  50-75%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 1.3)  [1.3, 3.3)  [3.3, 5.3)  [5.3, 7.3)  [7.3, 9.3]  (9.3, Inf] 
#>           0           2           2           1           3           2
tab_size(x, 4)
#> x
#> [-Inf, 1.3)  [1.3, 6.4)  [6.4, 9.8)  [9.8, Inf] 
#>           0           4           4           2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>           x chopped
#> 1  1.946400  Lowest
#> 2  6.402338  Higher
#> 3  3.474928     Low
#> 4  8.434991 Highest
#> 5  4.385594     Low
#> 6  9.775059 Highest
#> 7  1.316238  Lowest
#> 8  9.918701 Highest
#> 9  9.190205 Highest
#> 10 8.305950 Highest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>           x  chopped
#> 1  1.946400 -Inf - 2
#> 2  6.402338    5 - 8
#> 3  3.474928    2 - 5
#> 4  8.434991  8 - Inf
#> 5  4.385594    2 - 5
#> 6  9.775059  8 - Inf
#> 7  1.316238 -Inf - 2
#> 8  9.918701  8 - Inf
#> 9  9.190205  8 - Inf
#> 10 8.305950  8 - Inf
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>           x   chopped
#> 1  1.946400 -Inf to 2
#> 2  6.402338    5 to 8
#> 3  3.474928    2 to 5
#> 4  8.434991  8 to Inf
#> 5  4.385594    2 to 5
#> 6  9.775059  8 to Inf
#> 7  1.316238 -Inf to 2
#> 8  9.918701  8 to Inf
#> 9  9.190205  8 to Inf
#> 10 8.305950  8 to Inf
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>           x chopped
#> 1  1.946400       1
#> 2  6.402338       3
#> 3  3.474928       2
#> 4  8.434991       4
#> 5  4.385594       2
#> 6  9.775059       4
#> 7  1.316238       1
#> 8  9.918701       4
#> 9  9.190205       4
#> 10 8.305950       4
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] a c b d b d a d d d
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] i   iii ii  iv  ii  iv  i   iv  iv  iv 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>           x chopped
#> 1  1.946400    <NA>
#> 2  6.402338  [5, 7]
#> 3  3.474928  [3, 5)
#> 4  8.434991    <NA>
#> 5  4.385594  [3, 5)
#> 6  9.775059    <NA>
#> 7  1.316238    <NA>
#> 8  9.918701    <NA>
#> 9  9.190205    <NA>
#> 10 8.305950    <NA>
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
#>  [1] -Inf - 3.7 3.7 - 7.35 -Inf - 3.7 7.35 - 9   3.7 - 7.35 9 - Inf   
#>  [7] -Inf - 3.7 9 - Inf    9 - Inf    7.35 - 9  
#> Levels: -Inf - 3.7 3.7 - 7.35 7.35 - 9 9 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>   -Inf - -0.99 -0.99 - 0.0196 0.0196 - 0.955    0.955 - Inf 
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
#>  chop(rnorm(1e+05), -2:2) 13.58385 15.30726 16.61386 15.65808 17.23291
#>   cut(rnorm(1e+05), -2:2) 11.06931 12.34102 13.42922 12.61561 13.75428
#>       max neval cld
#>  26.34205   100   b
#>  49.34841   100  a
```
