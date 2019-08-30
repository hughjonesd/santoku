
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
#>  [1] [3, 4)  [1, 2)  [2, 3)  [9, 10] [5, 6)  [3, 4)  [4, 5)  [3, 4) 
#>  [9] [6, 7)  [3, 4) 
#> Levels: [1, 2) [2, 3) [3, 4) [4, 5) [5, 6) [6, 7) [9, 10]
data.frame(x, chopped)
#>           x chopped
#> 1  3.254577  [3, 4)
#> 2  1.811796  [1, 2)
#> 3  2.524595  [2, 3)
#> 4  9.842434 [9, 10]
#> 5  5.080918  [5, 6)
#> 6  3.890088  [3, 4)
#> 7  4.869093  [4, 5)
#> 8  3.555330  [3, 4)
#> 9  6.223220  [6, 7)
#> 10 3.906678  [3, 4)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>           x   chopped
#> 1  3.254577    [3, 4)
#> 2  1.811796 [-Inf, 3)
#> 3  2.524595 [-Inf, 3)
#> 4  9.842434  (7, Inf]
#> 5  5.080918    [5, 6)
#> 6  3.890088    [3, 4)
#> 7  4.869093    [4, 5)
#> 8  3.555330    [3, 4)
#> 9  6.223220    [6, 7]
#> 10 3.906678    [3, 4)
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
#> 6  3.890088  [2, 5)
#> 7  4.869093  [2, 5)
#> 8  3.555330  [2, 5)
#> 9  6.223220  (5, 8]
#> 10 3.906678  [2, 5)
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         1         6         2         1
```

## More ways to chop

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>           x    chopped
#> 1  3.254577 [1.8, 3.8)
#> 2  1.811796 [1.8, 3.8)
#> 3  2.524595 [1.8, 3.8)
#> 4  9.842434 (9.8, Inf]
#> 5  5.080918 [3.8, 5.8)
#> 6  3.890088 [3.8, 5.8)
#> 7  4.869093 [3.8, 5.8)
#> 8  3.555330 [1.8, 3.8)
#> 9  6.223220 [5.8, 7.8)
#> 10 3.906678 [3.8, 5.8)
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chopped <- chop_size(x, 4)
table(chopped)
#> chopped
#> [1.8, 3.9) [3.9, 6.2) [6.2, Inf] 
#>          4          4          2
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chopped <- chop_equal(x, 3)
table(chopped)
#> chopped
#> [-Inf, 3.6)  [3.6, 4.9]  (4.9, Inf] 
#>           3           4           3
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>           x chopped
#> 1  3.254577   0-25%
#> 2  1.811796   0-25%
#> 3  2.524595   0-25%
#> 4  9.842434 75-100%
#> 5  5.080918 75-100%
#> 6  3.890088  25-50%
#> 7  4.869093  50-75%
#> 8  3.555330  25-50%
#> 9  6.223220 75-100%
#> 10 3.906678  50-75%
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 1.8)  [1.8, 3.8)  [3.8, 5.8)  [5.8, 7.8)  [7.8, 9.8]  (9.8, Inf] 
#>           0           4           4           1           0           1
tab_size(x, 4)
#> x
#> [-Inf, 1.8)  [1.8, 3.9)  [3.9, 6.2)  [6.2, Inf] 
#>           0           4           4           2
```

# Advanced usage

You can change factor labels with the `labels`
argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>           x chopped
#> 1  3.254577     Low
#> 2  1.811796  Lowest
#> 3  2.524595     Low
#> 4  9.842434 Highest
#> 5  5.080918  Higher
#> 6  3.890088     Low
#> 7  4.869093     Low
#> 8  3.555330     Low
#> 9  6.223220  Higher
#> 10 3.906678     Low
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_dash())
data.frame(x, chopped)
#>           x  chopped
#> 1  3.254577    2 - 5
#> 2  1.811796 -Inf - 2
#> 3  2.524595    2 - 5
#> 4  9.842434  8 - Inf
#> 5  5.080918    5 - 8
#> 6  3.890088    2 - 5
#> 7  4.869093    2 - 5
#> 8  3.555330    2 - 5
#> 9  6.223220    5 - 8
#> 10 3.906678    2 - 5
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_format("%s to %s"))
data.frame(x, chopped)
#>           x   chopped
#> 1  3.254577    2 to 5
#> 2  1.811796 -Inf to 2
#> 3  2.524595    2 to 5
#> 4  9.842434  8 to Inf
#> 5  5.080918    5 to 8
#> 6  3.890088    2 to 5
#> 7  4.869093    2 to 5
#> 8  3.555330    2 to 5
#> 9  6.223220    5 to 8
#> 10 3.906678    2 to 5
```

To number intervals in order use `lbl_numerals()`:

``` r
chopped <- chop(x, c(2, 5, 8), lbl_numerals())
data.frame(x, chopped)
#>           x chopped
#> 1  3.254577       2
#> 2  1.811796       1
#> 3  2.524595       2
#> 4  9.842434       4
#> 5  5.080918       3
#> 6  3.890088       2
#> 7  4.869093       2
#> 8  3.555330       2
#> 9  6.223220       3
#> 10 3.906678       2
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] b a b d c b b b c b
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] ii  i   ii  iv  iii ii  ii  ii  iii ii 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>           x chopped
#> 1  3.254577  [3, 5)
#> 2  1.811796    <NA>
#> 3  2.524595    <NA>
#> 4  9.842434    <NA>
#> 5  5.080918  [5, 7]
#> 6  3.890088  [3, 5)
#> 7  4.869093  [3, 5)
#> 8  3.555330  [3, 5)
#> 9  6.223220  [5, 7]
#> 10 3.906678  [3, 5)
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
#>  [1] -Inf - 3.33 -Inf - 3.33 -Inf - 3.33 5.03 - Inf  5.03 - Inf 
#>  [6] 3.33 - 3.9  3.9 - 5.03  3.33 - 3.9  5.03 - Inf  3.9 - 5.03 
#> Levels: -Inf - 3.33 3.33 - 3.9 3.9 - 5.03 5.03 - Inf
table(chop_by_quartiles(rnorm(50)))
#> 
#>   -Inf - -0.551 -0.551 - 0.0643  0.0643 - 0.776     0.776 - Inf 
#>              13              12              12              13
```

## Speed

The core of santoku is written in C++. It is reasonably fast:

``` r
microbenchmark::microbenchmark(
        chop(rnorm(1e6), -2:2),
         cut(rnorm(1e6), -2:2)
      )
#> Unit: milliseconds
#>                      expr      min       lq     mean   median       uq
#>  chop(rnorm(1e+06), -2:2) 310.9976 325.8276 345.4975 335.7518 354.1544
#>   cut(rnorm(1e+06), -2:2) 274.8432 279.6780 299.5998 290.4864 304.0389
#>       max neval cld
#>  490.1177   100   b
#>  439.4383   100  a
```
