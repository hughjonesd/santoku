
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
chopped <- chop(x, breaks = 0:10)
data.frame(x, chopped)
#>            x chopped
#> 1  0.6265701  [0, 1)
#> 2  2.7263255  [2, 3)
#> 3  0.4049512  [0, 1)
#> 4  9.9720659 [9, 10]
#> 5  8.1095773  [8, 9)
#> 6  3.4927747  [3, 4)
#> 7  9.4063044 [9, 10]
#> 8  7.1975784  [7, 8)
#> 9  6.2607050  [6, 7)
#> 10 2.6999828  [2, 3)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chop(x, breaks = 3:7)
#>  [1] [-Inf, 3) [-Inf, 3) [-Inf, 3) (7, Inf]  (7, Inf]  [3, 4)    (7, Inf] 
#>  [8] (7, Inf]  [6, 7]    [-Inf, 3)
#> Levels: [-Inf, 3) [3, 4) [6, 7] (7, Inf]
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chop(x_fives, c(2, 5, 5, 8))
#>  [1] {5}      {5}      {5}      {5}      {5}      [2, 5)   (8, Inf]
#>  [8] (5, 8]   (5, 8]   [2, 5)  
#> Levels: [2, 5) {5} (5, 8] (8, Inf]
```

To quickly produce a table of chopped data, use `tab()`:

``` r
tab(x, c(2, 5, 8))
#> x
#> [-Inf, 2)    [2, 5)    [5, 8]  (8, Inf] 
#>         2         3         2         3
```

## More ways to chop

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chop_quantiles(x, c(0.25, 0.5, 0.75))
#>  [1] 0-25%   25-50%  0-25%   75-100% 75-100% 25-50%  75-100% 50-75% 
#>  [9] 50-75%  0-25%  
#> Levels: 0-25% 25-50% 50-75% 75-100%
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chop_equal(x, 3)
#>  [1] [-Inf, 2.7) [2.7, 7.2]  [-Inf, 2.7) (7.2, Inf]  (7.2, Inf] 
#>  [6] [2.7, 7.2]  (7.2, Inf]  [2.7, 7.2]  [2.7, 7.2]  [-Inf, 2.7)
#> Levels: [-Inf, 2.7) [2.7, 7.2] (7.2, Inf]
```

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chop_width(x, 2)
#>  [1] [0.4, 2.4) [2.4, 4.4) [0.4, 2.4) (8.4, Inf] [6.4, 8.4] [2.4, 4.4)
#>  [7] (8.4, Inf] [6.4, 8.4] [4.4, 6.4) [2.4, 4.4)
#> Levels: [0.4, 2.4) [2.4, 4.4) [4.4, 6.4) [6.4, 8.4] (8.4, Inf]
```

To chop into groups with a fixed *size* (i.e. number of members), use
`chop_size()`:

``` r
chop_size(x, 4)
#>  [1] [0.4, 3.5) [0.4, 3.5) [0.4, 3.5) [9.4, Inf] [3.5, 9.4) [3.5, 9.4)
#>  [7] [9.4, Inf] [3.5, 9.4) [3.5, 9.4) [0.4, 3.5)
#> Levels: [0.4, 3.5) [3.5, 9.4) [9.4, Inf]
```

`tab_size()` and `tab_width()` do the same as `tab()`:

``` r
tab_width(x, 2)
#> x
#> [-Inf, 0.4)  [0.4, 2.4)  [2.4, 4.4)  [4.4, 6.4)  [6.4, 8.4]  (8.4, Inf] 
#>           0           2           3           1           2           2
tab_size(x, 4)
#> x
#> [-Inf, 0.4)  [0.4, 3.5)  [3.5, 9.4)  [9.4, Inf] 
#>           0           4           4           2
```

# Advanced usage

You can change factor labels with the `labels` argument:

``` r
chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
#>  [1] Lowest  Low     Lowest  Highest Highest Low     Highest Higher 
#>  [9] Higher  Low    
#> Levels: Lowest Low Higher Highest
```

You need one more label than there are breaks.

To label intervals with a dash, use `lbl_dash()`:

``` r
chop(x, c(2, 5, 8), lbl_dash())
#>  [1] -Inf - 2 2 - 5    -Inf - 2 8 - Inf  8 - Inf  2 - 5    8 - Inf 
#>  [8] 5 - 8    5 - 8    2 - 5   
#> Levels: -Inf - 2 2 - 5 5 - 8 8 - Inf
```

For arbitrary formatting use `lbl_format()` and `sprintf`-style format
strings:

``` r
chop(x, c(2, 5, 8), lbl_format("%s to %s"))
#>  [1] -Inf to 2 2 to 5    -Inf to 2 8 to Inf  8 to Inf  2 to 5    8 to Inf 
#>  [8] 5 to 8    5 to 8    2 to 5   
#> Levels: -Inf to 2 2 to 5 5 to 8 8 to Inf
```

To number intervals in order use `lbl_numerals()`:

``` r
chop(x, c(2, 5, 8), lbl_numerals())
#>  [1] 1 2 1 4 4 2 4 3 3 2
#> Levels: 1 2 3 4
```

You can use letters or even roman numerals:

``` r
chop(x, c(2, 5, 8), lbl_letters())
#>  [1] a b a d d b d c c b
#> Levels: a b c d
chop(x, c(2, 5, 8), lbl_roman())
#>  [1] i   ii  i   iv  iv  ii  iv  iii iii ii 
#> Levels: i ii iii iv
```

By default, `chop()` extends `breaks` if necessary. If you don’t want
that, set `extend = FALSE`:

``` r
chop(x, c(3, 5, 7), extend = FALSE)
#>  [1] <NA>   <NA>   <NA>   <NA>   <NA>   [3, 5) <NA>   <NA>   [5, 7] <NA>  
#> Levels: [3, 5) [5, 7]
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
