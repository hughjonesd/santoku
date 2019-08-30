
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
#> 1  2.9225085  [2, 3)
#> 2  4.4490830  [4, 5)
#> 3  0.1002426  [0, 1)
#> 4  1.5718366  [1, 2)
#> 5  4.3537097  [4, 5)
#> 6  0.1585944  [0, 1)
#> 7  2.2132517  [2, 3)
#> 8  9.7078719 [9, 10]
#> 9  9.0622754 [9, 10]
#> 10 7.4245539  [7, 8)
```

`chop()` returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chop(x, breaks = 3:7)
#>  [1] [-Inf, 3) [4, 5)    [-Inf, 3) [-Inf, 3) [4, 5)    [-Inf, 3) [-Inf, 3)
#>  [8] (7, Inf]  (7, Inf]  (7, Inf] 
#> Levels: [-Inf, 3) [4, 5) (7, Inf]
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- c(x, rep(5, 5))
chop(x_fives, c(2, 5, 5, 8))
#>  [1] [2, 5)    [2, 5)    [-Inf, 2) [-Inf, 2) [2, 5)    [-Inf, 2) [2, 5)   
#>  [8] (8, Inf]  (8, Inf]  (5, 8]    {5}       {5}       {5}       {5}      
#> [15] {5}      
#> Levels: [-Inf, 2) [2, 5) {5} (5, 8] (8, Inf]
```

To chop data up by quantiles, use `chop_quantiles()`:

``` r
chop_quantiles(x, c(0.25, 0.5, 0.75))
#>  [1] 25-50%  50-75%  0-25%   0-25%   50-75%  0-25%   25-50%  75-100%
#>  [9] 75-100% 75-100%
#> Levels: 0-25% 25-50% 50-75% 75-100%
```

To chop into `n` equal sized groups use `chop_equal()`:

``` r
chop_equal(x, 3)
#>  [1] 33.3-66.7% 66.7-100%  0-33.3%    0-33.3%    33.3-66.7% 0-33.3%   
#>  [7] 33.3-66.7% 66.7-100%  66.7-100%  66.7-100% 
#> Levels: 0-33.3% 33.3-66.7% 66.7-100%
```

To chop into fixed-width intervals, starting at the minimum value, use
`chop_width()`:

``` r
chop_width(x, 2)
#>  [1] [2.1, 4.1) [4.1, 6.1) [0.1, 2.1) [0.1, 2.1) [4.1, 6.1) [0.1, 2.1)
#>  [7] [2.1, 4.1) (8.1, Inf] (8.1, Inf] [6.1, 8.1]
#> Levels: [0.1, 2.1) [2.1, 4.1) [4.1, 6.1) [6.1, 8.1] (8.1, Inf]
```
