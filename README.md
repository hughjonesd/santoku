
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku <img src="man/figures/logo.png" align="right" alt="santoku logo" width="120" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/santoku.svg?branch=master)](https://travis-ci.org/hughjonesd/santoku)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
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
#>  [1] [8, 9)  [7, 8)  [7, 8)  [3, 4)  [5, 6)  [2, 3)  [3, 4)  [9, 10]
#>  [9] [9, 10] [2, 3) 
#> Levels: [2, 3) [3, 4) [5, 6) [7, 8) [8, 9) [9, 10]
data.frame(x, chopped)
#>           x chopped
#> 1  8.236855  [8, 9)
#> 2  7.852700  [7, 8)
#> 3  7.599159  [7, 8)
#> 4  3.315497  [3, 4)
#> 5  5.359981  [5, 6)
#> 6  2.700143  [2, 3)
#> 7  3.977909  [3, 4)
#> 8  9.652508 [9, 10]
#> 9  9.335848 [9, 10]
#> 10 2.884556  [2, 3)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>           x   chopped
#> 1  8.236855  (7, Inf]
#> 2  7.852700  (7, Inf]
#> 3  7.599159  (7, Inf]
#> 4  3.315497    [3, 4)
#> 5  5.359981    [5, 6)
#> 6  2.700143 [-Inf, 3)
#> 7  3.977909    [3, 4)
#> 8  9.652508  (7, Inf]
#> 9  9.335848  (7, Inf]
#> 10 2.884556 [-Inf, 3)
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
#> 6  2.700143   [2, 5)
#> 7  3.977909   [2, 5)
#> 8  9.652508 (8, Inf]
#> 9  9.335848 (8, Inf]
#> 10 2.884556   [2, 5)
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         0         4         3         3
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>           x    chopped
#> 1  8.236855 [6.7, 8.7]
#> 2  7.852700 [6.7, 8.7]
#> 3  7.599159 [6.7, 8.7]
#> 4  3.315497 [2.7, 4.7)
#> 5  5.359981 [4.7, 6.7)
#> 6  2.700143 [2.7, 4.7)
#> 7  3.977909 [2.7, 4.7)
#> 8  9.652508 (8.7, Inf]
#> 9  9.335848 (8.7, Inf]
#> 10 2.884556 [2.7, 4.7)
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [2.7, 5.4) [5.4, 9.3) [9.3, Inf] 
#>          4          4          2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#>  [-Inf, 4)   [4, 7.9] (7.9, Inf] 
#>          3          4          3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>           x chopped
#> 1  8.236855 75-100%
#> 2  7.852700  50-75%
#> 3  7.599159  50-75%
#> 4  3.315497   0-25%
#> 5  5.359981  25-50%
#> 6  2.700143   0-25%
#> 7  3.977909  25-50%
#> 8  9.652508 75-100%
#> 9  9.335848 75-100%
#> 10 2.884556   0-25%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 2.7)  [2.7, 4.7)  [4.7, 6.7)  [6.7, 8.7]  (8.7, Inf] 
#>           0           4           1           3           2
tab_size(x, 4)
#> x
#> [-Inf, 2.7)  [2.7, 5.4)  [5.4, 9.3)  [9.3, Inf] 
#>           0           4           4           2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>           x chopped
#> 1  8.236855 Highest
#> 2  7.852700  Higher
#> 3  7.599159  Higher
#> 4  3.315497     Low
#> 5  5.359981  Higher
#> 6  2.700143     Low
#> 7  3.977909     Low
#> 8  9.652508 Highest
#> 9  9.335848 Highest
#> 10 2.884556     Low
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>           x chopped
#> 1  8.236855 8 - Inf
#> 2  7.852700   5 - 8
#> 3  7.599159   5 - 8
#> 4  3.315497   2 - 5
#> 5  5.359981   5 - 8
#> 6  2.700143   2 - 5
#> 7  3.977909   2 - 5
#> 8  9.652508 8 - Inf
#> 9  9.335848 8 - Inf
#> 10 2.884556   2 - 5
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>           x  chopped
#> 1  8.236855 8 to Inf
#> 2  7.852700   5 to 8
#> 3  7.599159   5 to 8
#> 4  3.315497   2 to 5
#> 5  5.359981   5 to 8
#> 6  2.700143   2 to 5
#> 7  3.977909   2 to 5
#> 8  9.652508 8 to Inf
#> 9  9.335848 8 to Inf
#> 10 2.884556   2 to 5
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>           x chopped
#> 1  8.236855       4
#> 2  7.852700       3
#> 3  7.599159       3
#> 4  3.315497       2
#> 5  5.359981       3
#> 6  2.700143       2
#> 7  3.977909       2
#> 8  9.652508       4
#> 9  9.335848       4
#> 10 2.884556       2
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] d c c b c b b d d b
#> Levels: b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iv  iii iii ii  iii ii  ii  iv  iv  ii 
#> Levels: ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>           x chopped
#> 1  8.236855    <NA>
#> 2  7.852700    <NA>
#> 3  7.599159    <NA>
#> 4  3.315497  [3, 5)
#> 5  5.359981  [5, 7]
#> 6  2.700143    <NA>
#> 7  3.977909  [3, 5)
#> 8  9.652508    <NA>
#> 9  9.335848    <NA>
#> 10 2.884556    <NA>
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
#>  [1] 8.14 - Inf  6.48 - 8.14 6.48 - 8.14 -Inf - 3.48 3.48 - 6.48
#>  [6] -Inf - 3.48 3.48 - 6.48 8.14 - Inf  8.14 - Inf  -Inf - 3.48
#> Levels: -Inf - 3.48 3.48 - 6.48 6.48 - 8.14 8.14 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>  -Inf - -0.644 -0.644 - 0.151  0.151 - 0.811    0.811 - Inf 
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
#>  chop(rnorm(1e+05), -2:2) 15.41595 17.55276 18.71340 18.13559 19.30524
#>   cut(rnorm(1e+05), -2:2) 12.25860 13.49718 14.40429 13.72798 14.60841
#>       max neval cld
#>  26.72603   100   b
#>  23.13729   100  a
```
