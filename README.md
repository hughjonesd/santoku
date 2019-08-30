
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/santoku.svg?branch=master)](https://travis-ci.org/hughjonesd/santoku)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
<!-- badges: end -->

![santoku logo](man/figures/santoku-logo.png)

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
#>  [1] [5, 6) [0, 1) [4, 5) [6, 7) [1, 2) [1, 2) [0, 1) [8, 9) [0, 1) [0, 1)
#> Levels: [0, 1) [1, 2) [4, 5) [5, 6) [6, 7) [8, 9)
data.frame(x, chopped)
#>            x chopped
#> 1  5.1582727  [5, 6)
#> 2  0.5850355  [0, 1)
#> 3  4.0879082  [4, 5)
#> 4  6.5237012  [6, 7)
#> 5  1.7956510  [1, 2)
#> 6  1.4978565  [1, 2)
#> 7  0.7928896  [0, 1)
#> 8  8.9941024  [8, 9)
#> 9  0.5299117  [0, 1)
#> 10 0.0407637  [0, 1)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  5.1582727    [5, 6)
#> 2  0.5850355 [-Inf, 3)
#> 3  4.0879082    [4, 5)
#> 4  6.5237012    [6, 7]
#> 5  1.7956510 [-Inf, 3)
#> 6  1.4978565 [-Inf, 3)
#> 7  0.7928896 [-Inf, 3)
#> 8  8.9941024  (7, Inf]
#> 9  0.5299117 [-Inf, 3)
#> 10 0.0407637 [-Inf, 3)
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
#> 6  1.4978565 [-Inf, 2)
#> 7  0.7928896 [-Inf, 2)
#> 8  8.9941024  (8, Inf]
#> 9  0.5299117 [-Inf, 2)
#> 10 0.0407637 [-Inf, 2)
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         6         1         2         1
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>            x    chopped
#> 1  5.1582727     [4, 6)
#> 2  0.5850355 [0.041, 2)
#> 3  4.0879082     [4, 6)
#> 4  6.5237012     [6, 8]
#> 5  1.7956510 [0.041, 2)
#> 6  1.4978565 [0.041, 2)
#> 7  0.7928896 [0.041, 2)
#> 8  8.9941024   (8, Inf]
#> 9  0.5299117 [0.041, 2)
#> 10 0.0407637 [0.041, 2)
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.041, 1.5)   [1.5, 6.5)   [6.5, Inf] 
#>            4            4            2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 0.79)  [0.79, 4.1]   (4.1, Inf] 
#>            3            4            3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>            x chopped
#> 1  5.1582727 75-100%
#> 2  0.5850355   0-25%
#> 3  4.0879082  50-75%
#> 4  6.5237012 75-100%
#> 5  1.7956510  50-75%
#> 6  1.4978565  25-50%
#> 7  0.7928896  25-50%
#> 8  8.9941024 75-100%
#> 9  0.5299117   0-25%
#> 10 0.0407637   0-25%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.041)    [0.041, 2)        [2, 4)        [4, 6)        [6, 8] 
#>             0             6             0             2             1 
#>      (8, Inf] 
#>             1
tab_size(x, 4)
#> x
#> [-Inf, 0.041)  [0.041, 1.5)    [1.5, 6.5)    [6.5, Inf] 
#>             0             4             4             2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  5.1582727  Higher
#> 2  0.5850355  Lowest
#> 3  4.0879082     Low
#> 4  6.5237012  Higher
#> 5  1.7956510  Lowest
#> 6  1.4978565  Lowest
#> 7  0.7928896  Lowest
#> 8  8.9941024 Highest
#> 9  0.5299117  Lowest
#> 10 0.0407637  Lowest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  5.1582727    5 - 8
#> 2  0.5850355 -Inf - 2
#> 3  4.0879082    2 - 5
#> 4  6.5237012    5 - 8
#> 5  1.7956510 -Inf - 2
#> 6  1.4978565 -Inf - 2
#> 7  0.7928896 -Inf - 2
#> 8  8.9941024  8 - Inf
#> 9  0.5299117 -Inf - 2
#> 10 0.0407637 -Inf - 2
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  5.1582727    5 to 8
#> 2  0.5850355 -Inf to 2
#> 3  4.0879082    2 to 5
#> 4  6.5237012    5 to 8
#> 5  1.7956510 -Inf to 2
#> 6  1.4978565 -Inf to 2
#> 7  0.7928896 -Inf to 2
#> 8  8.9941024  8 to Inf
#> 9  0.5299117 -Inf to 2
#> 10 0.0407637 -Inf to 2
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  5.1582727       3
#> 2  0.5850355       1
#> 3  4.0879082       2
#> 4  6.5237012       3
#> 5  1.7956510       1
#> 6  1.4978565       1
#> 7  0.7928896       1
#> 8  8.9941024       4
#> 9  0.5299117       1
#> 10 0.0407637       1
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] c a b c a a a d a a
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iii i   ii  iii i   i   i   iv  i   i  
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  5.1582727  [5, 7]
#> 2  0.5850355    <NA>
#> 3  4.0879082  [3, 5)
#> 4  6.5237012  [5, 7]
#> 5  1.7956510    <NA>
#> 6  1.4978565    <NA>
#> 7  0.7928896    <NA>
#> 8  8.9941024    <NA>
#> 9  0.5299117    <NA>
#> 10 0.0407637    <NA>
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
#>  [1] 4.89 - Inf   -Inf - 0.637 1.65 - 4.89  4.89 - Inf   1.65 - 4.89 
#>  [6] 0.637 - 1.65 0.637 - 1.65 4.89 - Inf   -Inf - 0.637 -Inf - 0.637
#> Levels: -Inf - 0.637 0.637 - 1.65 1.65 - 4.89 4.89 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>  -Inf - -0.294 -0.294 - 0.117  0.117 - 0.615    0.615 - Inf 
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
#>  chop(rnorm(1e+05), -2:2) 12.88223 15.12828 16.93203 16.52752 17.83408
#>   cut(rnorm(1e+05), -2:2) 10.67363 12.23765 13.62828 13.15680 14.32068
#>       max neval cld
#>  25.28353   100   b
#>  21.70808   100  a
```
