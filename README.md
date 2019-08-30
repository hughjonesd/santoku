
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
#>  [1] [7, 8)  [6, 7)  [2, 3)  [2, 3)  [4, 5)  [3, 4)  [0, 1)  [3, 4) 
#>  [9] [9, 10] [9, 10]
#> Levels: [0, 1) [2, 3) [3, 4) [4, 5) [6, 7) [7, 8) [9, 10]
data.frame(x, chopped)
#>            x chopped
#> 1  7.5465831  [7, 8)
#> 2  6.3132669  [6, 7)
#> 3  2.2234007  [2, 3)
#> 4  2.0758154  [2, 3)
#> 5  4.0666948  [4, 5)
#> 6  3.5355509  [3, 4)
#> 7  0.3636387  [0, 1)
#> 8  3.5307203  [3, 4)
#> 9  9.6499347 [9, 10]
#> 10 9.3131003 [9, 10]
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  7.5465831  (7, Inf]
#> 2  6.3132669    [6, 7]
#> 3  2.2234007 [-Inf, 3)
#> 4  2.0758154 [-Inf, 3)
#> 5  4.0666948    [4, 5)
#> 6  3.5355509    [3, 4)
#> 7  0.3636387 [-Inf, 3)
#> 8  3.5307203    [3, 4)
#> 9  9.6499347  (7, Inf]
#> 10 9.3131003  (7, Inf]
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
#> 6  3.5355509    [2, 5)
#> 7  0.3636387 [-Inf, 2)
#> 8  3.5307203    [2, 5)
#> 9  9.6499347  (8, Inf]
#> 10 9.3131003  (8, Inf]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         1         5         2         2
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>            x     chopped
#> 1  7.5465831  [6.4, 8.4]
#> 2  6.3132669  [4.4, 6.4)
#> 3  2.2234007 [0.36, 2.4)
#> 4  2.0758154 [0.36, 2.4)
#> 5  4.0666948  [2.4, 4.4)
#> 6  3.5355509  [2.4, 4.4)
#> 7  0.3636387 [0.36, 2.4)
#> 8  3.5307203  [2.4, 4.4)
#> 9  9.6499347  (8.4, Inf]
#> 10 9.3131003  (8.4, Inf]
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.36, 3.5)  [3.5, 9.3)  [9.3, Inf] 
#>           4           4           2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 3.5)  [3.5, 6.3]  (6.3, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>            x chopped
#> 1  7.5465831 75-100%
#> 2  6.3132669  50-75%
#> 3  2.2234007   0-25%
#> 4  2.0758154   0-25%
#> 5  4.0666948  50-75%
#> 6  3.5355509  25-50%
#> 7  0.3636387   0-25%
#> 8  3.5307203  25-50%
#> 9  9.6499347 75-100%
#> 10 9.3131003 75-100%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.36)  [0.36, 2.4)   [2.4, 4.4)   [4.4, 6.4)   [6.4, 8.4] 
#>            0            3            3            1            1 
#>   (8.4, Inf] 
#>            2
tab_size(x, 4)
#> x
#> [-Inf, 0.36)  [0.36, 3.5)   [3.5, 9.3)   [9.3, Inf] 
#>            0            4            4            2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  7.5465831  Higher
#> 2  6.3132669  Higher
#> 3  2.2234007     Low
#> 4  2.0758154     Low
#> 5  4.0666948     Low
#> 6  3.5355509     Low
#> 7  0.3636387  Lowest
#> 8  3.5307203     Low
#> 9  9.6499347 Highest
#> 10 9.3131003 Highest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  7.5465831    5 - 8
#> 2  6.3132669    5 - 8
#> 3  2.2234007    2 - 5
#> 4  2.0758154    2 - 5
#> 5  4.0666948    2 - 5
#> 6  3.5355509    2 - 5
#> 7  0.3636387 -Inf - 2
#> 8  3.5307203    2 - 5
#> 9  9.6499347  8 - Inf
#> 10 9.3131003  8 - Inf
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  7.5465831    5 to 8
#> 2  6.3132669    5 to 8
#> 3  2.2234007    2 to 5
#> 4  2.0758154    2 to 5
#> 5  4.0666948    2 to 5
#> 6  3.5355509    2 to 5
#> 7  0.3636387 -Inf to 2
#> 8  3.5307203    2 to 5
#> 9  9.6499347  8 to Inf
#> 10 9.3131003  8 to Inf
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  7.5465831       3
#> 2  6.3132669       3
#> 3  2.2234007       2
#> 4  2.0758154       2
#> 5  4.0666948       2
#> 6  3.5355509       2
#> 7  0.3636387       1
#> 8  3.5307203       2
#> 9  9.6499347       4
#> 10 9.3131003       4
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] c c b b b b a b d d
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iii iii ii  ii  ii  ii  i   ii  iv  iv 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  7.5465831    <NA>
#> 2  6.3132669  [5, 7]
#> 3  2.2234007    <NA>
#> 4  2.0758154    <NA>
#> 5  4.0666948  [3, 5)
#> 6  3.5355509  [3, 5)
#> 7  0.3636387    <NA>
#> 8  3.5307203  [3, 5)
#> 9  9.6499347    <NA>
#> 10 9.3131003    <NA>
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
#>  [1] 7.24 - Inf  3.8 - 7.24  -Inf - 2.55 -Inf - 2.55 3.8 - 7.24 
#>  [6] 2.55 - 3.8  -Inf - 2.55 2.55 - 3.8  7.24 - Inf  7.24 - Inf 
#> Levels: -Inf - 2.55 2.55 - 3.8 3.8 - 7.24 7.24 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>  -Inf - -0.505 -0.505 - 0.224  0.224 - 0.832    0.832 - Inf 
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
#>  chop(rnorm(1e+05), -2:2) 13.01989 14.89216 16.05595 15.32395 16.64690
#>   cut(rnorm(1e+05), -2:2) 11.10312 12.20900 13.18906 12.46777 13.59821
#>       max neval cld
#>  23.82563   100   b
#>  22.20725   100  a
```

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
#>  [1] [1, 2)  [5, 6)  [3, 4)  [9, 10] [0, 1)  [1, 2)  [9, 10] [1, 2) 
#>  [9] [4, 5)  [0, 1) 
#> Levels: [0, 1) [1, 2) [3, 4) [4, 5) [5, 6) [9, 10]
data.frame(x, chopped)
#>            x chopped
#> 1  1.1036164  [1, 2)
#> 2  5.4159229  [5, 6)
#> 3  3.4768280  [3, 4)
#> 4  9.2537990 [9, 10]
#> 5  0.9854478  [0, 1)
#> 6  1.6682271  [1, 2)
#> 7  9.0953746 [9, 10]
#> 8  1.0039538  [1, 2)
#> 9  4.3589922  [4, 5)
#> 10 0.8541879  [0, 1)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  1.1036164 [-Inf, 3)
#> 2  5.4159229    [5, 6)
#> 3  3.4768280    [3, 4)
#> 4  9.2537990  (7, Inf]
#> 5  0.9854478 [-Inf, 3)
#> 6  1.6682271 [-Inf, 3)
#> 7  9.0953746  (7, Inf]
#> 8  1.0039538 [-Inf, 3)
#> 9  4.3589922    [4, 5)
#> 10 0.8541879 [-Inf, 3)
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
#> 6  1.6682271 [-Inf, 2)
#> 7  9.0953746  (8, Inf]
#> 8  1.0039538 [-Inf, 2)
#> 9  4.3589922    [2, 5)
#> 10 0.8541879 [-Inf, 2)
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         5         2         1         2
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>            x     chopped
#> 1  1.1036164 [0.85, 2.9)
#> 2  5.4159229  [4.9, 6.9)
#> 3  3.4768280  [2.9, 4.9)
#> 4  9.2537990  (8.9, Inf]
#> 5  0.9854478 [0.85, 2.9)
#> 6  1.6682271 [0.85, 2.9)
#> 7  9.0953746  (8.9, Inf]
#> 8  1.0039538 [0.85, 2.9)
#> 9  4.3589922  [2.9, 4.9)
#> 10 0.8541879 [0.85, 2.9)
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.85, 1.7)  [1.7, 9.1)  [9.1, Inf] 
#>           4           4           2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 1.1)  [1.1, 4.4]  (4.4, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>            x chopped
#> 1  1.1036164  25-50%
#> 2  5.4159229 75-100%
#> 3  3.4768280  50-75%
#> 4  9.2537990 75-100%
#> 5  0.9854478   0-25%
#> 6  1.6682271  25-50%
#> 7  9.0953746 75-100%
#> 8  1.0039538   0-25%
#> 9  4.3589922  50-75%
#> 10 0.8541879   0-25%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.85)  [0.85, 2.9)   [2.9, 4.9)   [4.9, 6.9)   [6.9, 8.9] 
#>            0            5            2            1            0 
#>   (8.9, Inf] 
#>            2
tab_size(x, 4)
#> x
#> [-Inf, 0.85)  [0.85, 1.7)   [1.7, 9.1)   [9.1, Inf] 
#>            0            4            4            2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  1.1036164  Lowest
#> 2  5.4159229  Higher
#> 3  3.4768280     Low
#> 4  9.2537990 Highest
#> 5  0.9854478  Lowest
#> 6  1.6682271  Lowest
#> 7  9.0953746 Highest
#> 8  1.0039538  Lowest
#> 9  4.3589922     Low
#> 10 0.8541879  Lowest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  1.1036164 -Inf - 2
#> 2  5.4159229    5 - 8
#> 3  3.4768280    2 - 5
#> 4  9.2537990  8 - Inf
#> 5  0.9854478 -Inf - 2
#> 6  1.6682271 -Inf - 2
#> 7  9.0953746  8 - Inf
#> 8  1.0039538 -Inf - 2
#> 9  4.3589922    2 - 5
#> 10 0.8541879 -Inf - 2
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  1.1036164 -Inf to 2
#> 2  5.4159229    5 to 8
#> 3  3.4768280    2 to 5
#> 4  9.2537990  8 to Inf
#> 5  0.9854478 -Inf to 2
#> 6  1.6682271 -Inf to 2
#> 7  9.0953746  8 to Inf
#> 8  1.0039538 -Inf to 2
#> 9  4.3589922    2 to 5
#> 10 0.8541879 -Inf to 2
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  1.1036164       1
#> 2  5.4159229       3
#> 3  3.4768280       2
#> 4  9.2537990       4
#> 5  0.9854478       1
#> 6  1.6682271       1
#> 7  9.0953746       4
#> 8  1.0039538       1
#> 9  4.3589922       2
#> 10 0.8541879       1
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] a c b d a a d a b a
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] i   iii ii  iv  i   i   iv  i   ii  i  
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  1.1036164    <NA>
#> 2  5.4159229  [5, 7]
#> 3  3.4768280  [3, 5)
#> 4  9.2537990    <NA>
#> 5  0.9854478    <NA>
#> 6  1.6682271    <NA>
#> 7  9.0953746    <NA>
#> 8  1.0039538    <NA>
#> 9  4.3589922  [3, 5)
#> 10 0.8541879    <NA>
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
#>  [1] 1.03 - 2.57 5.15 - Inf  2.57 - 5.15 5.15 - Inf  -Inf - 1.03
#>  [6] 1.03 - 2.57 5.15 - Inf  -Inf - 1.03 2.57 - 5.15 -Inf - 1.03
#> Levels: -Inf - 1.03 1.03 - 2.57 2.57 - 5.15 5.15 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>   -Inf - -0.954 -0.954 - -0.177  -0.177 - 0.644     0.644 - Inf 
#>              13              12              12              13
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
#>  chop(rnorm(1e+05), -2:2) 13.04775 14.76724 16.72766 15.13787 16.60393
#>   cut(rnorm(1e+05), -2:2) 11.09089 12.19858 13.11613 12.43812 13.47277
#>        max neval cld
#>  110.97008   100   b
#>   22.13046   100  a
```
