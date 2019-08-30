
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/santoku.svg?branch=master)](https://travis-ci.org/hughjonesd/santoku)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
<!-- badges: end -->

![santoku logo](man/figures/logo.png)

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
#>  [1] [2, 3)  [3, 4)  [1, 2)  [5, 6)  [3, 4)  [5, 6)  [5, 6)  [0, 1) 
#>  [9] [9, 10] [8, 9) 
#> Levels: [0, 1) [1, 2) [2, 3) [3, 4) [5, 6) [8, 9) [9, 10]
data.frame(x, chopped)
#>             x chopped
#> 1  2.35770226  [2, 3)
#> 2  3.82448974  [3, 4)
#> 3  1.78764473  [1, 2)
#> 4  5.00303425  [5, 6)
#> 5  3.52210902  [3, 4)
#> 6  5.63305927  [5, 6)
#> 7  5.82707214  [5, 6)
#> 8  0.09598297  [0, 1)
#> 9  9.24836611 [9, 10]
#> 10 8.75264246  [8, 9)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>             x   chopped
#> 1  2.35770226 [-Inf, 3)
#> 2  3.82448974    [3, 4)
#> 3  1.78764473 [-Inf, 3)
#> 4  5.00303425    [5, 6)
#> 5  3.52210902    [3, 4)
#> 6  5.63305927    [5, 6)
#> 7  5.82707214    [5, 6)
#> 8  0.09598297 [-Inf, 3)
#> 9  9.24836611  (7, Inf]
#> 10 8.75264246  (7, Inf]
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chopped <- chop(x_fives, c(2, 5, 5, 8))
data.frame(x_fives, chopped)
#>       x_fives   chopped
#> 1  5.00000000       {5}
#> 2  5.00000000       {5}
#> 3  5.00000000       {5}
#> 4  5.00000000       {5}
#> 5  5.00000000       {5}
#> 6  5.63305927    (5, 8]
#> 7  5.82707214    (5, 8]
#> 8  0.09598297 [-Inf, 2)
#> 9  9.24836611  (8, Inf]
#> 10 8.75264246  (8, Inf]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         2         3         3         2
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>             x      chopped
#> 1  2.35770226   [2.1, 4.1)
#> 2  3.82448974   [2.1, 4.1)
#> 3  1.78764473 [0.096, 2.1)
#> 4  5.00303425   [4.1, 6.1)
#> 5  3.52210902   [2.1, 4.1)
#> 6  5.63305927   [4.1, 6.1)
#> 7  5.82707214   [4.1, 6.1)
#> 8  0.09598297 [0.096, 2.1)
#> 9  9.24836611   (8.1, Inf]
#> 10 8.75264246   (8.1, Inf]
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.096, 3.8)   [3.8, 8.8)   [8.8, Inf] 
#>            4            4            2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 3.5)  [3.5, 5.6]  (5.6, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>             x chopped
#> 1  2.35770226   0-25%
#> 2  3.82448974  25-50%
#> 3  1.78764473   0-25%
#> 4  5.00303425  50-75%
#> 5  3.52210902  25-50%
#> 6  5.63305927  50-75%
#> 7  5.82707214 75-100%
#> 8  0.09598297   0-25%
#> 9  9.24836611 75-100%
#> 10 8.75264246 75-100%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.096)  [0.096, 2.1)    [2.1, 4.1)    [4.1, 6.1)    [6.1, 8.1] 
#>             0             2             3             3             0 
#>    (8.1, Inf] 
#>             2
tab_size(x, 4)
#> x
#> [-Inf, 0.096)  [0.096, 3.8)    [3.8, 8.8)    [8.8, Inf] 
#>             0             4             4             2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>             x chopped
#> 1  2.35770226     Low
#> 2  3.82448974     Low
#> 3  1.78764473  Lowest
#> 4  5.00303425  Higher
#> 5  3.52210902     Low
#> 6  5.63305927  Higher
#> 7  5.82707214  Higher
#> 8  0.09598297  Lowest
#> 9  9.24836611 Highest
#> 10 8.75264246 Highest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>             x  chopped
#> 1  2.35770226    2 - 5
#> 2  3.82448974    2 - 5
#> 3  1.78764473 -Inf - 2
#> 4  5.00303425    5 - 8
#> 5  3.52210902    2 - 5
#> 6  5.63305927    5 - 8
#> 7  5.82707214    5 - 8
#> 8  0.09598297 -Inf - 2
#> 9  9.24836611  8 - Inf
#> 10 8.75264246  8 - Inf
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>             x   chopped
#> 1  2.35770226    2 to 5
#> 2  3.82448974    2 to 5
#> 3  1.78764473 -Inf to 2
#> 4  5.00303425    5 to 8
#> 5  3.52210902    2 to 5
#> 6  5.63305927    5 to 8
#> 7  5.82707214    5 to 8
#> 8  0.09598297 -Inf to 2
#> 9  9.24836611  8 to Inf
#> 10 8.75264246  8 to Inf
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>             x chopped
#> 1  2.35770226       2
#> 2  3.82448974       2
#> 3  1.78764473       1
#> 4  5.00303425       3
#> 5  3.52210902       2
#> 6  5.63305927       3
#> 7  5.82707214       3
#> 8  0.09598297       1
#> 9  9.24836611       4
#> 10 8.75264246       4
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] b b a c b c c a d d
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] ii  ii  i   iii ii  iii iii i   iv  iv 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>             x chopped
#> 1  2.35770226    <NA>
#> 2  3.82448974  [3, 5)
#> 3  1.78764473    <NA>
#> 4  5.00303425  [5, 7]
#> 5  3.52210902  [3, 5)
#> 6  5.63305927  [5, 7]
#> 7  5.82707214  [5, 7]
#> 8  0.09598297    <NA>
#> 9  9.24836611    <NA>
#> 10 8.75264246    <NA>
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
#>  [1] -Inf - 2.65 2.65 - 4.41 -Inf - 2.65 4.41 - 5.78 2.65 - 4.41
#>  [6] 4.41 - 5.78 5.78 - Inf  -Inf - 2.65 5.78 - Inf  5.78 - Inf 
#> Levels: -Inf - 2.65 2.65 - 4.41 4.41 - 5.78 5.78 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>   -Inf - -0.838 -0.838 - -0.339   -0.339 - 0.39      0.39 - Inf 
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
#>  chop(rnorm(1e+05), -2:2) 13.91996 15.79679 17.08258 16.13828 17.74974
#>   cut(rnorm(1e+05), -2:2) 11.13240 12.31140 13.15739 12.69595 13.31380
#>       max neval cld
#>  29.87616   100   b
#>  22.09939   100  a
```
