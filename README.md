
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
#>  [1] [8, 9)  [2, 3)  [5, 6)  [2, 3)  [0, 1)  [3, 4)  [9, 10] [3, 4) 
#>  [9] [3, 4)  [7, 8) 
#> Levels: [0, 1) [2, 3) [3, 4) [5, 6) [7, 8) [8, 9) [9, 10]
data.frame(x, chopped)
#>            x chopped
#> 1  8.4007505  [8, 9)
#> 2  2.0511181  [2, 3)
#> 3  5.0621184  [5, 6)
#> 4  2.2683803  [2, 3)
#> 5  0.9575925  [0, 1)
#> 6  3.1181037  [3, 4)
#> 7  9.9064892 [9, 10]
#> 8  3.5999298  [3, 4)
#> 9  3.2297283  [3, 4)
#> 10 7.4515561  [7, 8)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  8.4007505  (7, Inf]
#> 2  2.0511181 [-Inf, 3)
#> 3  5.0621184    [5, 6)
#> 4  2.2683803 [-Inf, 3)
#> 5  0.9575925 [-Inf, 3)
#> 6  3.1181037    [3, 4)
#> 7  9.9064892  (7, Inf]
#> 8  3.5999298    [3, 4)
#> 9  3.2297283    [3, 4)
#> 10 7.4515561  (7, Inf]
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
#> 6  3.118104   [2, 5)
#> 7  9.906489 (8, Inf]
#> 8  3.599930   [2, 5)
#> 9  3.229728   [2, 5)
#> 10 7.451556   (5, 8]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(1:10, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         1         3         4         2
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>            x                 chopped
#> 1  8.4007505  [6.9575925, 8.9575925)
#> 2  2.0511181  [0.9575925, 2.9575925)
#> 3  5.0621184  [4.9575925, 6.9575925)
#> 4  2.2683803  [0.9575925, 2.9575925)
#> 5  0.9575925  [0.9575925, 2.9575925)
#> 6  3.1181037  [2.9575925, 4.9575925)
#> 7  9.9064892 [8.9575925, 10.9575925]
#> 8  3.5999298  [2.9575925, 4.9575925)
#> 9  3.2297283  [2.9575925, 4.9575925)
#> 10 7.4515561  [6.9575925, 8.9575925)
```

To chop into exactly `groups` fixed-with intervals, use `chop_evenly()`:

``` r
chopped <- chop_evenly(x, groups = 3)
data.frame(x, chopped)
#>            x                chopped
#> 1  8.4007505 [6.9235236, 9.9064892]
#> 2  2.0511181 [0.9575925, 3.9405581)
#> 3  5.0621184 [3.9405581, 6.9235236)
#> 4  2.2683803 [0.9575925, 3.9405581)
#> 5  0.9575925 [0.9575925, 3.9405581)
#> 6  3.1181037 [0.9575925, 3.9405581)
#> 7  9.9064892 [6.9235236, 9.9064892]
#> 8  3.5999298 [0.9575925, 3.9405581)
#> 9  3.2297283 [0.9575925, 3.9405581)
#> 10 7.4515561 [6.9235236, 9.9064892]
```

To chop into groups with a fixed number of members, use `chop_n()`:

``` r
chopped <- chop_n(x, 4)
table(chopped)
#> chopped
#> [0.9575925, 3.2297283) [3.2297283, 8.4007505) [8.4007505, 9.9064892] 
#>                      4                      4                      2
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
#>            x     chopped
#> 1  8.4007505 [75%, 100%]
#> 2  2.0511181   [0%, 25%)
#> 3  5.0621184  [50%, 75%)
#> 4  2.2683803   [0%, 25%)
#> 5  0.9575925   [0%, 25%)
#> 6  3.1181037  [25%, 50%)
#> 7  9.9064892 [75%, 100%]
#> 8  3.5999298  [50%, 75%)
#> 9  3.2297283  [25%, 50%)
#> 10 7.4515561 [75%, 100%]
```

To chop data by standard deviations around the mean, use
`chop_mean_sd()`:

``` r
chopped <- chop_mean_sd(x)
data.frame(x, chopped)
#>            x        chopped
#> 1  8.4007505   [1 sd, 2 sd)
#> 2  2.0511181  [-1 sd, 0 sd)
#> 3  5.0621184   [0 sd, 1 sd)
#> 4  2.2683803  [-1 sd, 0 sd)
#> 5  0.9575925 [-2 sd, -1 sd)
#> 6  3.1181037  [-1 sd, 0 sd)
#> 7  9.9064892   [1 sd, 2 sd)
#> 8  3.5999298  [-1 sd, 0 sd)
#> 9  3.2297283  [-1 sd, 0 sd)
#> 10 7.4515561   [0 sd, 1 sd)
```

`tab_n()`, `tab_width()`, `tab_evenly()` and `tab_mean_sd()` act
similarly to `tab()`, calling the related `chop_` function and then
`table()`.

``` r
tab_n(x, 4)
#> x
#> [0.9575925, 3.2297283) [3.2297283, 8.4007505) [8.4007505, 9.9064892] 
#>                      4                      4                      2
tab_width(x, 2)
#> x
#>  [0.9575925, 2.9575925)  [2.9575925, 4.9575925)  [4.9575925, 6.9575925) 
#>                       3                       3                       1 
#>  [6.9575925, 8.9575925) [8.9575925, 10.9575925] 
#>                       2                       1
tab_evenly(x, 5)
#> x
#> [0.9575925, 2.7473718) [2.7473718, 4.5371512) [4.5371512, 6.3269305) 
#>                      3                      3                      1 
#> [6.3269305, 8.1167099) [8.1167099, 9.9064892] 
#>                      1                      2
tab_mean_sd(x)
#> x
#> [-2 sd, -1 sd)  [-1 sd, 0 sd)   [0 sd, 1 sd)   [1 sd, 2 sd) 
#>              1              5              2              2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  8.4007505 Highest
#> 2  2.0511181     Low
#> 3  5.0621184  Higher
#> 4  2.2683803     Low
#> 5  0.9575925  Lowest
#> 6  3.1181037     Low
#> 7  9.9064892 Highest
#> 8  3.5999298     Low
#> 9  3.2297283     Low
#> 10 7.4515561  Higher
```

You need as many labels as there are intervals - one fewer than
`length(breaks)` if your data doesn’t extend beyond `breaks`, one more
than `length(breaks)` if it does.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  8.4007505  8 - Inf
#> 2  2.0511181    2 - 5
#> 3  5.0621184    5 - 8
#> 4  2.2683803    2 - 5
#> 5  0.9575925 -Inf - 2
#> 6  3.1181037    2 - 5
#> 7  9.9064892  8 - Inf
#> 8  3.5999298    2 - 5
#> 9  3.2297283    2 - 5
#> 10 7.4515561    5 - 8
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  8.4007505  8 to Inf
#> 2  2.0511181    2 to 5
#> 3  5.0621184    5 to 8
#> 4  2.2683803    2 to 5
#> 5  0.9575925 -Inf to 2
#> 6  3.1181037    2 to 5
#> 7  9.9064892  8 to Inf
#> 8  3.5999298    2 to 5
#> 9  3.2297283    2 to 5
#> 10 7.4515561    5 to 8
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  8.4007505       4
#> 2  2.0511181       2
#> 3  5.0621184       3
#> 4  2.2683803       2
#> 5  0.9575925       1
#> 6  3.1181037       2
#> 7  9.9064892       4
#> 8  3.5999298       2
#> 9  3.2297283       2
#> 10 7.4515561       3
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] d b c b a b d b b c
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iv  ii  iii ii  i   ii  iv  ii  ii  iii
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  8.4007505    <NA>
#> 2  2.0511181    <NA>
#> 3  5.0621184  [5, 7]
#> 4  2.2683803    <NA>
#> 5  0.9575925    <NA>
#> 6  3.1181037  [3, 5)
#> 7  9.9064892    <NA>
#> 8  3.5999298  [3, 5)
#> 9  3.2297283  [3, 5)
#> 10 7.4515561    <NA>
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
#>  [1] 75% - 100% 0% - 25%   50% - 75%  0% - 25%   0% - 25%   25% - 50% 
#>  [7] 75% - 100% 50% - 75%  25% - 50%  75% - 100%
#> Levels: 0% - 25% 25% - 50% 50% - 75% 75% - 100%
table(chop_by_quartiles(rnorm(50)))
#> 
#>   0% - 25%  25% - 50%  50% - 75% 75% - 100% 
#>         13         12         12         13
```
