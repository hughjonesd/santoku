
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku

<!-- badges: start -->

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
#>  [1] [8, 9) [0, 1) [5, 6) [8, 9) [2, 3) [4, 5) [7, 8) [6, 7) [7, 8) [4, 5)
#> Levels: [0, 1) [2, 3) [4, 5) [5, 6) [6, 7) [7, 8) [8, 9)
data.frame(x, chopped)
#>            x chopped
#> 1  8.0293972  [8, 9)
#> 2  0.6022035  [0, 1)
#> 3  5.5090891  [5, 6)
#> 4  8.7108604  [8, 9)
#> 5  2.9109235  [2, 3)
#> 6  4.7939638  [4, 5)
#> 7  7.1476866  [7, 8)
#> 8  6.2216030  [6, 7)
#> 9  7.6285248  [7, 8)
#> 10 4.3222887  [4, 5)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>            x   chopped
#> 1  8.0293972  (7, Inf]
#> 2  0.6022035 [-Inf, 3)
#> 3  5.5090891    [5, 6)
#> 4  8.7108604  (7, Inf]
#> 5  2.9109235 [-Inf, 3)
#> 6  4.7939638    [4, 5)
#> 7  7.1476866  (7, Inf]
#> 8  6.2216030    [6, 7]
#> 9  7.6285248  (7, Inf]
#> 10 4.3222887    [4, 5)
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chopped <- chop(x_fives, c(2, 5, 5, 8))
data.frame(x_fives, chopped)
#>     x_fives chopped
#> 1  5.000000     {5}
#> 2  5.000000     {5}
#> 3  5.000000     {5}
#> 4  5.000000     {5}
#> 5  5.000000     {5}
#> 6  4.793964  [2, 5)
#> 7  7.147687  (5, 8]
#> 8  6.221603  (5, 8]
#> 9  7.628525  (5, 8]
#> 10 4.322289  [2, 5)
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
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
#>            x    chopped
#> 1  8.0293972 [6.6, 8.6]
#> 2  0.6022035 [0.6, 2.6)
#> 3  5.5090891 [4.6, 6.6)
#> 4  8.7108604 (8.6, Inf]
#> 5  2.9109235 [2.6, 4.6)
#> 6  4.7939638 [4.6, 6.6)
#> 7  7.1476866 [6.6, 8.6]
#> 8  6.2216030 [4.6, 6.6)
#> 9  7.6285248 [6.6, 8.6]
#> 10 4.3222887 [2.6, 4.6)
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [0.6, 5.5)   [5.5, 8)   [8, Inf] 
#>          4          4          2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 4.8)  [4.8, 7.1]  (7.1, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>            x chopped
#> 1  8.0293972 75-100%
#> 2  0.6022035   0-25%
#> 3  5.5090891  25-50%
#> 4  8.7108604 75-100%
#> 5  2.9109235   0-25%
#> 6  4.7939638  25-50%
#> 7  7.1476866  50-75%
#> 8  6.2216030  50-75%
#> 9  7.6285248 75-100%
#> 10 4.3222887   0-25%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.6)  [0.6, 2.6)  [2.6, 4.6)  [4.6, 6.6)  [6.6, 8.6]  (8.6, Inf] 
#>           0           1           2           3           3           1
tab_size(x, 4)
#> x
#> [-Inf, 0.6)  [0.6, 5.5)    [5.5, 8)    [8, Inf] 
#>           0           4           4           2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>            x chopped
#> 1  8.0293972 Highest
#> 2  0.6022035  Lowest
#> 3  5.5090891  Higher
#> 4  8.7108604 Highest
#> 5  2.9109235     Low
#> 6  4.7939638     Low
#> 7  7.1476866  Higher
#> 8  6.2216030  Higher
#> 9  7.6285248  Higher
#> 10 4.3222887     Low
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>            x  chopped
#> 1  8.0293972  8 - Inf
#> 2  0.6022035 -Inf - 2
#> 3  5.5090891    5 - 8
#> 4  8.7108604  8 - Inf
#> 5  2.9109235    2 - 5
#> 6  4.7939638    2 - 5
#> 7  7.1476866    5 - 8
#> 8  6.2216030    5 - 8
#> 9  7.6285248    5 - 8
#> 10 4.3222887    2 - 5
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>            x   chopped
#> 1  8.0293972  8 to Inf
#> 2  0.6022035 -Inf to 2
#> 3  5.5090891    5 to 8
#> 4  8.7108604  8 to Inf
#> 5  2.9109235    2 to 5
#> 6  4.7939638    2 to 5
#> 7  7.1476866    5 to 8
#> 8  6.2216030    5 to 8
#> 9  7.6285248    5 to 8
#> 10 4.3222887    2 to 5
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>            x chopped
#> 1  8.0293972       4
#> 2  0.6022035       1
#> 3  5.5090891       3
#> 4  8.7108604       4
#> 5  2.9109235       2
#> 6  4.7939638       2
#> 7  7.1476866       3
#> 8  6.2216030       3
#> 9  7.6285248       3
#> 10 4.3222887       2
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] d a c d b b c c c b
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] iv  i   iii iv  ii  ii  iii iii iii ii 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>            x chopped
#> 1  8.0293972    <NA>
#> 2  0.6022035    <NA>
#> 3  5.5090891  [5, 7]
#> 4  8.7108604    <NA>
#> 5  2.9109235    <NA>
#> 6  4.7939638  [3, 5)
#> 7  7.1476866    <NA>
#> 8  6.2216030  [5, 7]
#> 9  7.6285248    <NA>
#> 10 4.3222887  [3, 5)
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
#>  [1] 7.51 - Inf  -Inf - 4.44 4.44 - 5.87 7.51 - Inf  -Inf - 4.44
#>  [6] 4.44 - 5.87 5.87 - 7.51 5.87 - 7.51 7.51 - Inf  -Inf - 4.44
#> Levels: -Inf - 4.44 4.44 - 5.87 5.87 - 7.51 7.51 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>   -Inf - -0.59 -0.59 - -0.102 -0.102 - 0.663    0.663 - Inf 
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
#>  chop(rnorm(1e+05), -2:2) 32.69356 37.28347 41.40150 40.14253 44.44661
#>   cut(rnorm(1e+05), -2:2) 24.49327 27.34195 29.98106 29.30773 31.13626
#>       max neval cld
#>  65.76004   100   b
#>  41.18821   100  a
```
