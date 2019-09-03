
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
#>  [1] [8, 9)  [6, 7)  [8, 9)  [0, 1)  [2, 3)  [0, 1)  [8, 9)  [9, 10]
#>  [9] [5, 6)  [3, 4) 
#> Levels: [0, 1) [2, 3) [3, 4) [5, 6) [6, 7) [8, 9) [9, 10]
data.frame(x, chopped)
#>            x chopped
#> 1  8.6603941  [8, 9)
#> 2  6.4675134  [6, 7)
#> 3  8.7611954  [8, 9)
#> 4  0.9420829  [0, 1)
#> 5  2.1563750  [2, 3)
#> 6  0.1230766  [0, 1)
#> 7  8.9964951  [8, 9)
#> 8  9.2138624 [9, 10]
#> 9  5.9640762  [5, 6)
#> 10 3.4464425  [3, 4)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  8.6603941  (7, Inf]
#> 2  6.4675134    [6, 7]
#> 3  8.7611954  (7, Inf]
#> 4  0.9420829 [-Inf, 3)
#> 5  2.1563750 [-Inf, 3)
#> 6  0.1230766 [-Inf, 3)
#> 7  8.9964951  (7, Inf]
#> 8  9.2138624  (7, Inf]
#> 9  5.9640762    [5, 6)
#> 10 3.4464425    [3, 4)
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
#> 6  0.1230766 [-Inf, 2)
#> 7  8.9964951  (8, Inf]
#> 8  9.2138624  (8, Inf]
#> 9  5.9640762    (5, 8]
#> 10 3.4464425    [2, 5)
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
#> 1  8.6603941 [8.1230766, 10.1230766]
#> 2  6.4675134  [6.1230766, 8.1230766)
#> 3  8.7611954 [8.1230766, 10.1230766]
#> 4  0.9420829  [0.1230766, 2.1230766)
#> 5  2.1563750  [2.1230766, 4.1230766)
#> 6  0.1230766  [0.1230766, 2.1230766)
#> 7  8.9964951 [8.1230766, 10.1230766]
#> 8  9.2138624 [8.1230766, 10.1230766]
#> 9  5.9640762  [4.1230766, 6.1230766)
#> 10 3.4464425  [2.1230766, 4.1230766)
```

To chop into groups with a fixed number of members, use `chop_n()`:

``` r
chopped <- chop_n(x, 4)
table(chopped)
#> chopped
#> [0.1230766, 5.9640762) [5.9640762, 8.9964951)       [8.9964951, Inf] 
#>                      4                      4                      2
```

To chop into a fixed number of equal-sized groups, use `chop_equal()`:

``` r
chopped <- chop_equal(x, groups = 5)
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
#> 1  8.6603941  [50%, 75%)
#> 2  6.4675134  [50%, 75%)
#> 3  8.7611954 [75%, 100%]
#> 4  0.9420829   [0%, 25%)
#> 5  2.1563750   [0%, 25%)
#> 6  0.1230766   [0%, 25%)
#> 7  8.9964951 [75%, 100%]
#> 8  9.2138624 [75%, 100%]
#> 9  5.9640762  [25%, 50%)
#> 10 3.4464425  [25%, 50%)
```

To chop data by standard deviations around the mean, use
`chop_mean_sd()`:

``` r
chopped <- chop_mean_sd(x)
data.frame(x, chopped)
#>            x        chopped
#> 1  8.6603941   [0 sd, 1 sd)
#> 2  6.4675134   [0 sd, 1 sd)
#> 3  8.7611954   [0 sd, 1 sd)
#> 4  0.9420829 [-2 sd, -1 sd)
#> 5  2.1563750  [-1 sd, 0 sd)
#> 6  0.1230766 [-2 sd, -1 sd)
#> 7  8.9964951   [0 sd, 1 sd)
#> 8  9.2138624   [1 sd, 2 sd)
#> 9  5.9640762   [0 sd, 1 sd)
#> 10 3.4464425  [-1 sd, 0 sd)
```

`tab_n()`, `tab_width()` and `tab_mean_sd()` act similarly to `tab()`,
calling the related `chop_` function and then `table()`.

``` r
tab_width(x, 2)
#> x
#>  [0.1230766, 2.1230766)  [2.1230766, 4.1230766)  [4.1230766, 6.1230766) 
#>                       2                       2                       1 
#>  [6.1230766, 8.1230766) [8.1230766, 10.1230766] 
#>                       1                       4
tab_n(x, 4)
#> x
#> [0.1230766, 5.9640762) [5.9640762, 8.9964951)       [8.9964951, Inf] 
#>                      4                      4                      2
tab_mean_sd(x)
#> x
#> [-2 sd, -1 sd)  [-1 sd, 0 sd)   [0 sd, 1 sd)   [1 sd, 2 sd) 
#>              2              2              5              1
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  8.6603941 Highest
#> 2  6.4675134  Higher
#> 3  8.7611954 Highest
#> 4  0.9420829  Lowest
#> 5  2.1563750     Low
#> 6  0.1230766  Lowest
#> 7  8.9964951 Highest
#> 8  9.2138624 Highest
#> 9  5.9640762  Higher
#> 10 3.4464425     Low
```

You need as many labels as there are intervals - one fewer than
`length(breaks)` if your data doesn’t extend beyond `breaks`, one more
than `length(breaks)` if it does.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  8.6603941  8 - Inf
#> 2  6.4675134    5 - 8
#> 3  8.7611954  8 - Inf
#> 4  0.9420829 -Inf - 2
#> 5  2.1563750    2 - 5
#> 6  0.1230766 -Inf - 2
#> 7  8.9964951  8 - Inf
#> 8  9.2138624  8 - Inf
#> 9  5.9640762    5 - 8
#> 10 3.4464425    2 - 5
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  8.6603941  8 to Inf
#> 2  6.4675134    5 to 8
#> 3  8.7611954  8 to Inf
#> 4  0.9420829 -Inf to 2
#> 5  2.1563750    2 to 5
#> 6  0.1230766 -Inf to 2
#> 7  8.9964951  8 to Inf
#> 8  9.2138624  8 to Inf
#> 9  5.9640762    5 to 8
#> 10 3.4464425    2 to 5
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  8.6603941       4
#> 2  6.4675134       3
#> 3  8.7611954       4
#> 4  0.9420829       1
#> 5  2.1563750       2
#> 6  0.1230766       1
#> 7  8.9964951       4
#> 8  9.2138624       4
#> 9  5.9640762       3
#> 10 3.4464425       2
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] d c d a b a d d c b
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iv  iii iv  i   ii  i   iv  iv  iii ii 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  8.6603941    <NA>
#> 2  6.4675134  [5, 7]
#> 3  8.7611954    <NA>
#> 4  0.9420829    <NA>
#> 5  2.1563750    <NA>
#> 6  0.1230766    <NA>
#> 7  8.9964951    <NA>
#> 8  9.2138624    <NA>
#> 9  5.9640762  [5, 7]
#> 10 3.4464425  [3, 5)
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
#>  [1] 50% - 75%  50% - 75%  75% - 100% 0% - 25%   0% - 25%   0% - 25%  
#>  [7] 75% - 100% 75% - 100% 25% - 50%  25% - 50% 
#> Levels: 0% - 25% 25% - 50% 50% - 75% 75% - 100%
table(chop_by_quartiles(rnorm(50)))
#> 
#>   0% - 25%  25% - 50%  50% - 75% 75% - 100% 
#>         13         12         12         13
```
